#include "gtk_private.h"
#include <cwhip/Callbacks.h>
#include <cwhip/RuntimeGc.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#ifdef CWHIP_GTK_SOURCEVIEW
#include <gtksourceview/gtksource.h>
#endif

extern const CwhipClassMeta cwhip_string_class_meta;

typedef struct ShortcutBinding ShortcutBinding;
typedef struct MenuItem {
    struct MenuItem *next;
    int64_t token;
    int64_t menu;
    GSimpleAction *action;
    bool check;
    bool syncing;
} MenuItem;

typedef struct FileDialog {
    struct FileDialog *next;
    int64_t token;
    int64_t parent;
    GtkFileDialog *chooser;
    GCancellable *cancellable;
    CwhipCallbackContext *context;
    GSource *completion;
    GPtrArray *paths;
    bool multiple;
    bool save;
    bool folder;
    bool request_pending;
    bool cancelled;
} FileDialog;

typedef struct WidgetRecord {
    struct WidgetRecord *next;
    int64_t token;
    GtkWidget *widget;
    struct WidgetRecord *parent;
    void *receiver;
    CwhipCallbackContext *root;
    ShortcutBinding *shortcuts;
    GMenu *menu;
    GPtrArray *submenus;
    GSimpleActionGroup *actions;
    MenuItem *items;
    bool native_destroying;
    /* Borrowed Cairo context valid only while a DrawingArea draw callback runs. */
    cairo_t *draw_cr;
    /* Last pointer position inside a DrawingArea (widget coordinates). */
    double pointer_x;
    double pointer_y;
    bool pointer_inside;
} WidgetRecord;

/* A shortcut callback may dispose its own view (closing a tab or the window).
 * While `active` is nonzero, disposal only marks the binding: the callback
 * registration is released, and an orphaned binding freed, when the outermost
 * invocation unwinds. */
struct ShortcutBinding {
    ShortcutBinding *next;
    WidgetRecord *owner;
    CwhipCallbackContext *context;
    char *trigger;
    GtkEventController *controller;
    unsigned active;
    bool release_pending;
    bool orphaned;
};

static void shortcut_release(ShortcutBinding *binding) {
    if (!binding->context) return;
    if (binding->active) {
        binding->release_pending = true;
        return;
    }
    cwhip_callback_release(binding->context);
    cwhip_callback_dispose(binding->context);
    binding->context = NULL;
    binding->release_pending = false;
}

typedef struct Connection {
    struct Connection *next;
    int64_t token;
    GObject *object;
    gulong signal;
    gulong additional[3];
    unsigned additional_count;
    unsigned closures;
    CwhipCallbackContext *context;
    unsigned active;
    bool closed;
    bool detached;
    /* DrawingArea draw-func / ContextMenu popup-prepare connections are not
     * GObject signals; disconnect clears them explicitly. */
    bool draw_func;
    bool popup_func;
} Connection;

typedef struct Post {
    struct Post *next;
    int64_t token;
    GSource *source;
    CwhipCallbackTransfer *transfer;
} Post;

/* Lists and lifecycle state are protected by the runtime lock. Only the
 * immutable GUI identity is read at an unlocked signal boundary. */
static pthread_t owner;
static bool initialized;
static bool stopped;
static unsigned running;
static int64_t next_token;
static GMainContext *main_context;
static Connection *connections;
static Post *posts;
static WidgetRecord *widgets;
static FileDialog *dialogs;
static GtkApplication *application;
static bool activated;
static bool ran;
static bool scheduler_hold;
#ifdef CWHIP_GTK_SOURCEVIEW
static GtkSourceLanguageManager *source_language_manager;
/* Language ids whose <id>.lang file is installed by the sourceview package. */
static GHashTable *registered_languages;
#endif
static void widget_dispose(WidgetRecord *record);
static void window_removed(GtkApplication *app, GtkWindow *window, gpointer data);
static void dialog_finish(FileDialog *dialog, bool invoke);
static void dialog_cancel(FileDialog *dialog);
static void config_finish_shutdown(void);
static void drawing_area_pointer_enter(GtkEventControllerMotion *controller, double x,
                                       double y, gpointer data);
static void drawing_area_pointer_leave(GtkEventControllerMotion *controller, gpointer data);
static void drawing_area_pointer_motion(GtkEventControllerMotion *controller, double x,
                                        double y, gpointer data);

static _Noreturn void fatal(const char *message) {
    fprintf(stderr, "Cwhip GTK error: %s\n", message);
    abort();
}

/* Private typed receiver bindings compensate for Cwhip's lack of a this expression. */
void *cwhip_gtk_self(void *self) { return self; }

static void require_managed(void) {
    if (cwhip_runtime_managed_enter()) fatal("operation requires the managed runtime lock");
}

void cwhip_gtk_require_owner(void) {
    if (!initialized || !pthread_equal(owner, pthread_self()))
        fatal("operation requires the GUI owner thread");
}

static void require_live(void) {
    require_managed();
    cwhip_gtk_require_owner();
    if (stopped) fatal("application has shut down");
}

static int64_t token_new(void) {
    if (next_token == INT64_MAX) fatal("token space exhausted");
    return ++next_token;
}

static void connection_collect(Connection *connection) {
    if (!connection->detached || connection->active) return;
    Connection **link = &connections;
    while (*link != connection) link = &(*link)->next;
    *link = connection->next;
    cwhip_callback_release(connection->context);
    cwhip_callback_dispose(connection->context);
    free(connection);
}

static void connection_destroy(gpointer data, GClosure *closure) {
    (void)closure;
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    Connection *connection = data;
    if (--connection->closures == 0) {
        connection->object = NULL;
        connection->closed = true;
        connection->detached = true;
    }
    connection_collect(connection);
    cwhip_runtime_managed_leave(acquired);
}

static int signal_enter(Connection *connection) {
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    ++connection->active;
    return acquired;
}

static void signal_leave(Connection *connection, int acquired) {
    --connection->active;
    connection_collect(connection);
    cwhip_runtime_managed_leave(acquired);
}

static void clicked(GtkButton *button, gpointer data) {
    (void)button;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context);
    signal_leave(connection, acquired);
}

static void page_switched(GtkNotebook *notebook, GtkWidget *page, guint page_num,
                          gpointer data) {
    (void)notebook;
    (void)page;
    (void)page_num;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context);
    signal_leave(connection, acquired);
}

static void window_focus_changed(GtkWindow *window, GParamSpec *property, gpointer data) {
    (void)property;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, bool);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, gtk_window_is_active(window));
    signal_leave(connection, acquired);
}

static void changed(GtkEditable *editable, gpointer data) {
    (void)editable;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context);
    signal_leave(connection, acquired);
}

#ifdef CWHIP_GTK_SOURCEVIEW
static void changed_no_args(GObject *object, gpointer data) {
    (void)object;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context);
    signal_leave(connection, acquired);
}

static void state_notified(GObject *object, GParamSpec *property, gpointer data) {
    (void)property;
    changed_no_args(object, data);
}

static void cursor_moved(GtkTextBuffer *buffer, GtkTextIter *location,
                         GtkTextMark *mark, gpointer data) {
    (void)location;
    if (mark != gtk_text_buffer_get_insert(buffer)) return;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context);
    signal_leave(connection, acquired);
}
#endif

static void text_changed(GtkEditable *editable, gpointer data) {
    Connection *connection = data;
    int acquired = signal_enter(connection);
    const char *bytes = gtk_editable_get_text(editable);
    void *text = cwhip_string_new(&cwhip_string_class_meta, bytes, strlen(bytes));
    void *slots[] = { &text };
    CwhipRootFrame frame = {0};
    cwhip_gc_push_or_abort(&frame, slots, 1);
    typedef void (*Adapter)(CwhipCallbackContext *, void *);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context, text);
    cwhip_gc_pop_or_abort(&frame);
    signal_leave(connection, acquired);
}

static void toggled(GtkCheckButton *button, gpointer data) {
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, bool);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, gtk_check_button_get_active(button) != FALSE);
    signal_leave(connection, acquired);
}

static void activate(GApplication *app, gpointer data) {
    (void)app;
    clicked(NULL, data);
}

static void activation_started(GApplication *app, gpointer data) {
    (void)app;
    (void)data;
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    activated = true;
    cwhip_runtime_managed_leave(acquired);
}

static gboolean close_request(GtkWindow *window, gpointer data) {
    (void)window;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef bool (*Adapter)(CwhipCallbackContext *);
    bool result = ((Adapter)cwhip_callback_adapter(connection->context))(connection->context);
    signal_leave(connection, acquired);
    return result ? TRUE : FALSE;
}

static int64_t connect_signal(GObject *object, const char *signal,
                               GCallback forwarder, void *callback, const char *signature) {
    require_live();
    if (!object) fatal("null signal object");
    Connection *connection = calloc(1, sizeof(*connection));
    if (!connection) fatal("allocation failed");
    connection->token = token_new();
    connection->object = object;
    connection->context = cwhip_callback_acquire(callback, signature);
    connection->closures = 1;
    connection->next = connections;
    connections = connection;
    connection->signal = g_signal_connect_data(object, signal, forwarder, connection,
        connection_destroy, strcmp(signal, "switch-page") == 0 ? G_CONNECT_AFTER : 0);
    if (!connection->signal) fatal("signal connection failed");
    return connection->token;
}

#ifdef CWHIP_GTK_SOURCEVIEW
static void connect_state(int64_t token, const char *signal) {
    Connection *connection = connections;
    while (connection && connection->token != token) connection = connection->next;
    if (!connection || connection->additional_count == G_N_ELEMENTS(connection->additional))
        fatal("invalid grouped signal connection");
    ++connection->closures;
    gulong id = g_signal_connect_data(connection->object, signal, G_CALLBACK(state_notified),
                                     connection, connection_destroy, 0);
    if (!id) fatal("signal connection failed");
    connection->additional[connection->additional_count++] = id;
}
#endif

/* Non-focusable (toolbar) buttons activate on press. Waiting for the default
 * clicked-on-release path loses the action when the matching release is dropped
 * — the same failure mode as stuck notebook scroll arrows — so the first mouse
 * press appears to do nothing and only the second press runs the command. */
static void button_pressed(GtkGestureClick *gesture, gint n_press, gdouble x, gdouble y,
                           gpointer data) {
    (void)x;
    (void)y;
    if (n_press != 1) return;
    gtk_gesture_set_state(GTK_GESTURE(gesture), GTK_EVENT_SEQUENCE_CLAIMED);
    clicked(NULL, data);
}

int64_t cwhip_gtk_connect_clicked(GtkButton *button, void *callback) {
    require_live();
    if (!GTK_IS_BUTTON(button)) fatal("clicked requires GtkButton");
    if (!gtk_widget_get_can_focus(GTK_WIDGET(button))) {
        GtkGesture *gesture = gtk_gesture_click_new();
        gtk_gesture_single_set_button(GTK_GESTURE_SINGLE(gesture), GDK_BUTTON_PRIMARY);
        gtk_event_controller_set_propagation_phase(GTK_EVENT_CONTROLLER(gesture),
                                                   GTK_PHASE_CAPTURE);
        int64_t token = connect_signal(G_OBJECT(gesture), "pressed",
            G_CALLBACK(button_pressed), callback, "callback<void()>");
        gtk_widget_add_controller(GTK_WIDGET(button), GTK_EVENT_CONTROLLER(gesture));
        return token;
    }
    return connect_signal(G_OBJECT(button), "clicked", G_CALLBACK(clicked),
                          callback, "callback<void()>");
}

int64_t cwhip_gtk_connect_changed(GtkEditable *editable, void *callback) {
    require_live();
    if (!GTK_IS_EDITABLE(editable)) fatal("changed requires GtkEditable");
    return connect_signal(G_OBJECT(editable), "changed", G_CALLBACK(changed),
                          callback, "callback<void()>");
}

int64_t cwhip_gtk_connect_close_request(GtkWindow *window, void *callback) {
    require_live();
    if (!GTK_IS_WINDOW(window)) fatal("close-request requires GtkWindow");
    return connect_signal(G_OBJECT(window), "close-request", G_CALLBACK(close_request),
                          callback, "callback<bool()>");
}

bool cwhip_gtk_disconnect(int64_t token) {
    require_managed();
    cwhip_gtk_require_owner();
    for (Connection *connection = connections; connection; connection = connection->next) {
        if (connection->token != token) continue;
        if (connection->closed) return false;
        /* GClosure defers its notify until emission unwinds. The active
         * count also covers synchronous/nested callbacks explicitly. */
        connection->closed = true;
        GObject *object = connection->object;
        if (connection->draw_func) {
            /* Clearing the draw func invokes its destroy notify, which
             * releases the Connection the same way a GClosure notify does. */
            gtk_drawing_area_set_draw_func(GTK_DRAWING_AREA(object), NULL, NULL, NULL);
            return true;
        }
        if (connection->popup_func) {
            /* Drop the prepare callback stored on the popover; no GClosure. */
            if (object) g_object_set_data(object, "cwhip-popup", NULL);
            connection->object = NULL;
            connection->detached = true;
            connection_collect(connection);
            return true;
        }
        gulong ids[4] = { connection->signal };
        unsigned count = connection->additional_count + 1;
        memcpy(ids + 1, connection->additional, connection->additional_count * sizeof(gulong));
        for (unsigned i = 0; i < count; ++i) g_signal_handler_disconnect(object, ids[i]);
        return true;
    }
    return false;
}

#ifdef CWHIP_GTK_SOURCEVIEW
static void register_languages(const char *directory) {
    GDir *dir = g_dir_open(directory, 0, NULL);
    if (!dir) return;
    for (const char *name; (name = g_dir_read_name(dir));) {
        if (g_str_has_suffix(name, ".lang") && strlen(name) > 5)
            g_hash_table_add(registered_languages, g_strndup(name, strlen(name) - 5));
    }
    g_dir_close(dir);
}

static bool directory_has_languages(const char *directory) {
    GDir *dir = g_dir_open(directory, 0, NULL);
    if (!dir) return false;
    bool found = false;
    for (const char *name; (name = g_dir_read_name(dir));) {
        if (g_str_has_suffix(name, ".lang")) {
            found = true;
            break;
        }
    }
    g_dir_close(dir);
    return found;
}

/* Debian's GtkSourceView 5 package ships the schema without definitions.
 * Use the newest installed spec directory when the linked defaults have none. */
static gchar *host_language_directory(void) {
    static const char *const relatives[] = {
        "gtksourceview-5/language-specs",
        "libgedit-gtksourceview-300/language-specs",
        "gtksourceview-4/language-specs",
        "gtksourceview-3.0/language-specs",
        NULL
    };
    const char *const *data_dirs = g_get_system_data_dirs();
    for (size_t relative = 0; relatives[relative]; ++relative) {
        for (size_t dir = 0; data_dirs && data_dirs[dir]; ++dir) {
            gchar *path = g_build_filename(data_dirs[dir], relatives[relative], NULL);
            if (directory_has_languages(path)) return path;
            g_free(path);
        }
    }
    return NULL;
}
#endif

/* GtkTextView updates scrollbar adjustments during snapshot (GTK #6057), which
 * marks the scrollbar's GtkGizmo as needing allocation and then warns when that
 * gizmo is snapshotted in the same frame. Harmless; common on undo/scroll. */
static GLogWriterOutput cwhip_gtk_log_writer(GLogLevelFlags log_level,
                                             const GLogField *fields,
                                             gsize n_fields,
                                             gpointer user_data) {
    if ((log_level & G_LOG_LEVEL_WARNING) != 0) {
        const char *domain = NULL;
        const char *message = NULL;
        for (gsize i = 0; i < n_fields; ++i) {
            if (g_strcmp0(fields[i].key, "GLIB_DOMAIN") == 0)
                domain = fields[i].value;
            else if (g_strcmp0(fields[i].key, "MESSAGE") == 0)
                message = fields[i].value;
        }
        if (domain && message && g_strcmp0(domain, "Gtk") == 0 &&
            strstr(message, "Trying to snapshot") &&
            strstr(message, "without a current allocation")) {
            return G_LOG_WRITER_HANDLED;
        }
    }
    return g_log_writer_default(log_level, fields, n_fields, user_data);
}

static void application_initialize(const char *id, bool scheduler) {
    require_managed();
    if (initialized) fatal("application initialization is single-use");
    if (!gtk_init_check()) fatal("GTK initialization failed (display unavailable)");
    g_log_set_writer_func(cwhip_gtk_log_writer, NULL, NULL);
#ifdef CWHIP_GTK_SOURCEVIEW
    GtkSourceLanguageManager *defaults = gtk_source_language_manager_get_default();
    const char * const *existing_paths =
        gtk_source_language_manager_get_search_path(defaults);
    GPtrArray *paths = g_ptr_array_new();
    for (size_t i = 0; existing_paths && existing_paths[i]; ++i)
        g_ptr_array_add(paths, (gpointer)existing_paths[i]);
    bool defaults_have_languages = false;
    for (guint i = 0; i < paths->len; ++i) {
        if (directory_has_languages(paths->pdata[i])) defaults_have_languages = true;
    }
    gchar *host_languages = defaults_have_languages ? NULL : host_language_directory();
    if (host_languages) g_ptr_array_add(paths, host_languages);
    gchar *executable = g_file_read_link("/proc/self/exe", NULL);
    gchar *bin = executable ? g_path_get_dirname(executable) : NULL;
    gchar *languages = bin ? g_build_filename(bin, "..", "share", "cwhip",
        "modules", "sourceview", "0.1.0", "language-specs", NULL) : NULL;
    if (bin && !g_file_test(languages, G_FILE_TEST_IS_DIR)) {
        g_free(languages);
        languages = g_build_filename(bin, "share", "cwhip", "modules",
            "sourceview", "0.1.0", "language-specs", NULL);
    }
    if (languages && g_file_test(languages, G_FILE_TEST_IS_DIR))
        g_ptr_array_insert(paths, 0, languages);
    registered_languages = g_hash_table_new_full(g_str_hash, g_str_equal, g_free, NULL);
    for (guint i = 0; i < paths->len; ++i)
        register_languages(paths->pdata[i]);
    g_ptr_array_add(paths, NULL);
    source_language_manager = gtk_source_language_manager_new();
    gtk_source_language_manager_set_search_path(source_language_manager,
                                                 (const char **)paths->pdata);
    g_ptr_array_unref(paths);
    g_free(host_languages);
    g_free(languages);
    g_free(bin);
    g_free(executable);
#endif
    owner = pthread_self();
    initialized = true;
    main_context = g_main_context_ref(g_main_context_default());
    application = gtk_application_new(id, G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(application, "activate", G_CALLBACK(activation_started), NULL);
    g_signal_connect(application, "window-removed", G_CALLBACK(window_removed), NULL);
    if (scheduler) g_application_hold(G_APPLICATION(application));
    scheduler_hold = scheduler;
}

void cwhip_gtk_initialize(void *self) {
    (void)self;
    application_initialize("org.cwhip.Scheduler", true);
}

void cwhip_gtk_run(void *self) {
    (void)self;
    require_live();
    if (running) fatal("nested application run is not supported");
    if (ran) fatal("application run is single-use");
    ran = true;
    ++running;
    GtkApplication *run_application = g_object_ref(application);
    cwhip_runtime_gil_release();
    int status = g_application_run(G_APPLICATION(run_application), 0, NULL);
    cwhip_runtime_gil_acquire();
    --running;
    g_object_unref(run_application);
    if (status != 0) fatal("GtkApplication run failed");
    cwhip_gtk_shutdown(self);
}

void cwhip_gtk_quit(void *self) {
    (void)self;
    require_live();
    if (!running) fatal("quit requires a running application");
    g_application_quit(G_APPLICATION(application));
    g_main_context_wakeup(main_context);
}

static void post_remove(Post *post) {
    Post **link = &posts;
    while (*link != post) link = &(*link)->next;
    *link = post->next;
}

static gboolean dispatch(gpointer data) {
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    Post *post = data;
    post_remove(post);
    CwhipCallbackContext *context = cwhip_callback_transfer_accept(post->transfer);
    g_source_unref(post->source);
    free(post);
    typedef void (*Adapter)(CwhipCallbackContext *);
    ((Adapter)cwhip_callback_adapter(context))(context);
    cwhip_callback_release(context);
    cwhip_callback_dispose(context);
    cwhip_runtime_managed_leave(acquired);
    return G_SOURCE_REMOVE;
}

int64_t cwhip_gtk_post(void *self, void *callback) {
    (void)self;
    require_managed();
    if (!initialized || stopped) fatal("post requires a live application");
    Post *post = calloc(1, sizeof(*post));
    if (!post) fatal("allocation failed");
    post->token = token_new();
    post->transfer = cwhip_callback_transfer_prepare(callback, "callback<void()>");
    post->source = g_idle_source_new();
    post->next = posts;
    posts = post;
    g_source_set_callback(post->source, dispatch, post, NULL);
    if (!g_source_attach(post->source, main_context)) fatal("post attachment failed");
    return post->token;
}

int64_t cwhip_gtk_schedule(void *self, int64_t milliseconds, void *callback) {
    (void)self;
    require_managed();
    if (!initialized || stopped) fatal("schedule requires a live application");
    if (milliseconds < 0) milliseconds = 0;
    Post *post = calloc(1, sizeof(*post));
    if (!post) fatal("allocation failed");
    post->token = token_new();
    post->transfer = cwhip_callback_transfer_prepare(callback, "callback<void()>");
    post->source = g_timeout_source_new((guint)milliseconds);
    post->next = posts;
    posts = post;
    g_source_set_callback(post->source, dispatch, post, NULL);
    if (!g_source_attach(post->source, main_context)) fatal("schedule attachment failed");
    return post->token;
}

static void post_cancel(Post *post) {
    post_remove(post);
    g_source_destroy(post->source);
    g_source_unref(post->source);
    cwhip_callback_transfer_cancel(post->transfer);
    free(post);
}

bool cwhip_gtk_cancel(void *self, int64_t token) {
    (void)self;
    require_live();
    for (Post *post = posts; post; post = post->next) {
        if (post->token == token) {
            post_cancel(post);
            return true;
        }
    }
    return false;
}

void cwhip_gtk_shutdown(void *self) {
    (void)self;
    require_managed();
    cwhip_gtk_require_owner();
    if (stopped) return;
    stopped = true;
    g_application_quit(G_APPLICATION(application));
    while (posts) post_cancel(posts);
    while (dialogs) dialog_cancel(dialogs);
    for (Connection *connection = connections; connection;) {
        Connection *next = connection->next;
        if (!connection->closed) cwhip_gtk_disconnect(connection->token);
        connection = next;
    }
    for (WidgetRecord *record = widgets; record; record = record->next) {
        if (record->widget && GTK_IS_WINDOW(record->widget))
            gtk_window_set_focus(GTK_WINDOW(record->widget), NULL);
    }
    for (WidgetRecord *record = widgets; record; record = record->next)
        widget_dispose(record);
    config_finish_shutdown();
#ifdef CWHIP_GTK_SOURCEVIEW
    g_clear_object(&source_language_manager);
    g_clear_pointer(&registered_languages, g_hash_table_unref);
#endif
    while (widgets) {
        WidgetRecord *next = widgets->next;
        free(widgets);
        widgets = next;
    }
    if (scheduler_hold) {
        g_application_release(G_APPLICATION(application));
        scheduler_hold = false;
    }
    g_object_unref(application);
    application = NULL;
    g_main_context_wakeup(main_context);
    g_main_context_unref(main_context);
    /* The default context itself outlives this application and a currently
     * unwinding iteration. All package-owned sources are already destroyed. */
    main_context = NULL;
}

static char *text_copy(void *text) {
    if (!text) fatal("null text");
    const char *bytes;
    uint64_t length;
    cwhip_string_bytes(text, &bytes, &length);
    if (!length) bytes = "";
    if (length > G_MAXSSIZE || memchr(bytes, 0, length) ||
        !g_utf8_validate(bytes, (gssize)length, NULL))
        fatal("text must be UTF-8 without embedded NUL");
    return g_strndup(bytes, length);
}

void cwhip_gtk_application_create(void *self, void *id) {
    (void)self;
    require_managed();
    if (initialized) fatal("application initialization is single-use");
    char *name = text_copy(id);
    if (!g_application_id_is_valid(name)) fatal("invalid application ID");
    application_initialize(name, false);
    g_free(name);
}

int64_t cwhip_gtk_application_activate(void *self, void *callback) {
    (void)self;
    require_live();
    if (ran) fatal("activation handler must be installed before run");
    return connect_signal(G_OBJECT(application), "activate", G_CALLBACK(activate),
                          callback, "callback<void()>");
}

int64_t cwhip_gtk_activation_signal(void *self, void *source, void *callback) {
    if (!source) fatal("null signal source");
    return cwhip_gtk_application_activate(self, callback);
}

void *cwhip_gtk_application_id(void *self) {
    (void)self;
    require_live();
    const char *id = g_application_get_application_id(G_APPLICATION(application));
    return cwhip_string_new(&cwhip_string_class_meta, id, strlen(id));
}

bool cwhip_gtk_connected(void *self, int64_t token) {
    (void)self;
    require_managed();
    cwhip_gtk_require_owner();
    for (Connection *c = connections; c; c = c->next)
        if (c->token == token) return !c->closed;
    return false;
}

bool cwhip_gtk_connection_disconnect(void *self, int64_t token) {
    (void)self;
    return cwhip_gtk_disconnect(token);
}

static WidgetRecord *record_find(int64_t token) {
    require_managed();
    cwhip_gtk_require_owner();
    for (WidgetRecord *r = widgets; r; r = r->next)
        if (r->token == token) return r;
    fatal("invalid or disposed widget");
}

static GtkWidget *widget_live(int64_t token) {
    require_live();
    GtkWidget *widget = record_find(token)->widget;
    if (!widget) fatal("widget has been disposed");
    return widget;
}

#include "explorer.c"

static void disconnect_object(GObject *object) {
    for (Connection *c = connections; c;) {
        Connection *next = c->next;
        if (c->object == object && !c->closed) cwhip_gtk_disconnect(c->token);
        c = next;
    }
}

static void detach(WidgetRecord *r) {
    if (!r->parent) return;
    GtkWidget *parent = r->parent->widget;
    r->parent = NULL;
    if (GTK_IS_BOX(parent)) gtk_box_remove(GTK_BOX(parent), r->widget);
    else if (GTK_IS_GRID(parent)) gtk_grid_remove(GTK_GRID(parent), r->widget);
    else if (GTK_IS_POPOVER(r->widget)) gtk_widget_unparent(r->widget);
    else if (GTK_IS_POPOVER(parent)) gtk_popover_set_child(GTK_POPOVER(parent), NULL);
    else if (GTK_IS_WINDOW(parent)) gtk_window_set_child(GTK_WINDOW(parent), NULL);
    else if (GTK_IS_SCROLLED_WINDOW(parent))
        gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(parent), NULL);
    else if (GTK_IS_FRAME(parent))
        gtk_frame_set_child(GTK_FRAME(parent), NULL);
    else if (GTK_IS_EXPANDER(parent))
        gtk_expander_set_child(GTK_EXPANDER(parent), NULL);
    else if (GTK_IS_PANED(parent)) {
        if (gtk_paned_get_start_child(GTK_PANED(parent)) == r->widget)
            gtk_paned_set_start_child(GTK_PANED(parent), NULL);
        else gtk_paned_set_end_child(GTK_PANED(parent), NULL);
    }
    else if (GTK_IS_NOTEBOOK(parent)) {
        int page = gtk_notebook_page_num(GTK_NOTEBOOK(parent), r->widget);
        if (page >= 0) gtk_notebook_remove_page(GTK_NOTEBOOK(parent), page);
    }
    else fatal("invalid widget parent");
}

static void widget_dispose(WidgetRecord *r) {
    if (!r->widget) return;
    GtkWidget *widget = r->widget;
    if (GTK_IS_WINDOW(widget)) gtk_window_set_focus(GTK_WINDOW(widget), NULL);
    directory_cancel_owner(r->token);
    tree_stop(widget);
    for (FileDialog *dialog = dialogs; dialog;) {
        FileDialog *next = dialog->next;
        if (dialog->parent == r->token) dialog_cancel(dialog);
        dialog = next;
    }
    while (r->items) {
        MenuItem *item = r->items;
        r->items = item->next;
        cwhip_gtk_disconnect(item->token);
        g_object_unref(item->action);
        free(item);
    }
    if (r->actions) {
        gtk_widget_insert_action_group(widget, "menu", NULL);
        g_clear_object(&r->actions);
        g_clear_pointer(&r->submenus, g_ptr_array_unref);
        g_clear_object(&r->menu);
    }
    /* Scrollbar/Scale value-changed connections live on the GtkAdjustment. */
    if (GTK_IS_SCROLLBAR(widget))
        disconnect_object(G_OBJECT(gtk_scrollbar_get_adjustment(GTK_SCROLLBAR(widget))));
    if (GTK_IS_SCALE(widget))
        disconnect_object(G_OBJECT(gtk_range_get_adjustment(GTK_RANGE(widget))));
    disconnect_object(G_OBJECT(widget));
    GListModel *controllers = gtk_widget_observe_controllers(widget);
    for (guint i = 0; i < g_list_model_get_n_items(controllers); ++i) {
        GObject *controller = g_list_model_get_item(controllers, i);
        disconnect_object(controller);
        g_object_unref(controller);
    }
    g_object_unref(controllers);
    g_object_set_data(G_OBJECT(widget), "cwhip-tab-css", NULL);
#ifdef CWHIP_GTK_SOURCEVIEW
    if (GTK_SOURCE_IS_VIEW(widget))
        disconnect_object(G_OBJECT(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))));
    g_object_set_data(G_OBJECT(widget), "cwhip-font-provider", NULL);
#endif
    for (ShortcutBinding *binding = r->shortcuts; binding;) {
        ShortcutBinding *next = binding->next;
        shortcut_release(binding);
        binding->owner = NULL;
        binding = next;
    }
    r->shortcuts = NULL;
    for (WidgetRecord *child = widgets; child; child = child->next)
        if (child->parent == r) widget_dispose(child);
    detach(r);
    r->widget = NULL;
    g_signal_handlers_disconnect_by_data(widget, r);
    if (GTK_IS_WINDOW(widget) && !r->native_destroying)
        gtk_window_destroy(GTK_WINDOW(widget));
    g_object_unref(widget);
    cwhip_callback_release(r->root);
    cwhip_callback_dispose(r->root);
    r->root = NULL;
    r->receiver = NULL;
}

static void widget_destroyed(GtkWidget *widget, gpointer data) {
    (void)widget;
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    WidgetRecord *r = data;
    r->native_destroying = true;
    widget_dispose(r);
    cwhip_runtime_managed_leave(acquired);
}

static void window_removed(GtkApplication *app, GtkWindow *window, gpointer data) {
    (void)app;
    (void)data;
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    for (WidgetRecord *r = widgets; r; r = r->next) {
        if (r->widget != GTK_WIDGET(window)) continue;
        g_object_ref(window);
        r->native_destroying = true;
        widget_dispose(r);
        g_object_unref(window);
        break;
    }
    cwhip_runtime_managed_leave(acquired);
}

#ifdef CWHIP_GTK_SOURCEVIEW
typedef struct _CwhipSourceView {
    GtkSourceView parent_instance;
    bool indent_markers;
    bool show_spaces;
    bool show_line_ends;
    bool show_right_margin;
    int right_margin_column;
} CwhipSourceView;

typedef struct _CwhipSourceViewClass {
    GtkSourceViewClass parent_class;
} CwhipSourceViewClass;

G_DEFINE_TYPE(CwhipSourceView, cwhip_source_view, GTK_SOURCE_TYPE_VIEW)

static void cwhip_draw_indent_markers(GtkTextView *text_view, GtkSnapshot *snapshot) {
    CwhipSourceView *self = (CwhipSourceView *)text_view;
    if (!self->indent_markers) return;
    int tab = gtk_source_view_get_tab_width(GTK_SOURCE_VIEW(text_view));
    if (tab < 1) tab = 4;
    GdkRectangle visible;
    gtk_text_view_get_visible_rect(text_view, &visible);
    GtkTextIter line, end;
    gtk_text_view_get_line_at_y(text_view, &line, visible.y, NULL);
    gtk_text_view_get_line_at_y(text_view, &end, visible.y + visible.height, NULL);
    gtk_text_iter_set_line_offset(&line, 0);
    int last = gtk_text_iter_get_line(&end);
    GdkRGBA color;
    gtk_widget_get_color(GTK_WIDGET(text_view), &color);
    color.alpha = 0.35f;
    int guard = 0;
    while (gtk_text_iter_get_line(&line) <= last && guard < 100000) {
        ++guard;
        GtkTextIter scan = line;
        int indent = 0;
        while (!gtk_text_iter_ends_line(&scan)) {
            gunichar ch = gtk_text_iter_get_char(&scan);
            if (ch == ' ') indent += 1;
            else if (ch == '\t') indent += tab - (indent % tab);
            else break;
            if (!gtk_text_iter_forward_char(&scan)) break;
        }
        int levels = indent / tab;
        for (int level = 1; level <= levels; ++level) {
            int column = level * tab;
            GtkTextIter at = line;
            int visual = 0;
            while (visual < column && !gtk_text_iter_ends_line(&at)) {
                gunichar ch = gtk_text_iter_get_char(&at);
                int width = ch == '\t' ? tab - (visual % tab) : 1;
                if (visual + width > column) break;
                visual += width;
                if (!gtk_text_iter_forward_char(&at)) break;
            }
            GdkRectangle location;
            gtk_text_view_get_iter_location(text_view, &at, &location);
            graphene_rect_t rect = GRAPHENE_RECT_INIT(location.x, location.y, 1, location.height);
            gtk_snapshot_append_color(snapshot, &color, &rect);
        }
        if (!gtk_text_iter_forward_line(&line)) break;
    }
}

/* Draw a column guide even when the style scheme's right-margin color is
 * invisible or unset (common with plain/default schemes). */
static void cwhip_draw_right_margin(GtkTextView *text_view, GtkSnapshot *snapshot) {
    CwhipSourceView *self = (CwhipSourceView *)text_view;
    if (!self->show_right_margin || self->right_margin_column < 1) return;
    GdkRectangle visible;
    gtk_text_view_get_visible_rect(text_view, &visible);
    GtkTextIter line;
    gtk_text_view_get_line_at_y(text_view, &line, visible.y, NULL);
    gtk_text_iter_set_line_offset(&line, 0);
    int tab = gtk_source_view_get_tab_width(GTK_SOURCE_VIEW(text_view));
    if (tab < 1) tab = 4;
    GtkTextIter at = line;
    int visual = 0;
    int column = self->right_margin_column;
    while (visual < column && !gtk_text_iter_ends_line(&at)) {
        gunichar ch = gtk_text_iter_get_char(&at);
        int width = ch == '\t' ? tab - (visual % tab) : 1;
        if (visual + width > column) break;
        visual += width;
        if (!gtk_text_iter_forward_char(&at)) break;
    }
    GdkRectangle location;
    gtk_text_view_get_iter_location(text_view, &at, &location);
    /* When the line is shorter than the margin column, advance by average
     * character width from the line start. */
    int x = location.x;
    if (visual < column) {
        PangoLayout *layout = gtk_widget_create_pango_layout(GTK_WIDGET(text_view), "M");
        int char_width = 0, char_height = 0;
        pango_layout_get_pixel_size(layout, &char_width, &char_height);
        g_object_unref(layout);
        if (char_width < 1) char_width = 8;
        GtkTextIter start = line;
        GdkRectangle origin;
        gtk_text_view_get_iter_location(text_view, &start, &origin);
        x = origin.x + column * char_width;
    }
    GdkRGBA color;
    gtk_widget_get_color(GTK_WIDGET(text_view), &color);
    color.alpha = 0.45f;
    graphene_rect_t rect = GRAPHENE_RECT_INIT((float)x, (float)visible.y, 1.0f,
                                              (float)visible.height);
    gtk_snapshot_append_color(snapshot, &color, &rect);
}

static void cwhip_source_view_snapshot_layer(GtkTextView *text_view, GtkTextViewLayer layer,
                                            GtkSnapshot *snapshot) {
    GtkTextViewClass *parent = GTK_TEXT_VIEW_CLASS(cwhip_source_view_parent_class);
    if (parent->snapshot_layer) parent->snapshot_layer(text_view, layer, snapshot);
    /* Skip overlays until the view has an allocation; drawing against a zero
     * size can race with scrollbar GtkGizmo snapshot during first layout. */
    if (gtk_widget_get_width(GTK_WIDGET(text_view)) <= 0 ||
        gtk_widget_get_height(GTK_WIDGET(text_view)) <= 0) {
        return;
    }
    if (layer == GTK_TEXT_VIEW_LAYER_BELOW_TEXT) {
        cwhip_draw_indent_markers(text_view, snapshot);
        cwhip_draw_right_margin(text_view, snapshot);
    }
}

static void cwhip_source_view_class_init(CwhipSourceViewClass *klass) {
    GTK_TEXT_VIEW_CLASS(klass)->snapshot_layer = cwhip_source_view_snapshot_layer;
}

static void cwhip_source_view_init(CwhipSourceView *self) {
    self->indent_markers = false;
    self->show_spaces = false;
    self->show_line_ends = false;
    self->show_right_margin = false;
    self->right_margin_column = 80;
}
#endif

int64_t cwhip_gtk_widget_create(void *self, int64_t kind, void *text,
                               int64_t orientation, int64_t spacing, void *keep_alive) {
    require_live();
    if (!activated || g_application_get_is_remote(G_APPLICATION(application)))
        fatal("widgets must be created during or after local activation");
    void *receiver = cwhip_gc_root(self);
    const CwhipClassMeta *metadata = *(const CwhipClassMeta *const *)receiver;
    unsigned widget_bases = 0;
    for (uint64_t i = 0; i < metadata->base_class_count; ++i) {
        const CwhipClassName *base = &metadata->base_classes[i];
        if (base->name_length == sizeof("Gtk.Widget") - 1 &&
            memcmp(base->name, "Gtk.Widget", sizeof("Gtk.Widget") - 1) == 0 &&
            ++widget_bases > 1)
            fatal("multiple Widget bases in one managed object are not supported");
    }
    if (orientation < 0 || orientation > 1 || spacing < 0 || spacing > G_MAXINT)
        fatal("invalid layout orientation or spacing");
    char *label = text_copy(text);
    GtkWidget *widget = NULL;
    switch (kind) {
    case 1: widget = gtk_application_window_new(application);
        gtk_window_set_title(GTK_WINDOW(widget), label); break;
    case 11: widget = gtk_window_new();
        gtk_window_set_title(GTK_WINDOW(widget), label); break;
    case 2: widget = gtk_box_new((GtkOrientation)orientation, (int)spacing); break;
    case 3: widget = gtk_label_new(label); break;
    case 4:
        widget = gtk_button_new_with_label(label);
        /* Toolbar-style clicks should activate without stealing focus from an
         * editor; otherwise the first press often only focuses the button. */
        gtk_widget_set_focus_on_click(widget, FALSE);
        break;
    case 5: widget = gtk_entry_new();
        gtk_editable_set_text(GTK_EDITABLE(widget), label); break;
    case 6: widget = gtk_check_button_new_with_label(label); break;
    case 7: widget = gtk_scrolled_window_new(); break;
    case 12: widget = gtk_paned_new((GtkOrientation)orientation);
        /* Start child keeps its size on window resize and cannot collapse
         * past its minimum. End child may shrink so the start can grow.
         * orientation 0 = horizontal (left|right), 1 = vertical (top/bottom). */
        gtk_paned_set_resize_start_child(GTK_PANED(widget), FALSE);
        gtk_paned_set_shrink_start_child(GTK_PANED(widget), FALSE);
        gtk_paned_set_shrink_end_child(GTK_PANED(widget), TRUE);
        break;
    case 13: widget = gtk_list_view_new(NULL, NULL);
        gtk_list_view_set_single_click_activate(GTK_LIST_VIEW(widget), FALSE);
        break;
    case 14: widget = gtk_grid_new();
        gtk_grid_set_row_spacing(GTK_GRID(widget), (guint)spacing);
        gtk_grid_set_column_spacing(GTK_GRID(widget), (guint)spacing);
        break;
    case 15: {
        GMenu *menu = g_menu_new();
        widget = gtk_popover_menu_new_from_model(G_MENU_MODEL(menu));
        g_object_unref(menu);
        break;
    }
    case 16: widget = gtk_drawing_area_new(); break;
    case 17: widget = gtk_scrollbar_new((GtkOrientation)orientation, NULL); break;
    case 18:
        /* Default 0..1 step 0.1 until Scale.configure(); matches
         * gtk_scale_new_with_range page = step*10 convention. */
        widget = gtk_scale_new_with_range((GtkOrientation)orientation, 0.0, 1.0, 0.1);
        break;
    case 19:
        /* ProgressBar defaults: fraction 0, no overlay text, pulse step 0.1. */
        widget = gtk_progress_bar_new();
        gtk_orientable_set_orientation(GTK_ORIENTABLE(widget), (GtkOrientation)orientation);
        break;
    case 20:
        /* SpinButton default 0..100 step 1 until SpinButton.configure(). */
        widget = gtk_spin_button_new_with_range(0.0, 100.0, 1.0);
        break;
    case 21: {
        /* Empty DropDown backed by a mutable GtkStringList model. */
        GtkStringList *strings = gtk_string_list_new(NULL);
        widget = gtk_drop_down_new(G_LIST_MODEL(strings), NULL);
        break;
    }
    case 22: widget = gtk_frame_new(label[0] ? label : NULL); break;
    case 23: widget = gtk_expander_new(label[0] ? label : NULL); break;
    case 24: widget = gtk_separator_new((GtkOrientation)orientation); break;
    case 25:
        widget = gtk_text_view_new();
        gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(widget), GTK_WRAP_WORD_CHAR);
        gtk_text_view_set_editable(GTK_TEXT_VIEW(widget), TRUE);
        gtk_text_view_set_cursor_visible(GTK_TEXT_VIEW(widget), TRUE);
        break;
    case 9: widget = gtk_notebook_new(); break;
    case 10: {
        GMenu *menu = g_menu_new();
        widget = gtk_popover_menu_bar_new_from_model(G_MENU_MODEL(menu));
        g_object_unref(menu);
        break;
    }
#ifdef CWHIP_GTK_SOURCEVIEW
    case 8:
        widget = GTK_WIDGET(g_object_new(cwhip_source_view_get_type(), NULL));
        gtk_text_buffer_set_enable_undo(
            gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), TRUE);
        break;
#endif
    default: fatal("invalid widget kind");
    }
    g_free(label);
    WidgetRecord *r = calloc(1, sizeof(*r));
    if (!r) fatal("allocation failed");
    r->token = token_new();
    /* Windows are already non-floating and GTK owns a reference. */
    r->widget = g_object_ref_sink(widget);
    r->receiver = receiver;
    r->root = cwhip_callback_acquire(keep_alive, "callback<void()>");
    if (kind == 10 || kind == 15) {
        r->menu = G_MENU(g_object_ref(kind == 10
            ? gtk_popover_menu_bar_get_menu_model(GTK_POPOVER_MENU_BAR(widget))
            : gtk_popover_menu_get_menu_model(GTK_POPOVER_MENU(widget))));
        r->submenus = g_ptr_array_new_with_free_func(g_object_unref);
        r->actions = g_simple_action_group_new();
        gtk_widget_insert_action_group(widget, "menu", G_ACTION_GROUP(r->actions));
        g_object_set_data(G_OBJECT(widget), "cwhip-actions", r->actions);
        if (kind == 15) {
            g_ptr_array_add(r->submenus, g_object_ref(r->menu));
            g_object_set_data(G_OBJECT(r->menu), "cwhip-menu-parent", r->menu);
        }
    }
    r->next = widgets;
    widgets = r;
    if (kind == 16) {
        /* Track pointer position so scroll callbacks can report zoom focus. */
        GtkEventController *motion = gtk_event_controller_motion_new();
        g_signal_connect(motion, "enter", G_CALLBACK(drawing_area_pointer_enter), r);
        g_signal_connect(motion, "leave", G_CALLBACK(drawing_area_pointer_leave), r);
        g_signal_connect(motion, "motion", G_CALLBACK(drawing_area_pointer_motion), r);
        gtk_widget_add_controller(widget, motion);
    }
    g_signal_connect(widget, "destroy", G_CALLBACK(widget_destroyed), r);
    return r->token;
}

void cwhip_gtk_widget_dispose(void *self, int64_t token) {
    (void)self;
    require_managed();
    cwhip_gtk_require_owner();
    if (stopped) return;
    widget_dispose(record_find(token));
}

bool cwhip_gtk_widget_disposed(void *self, int64_t token) {
    (void)self;
    require_managed();
    cwhip_gtk_require_owner();
    return stopped || !record_find(token)->widget;
}

void cwhip_gtk_widget_visible(void *self, int64_t token, bool value) {
    (void)self;
    gtk_widget_set_visible(widget_live(token), value);
}

bool cwhip_gtk_widget_is_visible(void *self, int64_t token) {
    (void)self;
    return gtk_widget_get_visible(widget_live(token));
}

void cwhip_gtk_widget_sensitive(void *self, int64_t token, bool value) {
    (void)self;
    GtkWidget *w = widget_live(token);
    if (gtk_widget_get_sensitive(w) != (gboolean)value)
        gtk_widget_set_sensitive(w, value);
}

void cwhip_gtk_widget_expand(void *self, int64_t token, bool horizontal, bool value) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (horizontal) gtk_widget_set_hexpand(widget, value);
    else gtk_widget_set_vexpand(widget, value);
}

void cwhip_gtk_widget_width_request(void *self, int64_t token, int64_t width) {
    (void)self;
    if (width < 0 || width > G_MAXINT) fatal("width request must be a nonnegative GTK integer");
    GtkWidget *widget = widget_live(token);
    int current_height = -1;
    gtk_widget_get_size_request(widget, NULL, &current_height);
    gtk_widget_set_size_request(widget, (int)width, current_height);
}

void cwhip_gtk_widget_css_class(void *self, int64_t token, void *name_text, bool add) {
    (void)self;
    char *name = text_copy(name_text);
    if (!*name) fatal("CSS class name must be nonempty");
    GtkWidget *widget = widget_live(token);
    if (add) gtk_widget_add_css_class(widget, name);
    else gtk_widget_remove_css_class(widget, name);
    g_free(name);
}

void cwhip_gtk_widget_tooltip(void *self, int64_t token, void *text) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    char *tooltip = text_copy(text);
    gtk_widget_set_tooltip_text(widget, *tooltip ? tooltip : NULL);
    g_free(tooltip);
}

void cwhip_gtk_button_icon(void *self, int64_t token, void *icon_text) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_BUTTON(widget)) fatal("operation requires Button");
    char *icon = text_copy(icon_text);
    if (!*icon) fatal("icon name must be nonempty");
    gtk_button_set_icon_name(GTK_BUTTON(widget), icon);
    g_free(icon);
}

void cwhip_gtk_widget_focus(void *self, int64_t token) {
    (void)self;
    gtk_widget_grab_focus(widget_live(token));
}

void cwhip_gtk_widget_focus_on_click(void *self, int64_t token, bool enabled) {
    (void)self;
    gtk_widget_set_focus_on_click(widget_live(token), enabled);
}

void cwhip_gtk_widget_can_focus(void *self, int64_t token, bool enabled) {
    (void)self;
    gtk_widget_set_can_focus(widget_live(token), enabled);
}

static WidgetRecord *menu_record(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_POPOVER_MENU_BAR(widget) && !GTK_IS_POPOVER_MENU(widget))
        fatal("operation requires MenuBar or ContextMenu");
    return record_find(token);
}

int64_t cwhip_gtk_menu_add(void *self, int64_t token, void *label) {
    (void)self;
    WidgetRecord *record = menu_record(token);
    char *text = text_copy(label);
    GMenu *menu = g_menu_new();
    GMenu *section = g_menu_new();
    g_menu_append_section(menu, NULL, G_MENU_MODEL(section));
    /* Borrowed: the menubar model owns the submenu for the record's lifetime. */
    g_object_set_data(G_OBJECT(section), "cwhip-menu-parent", menu);
    int64_t index = record->submenus->len;
    /* Items append to the submenu's current section; a separator starts a
     * new section, which GTK renders with a dividing line. */
    g_ptr_array_add(record->submenus, section);
    g_menu_append_submenu(record->menu, text, G_MENU_MODEL(menu));
    g_object_unref(menu);
    g_free(text);
    return index;
}

void cwhip_gtk_menu_separator_add(void *self, int64_t token, int64_t menu) {
    (void)self;
    WidgetRecord *record = menu_record(token);
    if (menu < 0 || menu >= record->submenus->len) fatal("invalid menu index");
    GMenu *current = g_ptr_array_index(record->submenus, (guint)menu);
    GMenu *parent = g_object_get_data(G_OBJECT(current), "cwhip-menu-parent");
    GMenu *section = g_menu_new();
    g_menu_append_section(parent, NULL, G_MENU_MODEL(section));
    g_object_set_data(G_OBJECT(section), "cwhip-menu-parent", parent);
    record->submenus->pdata[menu] = section;
    g_object_unref(current);
}

static void menu_activated(GSimpleAction *action, GVariant *parameter, gpointer data) {
    (void)action;
    (void)parameter;
    clicked(NULL, data);
}

static void menu_check_changed(GSimpleAction *action, GVariant *value, gpointer data) {
    bool state = g_variant_get_boolean(value);
    g_simple_action_set_state(action, value);
    MenuItem *item = g_object_get_data(G_OBJECT(action), "cwhip-menu-item");
    if (item && item->syncing) return;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, bool);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context, state);
    signal_leave(connection, acquired);
}

int64_t cwhip_gtk_menu_item_add(void *self, int64_t token, int64_t menu,
                               void *label, void *callback) {
    (void)self;
    WidgetRecord *record = menu_record(token);
    if (menu < 0 || menu >= record->submenus->len) fatal("invalid menu index");
    char *text = text_copy(label);
    MenuItem *item = calloc(1, sizeof(*item));
    if (!item) fatal("allocation failed");
    char *name = g_strdup_printf("item%" G_GINT64_FORMAT, token_new());
    item->menu = menu;
    item->action = g_simple_action_new(name, NULL);
    item->token = connect_signal(G_OBJECT(item->action), "activate",
                                G_CALLBACK(menu_activated), callback, "callback<void()>");
    g_action_map_add_action(G_ACTION_MAP(record->actions), G_ACTION(item->action));
    char *detailed = g_strconcat("menu.", name, NULL);
    g_menu_append(g_ptr_array_index(record->submenus, (guint)menu), text, detailed);
    g_free(detailed);
    g_free(name);
    g_free(text);
    item->next = record->items;
    record->items = item;
    return item->token;
}

static MenuItem *menu_item(int64_t token, int64_t item) {
    for (MenuItem *i = menu_record(token)->items; i; i = i->next)
        if (i->token == item) return i;
    fatal("invalid menu item");
}

int64_t cwhip_gtk_menu_check_add(void *self, int64_t token, int64_t menu,
                                 void *label, bool initial, void *callback) {
    (void)self;
    WidgetRecord *record = menu_record(token);
    if (menu < 0 || menu >= record->submenus->len) fatal("invalid menu index");
    char *text = text_copy(label);
    MenuItem *item = calloc(1, sizeof(*item));
    if (!item) fatal("allocation failed");
    char *name = g_strdup_printf("item%" G_GINT64_FORMAT, token_new());
    item->menu = menu;
    item->check = true;
    item->action = g_simple_action_new_stateful(name, NULL, g_variant_new_boolean(initial));
    g_object_set_data(G_OBJECT(item->action), "cwhip-menu-item", item);
    item->token = connect_signal(G_OBJECT(item->action), "change-state",
                                 G_CALLBACK(menu_check_changed), callback, "callback<void(bool)>");
    g_action_map_add_action(G_ACTION_MAP(record->actions), G_ACTION(item->action));
    char *detailed = g_strconcat("menu.", name, NULL);
    g_menu_append(g_ptr_array_index(record->submenus, (guint)menu), text, detailed);
    g_free(detailed);
    g_free(name);
    g_free(text);
    item->next = record->items;
    record->items = item;
    return item->token;
}

int64_t cwhip_gtk_menu_submenu_add(void *self, int64_t token, int64_t menu, void *label) {
    (void)self;
    WidgetRecord *record = menu_record(token);
    if (menu < 0 || menu >= record->submenus->len) fatal("invalid menu index");
    char *text = text_copy(label);
    GMenu *submenu = g_menu_new();
    GMenu *section = g_menu_new();
    g_menu_append_section(submenu, NULL, G_MENU_MODEL(section));
    g_object_set_data(G_OBJECT(section), "cwhip-menu-parent", submenu);
    int64_t index = record->submenus->len;
    g_ptr_array_add(record->submenus, section);
    g_menu_append_submenu(g_ptr_array_index(record->submenus, (guint)menu), text,
                          G_MENU_MODEL(submenu));
    g_object_unref(submenu);
    g_free(text);
    return index;
}

void cwhip_gtk_menu_clear(void *self, int64_t token, int64_t menu) {
    (void)self;
    WidgetRecord *record = menu_record(token);
    if (menu < 0 || menu >= record->submenus->len) fatal("invalid menu index");
    GMenu *current = g_ptr_array_index(record->submenus, (guint)menu);
    GMenu *parent = g_object_get_data(G_OBJECT(current), "cwhip-menu-parent");
    if (!parent) fatal("cannot clear top-level menubar model");
    g_menu_remove_all(current);
    MenuItem **link = &record->items;
    while (*link) {
        MenuItem *item = *link;
        if (item->menu != menu) {
            link = &item->next;
            continue;
        }
        *link = item->next;
        const char *name = g_action_get_name(G_ACTION(item->action));
        if (name) g_action_map_remove_action(G_ACTION_MAP(record->actions), name);
        cwhip_gtk_disconnect(item->token);
        g_object_unref(item->action);
        free(item);
    }
}

void cwhip_gtk_menu_item_enabled(void *self, int64_t token, int64_t item, bool enabled) {
    (void)self;
    GSimpleAction *action = menu_item(token, item)->action;
    if (g_action_get_enabled(G_ACTION(action)) != (gboolean)enabled)
        g_simple_action_set_enabled(action, enabled);
}

void cwhip_gtk_menu_item_activate(void *self, int64_t token, int64_t item) {
    (void)self;
    MenuItem *entry = menu_item(token, item);
    GSimpleAction *action = g_object_ref(entry->action);
    if (g_action_get_enabled(G_ACTION(action))) {
        if (entry->check) {
            GVariant *state = g_action_get_state(G_ACTION(action));
            bool next = !g_variant_get_boolean(state);
            g_variant_unref(state);
            g_action_change_state(G_ACTION(action), g_variant_new_boolean(next));
        } else {
            g_action_activate(G_ACTION(action), NULL);
        }
    }
    g_object_unref(action);
}

void cwhip_gtk_menu_item_set_checked(void *self, int64_t token, int64_t item, bool checked) {
    (void)self;
    MenuItem *entry = menu_item(token, item);
    if (!entry->check) fatal("menu item is not a check item");
    GVariant *state = g_action_get_state(G_ACTION(entry->action));
    bool current = g_variant_get_boolean(state);
    g_variant_unref(state);
    if (current == checked) return;
    entry->syncing = true;
    g_action_change_state(G_ACTION(entry->action), g_variant_new_boolean(checked));
    entry->syncing = false;
}

bool cwhip_gtk_menu_item_checked(void *self, int64_t token, int64_t item) {
    (void)self;
    MenuItem *entry = menu_item(token, item);
    if (!entry->check) fatal("menu item is not a check item");
    GVariant *state = g_action_get_state(G_ACTION(entry->action));
    bool checked = g_variant_get_boolean(state);
    g_variant_unref(state);
    return checked;
}

static void *path_string(const char *path) {
    return cwhip_string_new(&cwhip_string_class_meta, path, strlen(path));
}

/* Remove all native ownership before invoking Cwhip: a result handler may
 * immediately dispose its parent, open another chooser, or shut down. A
 * single-file chooser delivers one path ("" when cancelled); a multi-select
 * chooser delivers each selected path and then "" to end the batch. */
static void dialog_unlink(FileDialog *dialog) {
    FileDialog **link = &dialogs;
    while (*link && *link != dialog) link = &(*link)->next;
    if (*link) *link = dialog->next;
    dialog->next = NULL;
}

static void dialog_finish(FileDialog *dialog, bool invoke) {
    GPtrArray *paths = dialog->paths;
    bool multiple = dialog->multiple;
    dialog_unlink(dialog);
    if (dialog->completion) {
        g_source_destroy(dialog->completion);
        g_source_unref(dialog->completion);
    }
    g_clear_object(&dialog->cancellable);
    g_clear_object(&dialog->chooser);
    CwhipCallbackContext *context = dialog->context;
    free(dialog);
    if (invoke && context) {
        typedef void (*Adapter)(CwhipCallbackContext *, void *);
        Adapter adapter = (Adapter)cwhip_callback_adapter(context);
        guint deliveries = multiple ? paths->len + 1 : 1;
        for (guint i = 0; i < deliveries; ++i) {
            void *text = path_string(i < paths->len ? g_ptr_array_index(paths, i) : "");
            void *slots[] = { &text };
            CwhipRootFrame frame = {0};
            cwhip_gc_push_or_abort(&frame, slots, 1);
            adapter(context, text);
            cwhip_gc_pop_or_abort(&frame);
        }
    }
    g_ptr_array_unref(paths);
    if (context) {
        cwhip_callback_release(context);
        cwhip_callback_dispose(context);
    }
}

static gboolean dialog_complete(gpointer data) {
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    FileDialog *dialog = data;
    g_source_unref(dialog->completion);
    dialog->completion = NULL;
    dialog_finish(dialog, true);
    cwhip_runtime_managed_leave(acquired);
    return G_SOURCE_REMOVE;
}

static void dialog_schedule(FileDialog *dialog) {
    if (dialog->completion) return;
    dialog->completion = g_idle_source_new();
    g_source_set_callback(dialog->completion, dialog_complete, dialog, NULL);
    g_source_attach(dialog->completion, main_context);
}

static void dialog_append_file(FileDialog *dialog, GFile *file) {
    char *path = g_file_get_path(file);
    /* Cwhip strings are UTF-8; fall back to the (ASCII) URI otherwise. */
    if (!path || !g_utf8_validate(path, -1, NULL)) {
        g_free(path);
        path = g_file_get_uri(file);
    }
    g_ptr_array_add(dialog->paths, path);
}

static void file_dialog_completed(GObject *source, GAsyncResult *result, gpointer data) {
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    FileDialog *dialog = data;
    dialog->request_pending = false;
    GError *error = NULL;
    if (dialog->multiple) {
        GListModel *files = gtk_file_dialog_open_multiple_finish(
            GTK_FILE_DIALOG(source), result, &error);
        for (guint i = 0; files && i < g_list_model_get_n_items(files); ++i) {
            GFile *file = g_list_model_get_item(files, i);
            dialog_append_file(dialog, file);
            g_object_unref(file);
        }
        g_clear_object(&files);
    } else {
        GFile *file;
        if (dialog->folder)
            file = gtk_file_dialog_select_folder_finish(GTK_FILE_DIALOG(source), result, &error);
        else if (dialog->save)
            file = gtk_file_dialog_save_finish(GTK_FILE_DIALOG(source), result, &error);
        else
            file = gtk_file_dialog_open_finish(GTK_FILE_DIALOG(source), result, &error);
        if (file) {
            dialog_append_file(dialog, file);
            g_object_unref(file);
        }
    }
    if (error) {
        if (!g_error_matches(error, G_IO_ERROR, G_IO_ERROR_CANCELLED) &&
            !g_error_matches(error, GTK_DIALOG_ERROR, GTK_DIALOG_ERROR_CANCELLED) &&
            !g_error_matches(error, GTK_DIALOG_ERROR, GTK_DIALOG_ERROR_DISMISSED))
            g_warning("File chooser failed: %s", error->message);
        g_error_free(error);
    }
    if (dialog->cancelled) dialog_finish(dialog, false);
    else dialog_schedule(dialog);
    cwhip_runtime_managed_leave(acquired);
}

static void dialog_cancel(FileDialog *dialog) {
    dialog->cancelled = true;
    dialog_unlink(dialog);
    cwhip_callback_release(dialog->context);
    cwhip_callback_dispose(dialog->context);
    dialog->context = NULL;
    /* GTask still owns the completion's data until its callback arrives. */
    if (dialog->request_pending) g_cancellable_cancel(dialog->cancellable);
    else dialog_finish(dialog, false);
}

static int64_t file_dialog_create(int64_t parent, bool save, bool multiple, bool folder,
                                  void *initial_path, void *callback) {
    GtkWidget *window = widget_live(parent);
    if (!GTK_IS_WINDOW(window)) fatal("FileDialog requires Window");
    char *path = text_copy(initial_path);
    FileDialog *dialog = calloc(1, sizeof(*dialog));
    if (!dialog) fatal("allocation failed");
    dialog->token = token_new();
    dialog->parent = parent;
    dialog->multiple = multiple;
    dialog->save = save;
    dialog->folder = folder;
    dialog->paths = g_ptr_array_new_with_free_func(g_free);
    dialog->context = cwhip_callback_acquire(callback, "callback<void(String)>");
    dialog->chooser = gtk_file_dialog_new();
    dialog->cancellable = g_cancellable_new();
    gtk_file_dialog_set_title(dialog->chooser,
                              folder ? "Open folder" : save ? "Save file" : "Open file");
    gtk_file_dialog_set_modal(dialog->chooser, TRUE);
    gtk_file_dialog_set_accept_label(dialog->chooser, save ? "Save" : "Open");
    if (*path) {
        GFile *file = g_file_new_for_path(path);
        if (g_file_test(path, G_FILE_TEST_IS_DIR))
            gtk_file_dialog_set_initial_folder(dialog->chooser, file);
        else if (save) {
            GFile *folder = g_file_get_parent(file);
            if (folder) {
                gtk_file_dialog_set_initial_folder(dialog->chooser, folder);
                g_object_unref(folder);
            }
            char *name = g_file_get_basename(file);
            gtk_file_dialog_set_initial_name(dialog->chooser, name);
            g_free(name);
        } else if (multiple || dialog->folder) {
            GFile *folder = g_file_get_parent(file);
            if (folder) {
                gtk_file_dialog_set_initial_folder(dialog->chooser, folder);
                g_object_unref(folder);
            }
        } else gtk_file_dialog_set_initial_file(dialog->chooser, file);
        g_object_unref(file);
    }
    g_free(path);
    dialog->next = dialogs;
    dialogs = dialog;
    int64_t token = dialog->token;
    dialog->request_pending = true;
    if (folder)
        gtk_file_dialog_select_folder(dialog->chooser, GTK_WINDOW(window),
                                      dialog->cancellable, file_dialog_completed, dialog);
    else if (multiple)
        gtk_file_dialog_open_multiple(dialog->chooser, GTK_WINDOW(window),
                                      dialog->cancellable, file_dialog_completed, dialog);
    else if (save)
        gtk_file_dialog_save(dialog->chooser, GTK_WINDOW(window),
                             dialog->cancellable, file_dialog_completed, dialog);
    else
        gtk_file_dialog_open(dialog->chooser, GTK_WINDOW(window),
                             dialog->cancellable, file_dialog_completed, dialog);
    return token;
}

int64_t cwhip_gtk_file_dialog_create(void *self, int64_t parent, bool save,
                                    void *initial_path, void *callback) {
    (void)self;
    return file_dialog_create(parent, save, false, false, initial_path, callback);
}

int64_t cwhip_gtk_file_dialog_create_multiple(void *self, int64_t parent, void *initial_path,
                                             void *callback) {
    (void)self;
    return file_dialog_create(parent, false, true, false, initial_path, callback);
}

int64_t cwhip_gtk_file_dialog_create_folder(void *self, int64_t parent, void *initial_path,
                                          void *callback) {
    (void)self;
    return file_dialog_create(parent, false, false, true, initial_path, callback);
}

/* GtkAlertDialog owns its window: it is modal, transient for the parent, and
 * destroys itself when dismissed or when the parent is destroyed. */
void cwhip_gtk_alert_show(void *self, int64_t parent, void *message, void *detail) {
    (void)self;
    require_managed();
    cwhip_gtk_require_owner();
    GtkWidget *window = widget_live(parent);
    if (!GTK_IS_WINDOW(window)) fatal("AlertDialog requires Window");
    char *heading = text_copy(message);
    char *body = text_copy(detail);
    GtkAlertDialog *alert = gtk_alert_dialog_new("%s", heading);
    if (*body) gtk_alert_dialog_set_detail(alert, body);
    gtk_alert_dialog_set_modal(alert, TRUE);
    gtk_alert_dialog_show(alert, GTK_WINDOW(window));
    g_object_unref(alert);
    g_free(body);
    g_free(heading);
}

void cwhip_gtk_file_dialog_cancel(void *self, int64_t token) {
    (void)self;
    require_managed();
    cwhip_gtk_require_owner();
    for (FileDialog *dialog = dialogs; dialog; dialog = dialog->next)
        if (dialog->token == token) {
            dialog_cancel(dialog);
            return;
        }
}

bool cwhip_gtk_file_dialog_pending(void *self, int64_t token) {
    (void)self;
    require_managed();
    cwhip_gtk_require_owner();
    for (FileDialog *dialog = dialogs; dialog; dialog = dialog->next)
        if (dialog->token == token) return true;
    return false;
}

void cwhip_gtk_widget_text_set(void *self, int64_t token, void *text) {
    (void)self;
    GtkWidget *w = g_object_ref(widget_live(token));
    char *label = text_copy(text);
    if (GTK_IS_WINDOW(w)) gtk_window_set_title(GTK_WINDOW(w), label);
    else if (GTK_IS_LABEL(w)) {
        if (g_strcmp0(gtk_label_get_text(GTK_LABEL(w)), label) != 0)
            gtk_label_set_text(GTK_LABEL(w), label);
    }
    else if (GTK_IS_BUTTON(w)) gtk_button_set_label(GTK_BUTTON(w), label);
    else if (GTK_IS_EDITABLE(w)) gtk_editable_set_text(GTK_EDITABLE(w), label);
    else if (GTK_IS_CHECK_BUTTON(w)) gtk_check_button_set_label(GTK_CHECK_BUTTON(w), label);
    else fatal("widget has no text property");
    g_free(label);
    g_object_unref(w);
}

void *cwhip_gtk_widget_text_get(void *self, int64_t token) {
    (void)self;
    GtkWidget *w = widget_live(token);
    const char *text;
    if (GTK_IS_WINDOW(w)) text = gtk_window_get_title(GTK_WINDOW(w));
    else if (GTK_IS_LABEL(w)) text = gtk_label_get_text(GTK_LABEL(w));
    else if (GTK_IS_BUTTON(w)) text = gtk_button_get_label(GTK_BUTTON(w));
    else if (GTK_IS_EDITABLE(w)) text = gtk_editable_get_text(GTK_EDITABLE(w));
    else if (GTK_IS_CHECK_BUTTON(w)) text = gtk_check_button_get_label(GTK_CHECK_BUTTON(w));
    else fatal("widget has no text property");
    if (!text) text = "";
    return cwhip_string_new(&cwhip_string_class_meta, text, strlen(text));
}

void cwhip_gtk_scrolled_window_set_policy(void *self, int64_t token, int64_t horizontal,
                                          int64_t vertical) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SCROLLED_WINDOW(widget)) fatal("operation requires GtkScrolledWindow");
    if (horizontal < GTK_POLICY_ALWAYS || horizontal > GTK_POLICY_EXTERNAL ||
        vertical < GTK_POLICY_ALWAYS || vertical > GTK_POLICY_EXTERNAL) {
        fatal("invalid scrolled window policy");
    }
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(widget), (GtkPolicyType)horizontal,
                                   (GtkPolicyType)vertical);
}

void cwhip_gtk_scrolled_window_set_overlay_scrolling(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SCROLLED_WINDOW(widget)) fatal("operation requires GtkScrolledWindow");
    gtk_scrolled_window_set_overlay_scrolling(GTK_SCROLLED_WINDOW(widget), enabled);
}

void cwhip_gtk_widget_attach(void *self, int64_t parent, int64_t child) {
    (void)self;
    GtkWidget *p = widget_live(parent);
    GtkWidget *c = widget_live(child);
    WidgetRecord *pr = record_find(parent), *cr = record_find(child);
    if (GTK_IS_WINDOW(c) || pr == cr || cr->parent || gtk_widget_get_parent(c))
        fatal("child is a window, already parented, or self");
    for (WidgetRecord *r = pr; r; r = r->parent)
        if (r == cr) fatal("parenting cycle");
    if (GTK_IS_BOX(p)) gtk_box_append(GTK_BOX(p), c);
    else if (GTK_IS_POPOVER(p)) {
        if (gtk_popover_get_child(GTK_POPOVER(p))) fatal("container already has a child");
        gtk_popover_set_child(GTK_POPOVER(p), c);
    }
    else if (GTK_IS_WINDOW(p)) {
        if (gtk_window_get_child(GTK_WINDOW(p))) fatal("container already has a child");
        gtk_window_set_child(GTK_WINDOW(p), c);
    } else if (GTK_IS_SCROLLED_WINDOW(p)) {
        if (gtk_scrolled_window_get_child(GTK_SCROLLED_WINDOW(p)))
            fatal("container already has a child");
        gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(p), c);
    } else if (GTK_IS_FRAME(p)) {
        if (gtk_frame_get_child(GTK_FRAME(p))) fatal("container already has a child");
        gtk_frame_set_child(GTK_FRAME(p), c);
    } else if (GTK_IS_EXPANDER(p)) {
        if (gtk_expander_get_child(GTK_EXPANDER(p))) fatal("container already has a child");
        gtk_expander_set_child(GTK_EXPANDER(p), c);
    } else if (GTK_IS_NOTEBOOK(p)) {
        fatal("use Notebook.appendPage to attach a notebook page");
    } else if (GTK_IS_PANED(p)) {
        if (!gtk_paned_get_start_child(GTK_PANED(p)))
            gtk_paned_set_start_child(GTK_PANED(p), c);
        else if (!gtk_paned_get_end_child(GTK_PANED(p)))
            gtk_paned_set_end_child(GTK_PANED(p), c);
        else fatal("Paned already has two children");
    } else fatal("widget is not a container");
    cr->parent = pr;
}

void cwhip_gtk_widget_remove(void *self, int64_t parent, int64_t child) {
    (void)self;
    widget_live(parent);
    widget_live(child);
    WidgetRecord *cr = record_find(child);
    if (cr->parent != record_find(parent)) fatal("widget is not a child of this container");
    detach(cr);
}

void cwhip_gtk_window_action(void *self, int64_t token, int64_t action) {
    (void)self;
    GtkWidget *w = g_object_ref(widget_live(token));
    if (!GTK_IS_WINDOW(w)) fatal("operation requires Window");
    if (action == 0) gtk_window_present(GTK_WINDOW(w));
    else if (action == 1) {
        if (!gtk_widget_get_realized(w))
            fatal("close requires a presented window; use dispose before presentation");
        gtk_window_close(GTK_WINDOW(w));
    }
    else fatal("invalid window action");
    g_object_unref(w);
}

void cwhip_gtk_window_size(void *self, int64_t token, int64_t width, int64_t height) {
    (void)self;
    GtkWidget *w = widget_live(token);
    if (!GTK_IS_WINDOW(w) || width < 1 || height < 1 || width > G_MAXINT || height > G_MAXINT)
        fatal("invalid window size");
    gtk_window_set_default_size(GTK_WINDOW(w), (int)width, (int)height);
}

int64_t cwhip_gtk_window_width(void *self, int64_t token) {
    (void)self;
    GtkWidget *w = widget_live(token);
    if (!GTK_IS_WINDOW(w)) fatal("invalid window");
    int width = 0;
    gtk_window_get_default_size(GTK_WINDOW(w), &width, NULL);
    return width;
}

int64_t cwhip_gtk_window_height(void *self, int64_t token) {
    (void)self;
    GtkWidget *w = widget_live(token);
    if (!GTK_IS_WINDOW(w)) fatal("invalid window");
    int height = 0;
    gtk_window_get_default_size(GTK_WINDOW(w), NULL, &height);
    return height;
}

void cwhip_gtk_window_transient_for(void *self, int64_t token, int64_t parent) {
    (void)self;
    require_managed();
    cwhip_gtk_require_owner();
    GtkWidget *window = widget_live(token);
    GtkWidget *parent_window = widget_live(parent);
    if (!GTK_IS_WINDOW(window) || !GTK_IS_WINDOW(parent_window) || window == parent_window)
        fatal("transient parent and child must be distinct Windows");
    gtk_window_set_transient_for(GTK_WINDOW(window), GTK_WINDOW(parent_window));
    gtk_window_set_destroy_with_parent(GTK_WINDOW(window), TRUE);
}

void cwhip_gtk_box_layout(void *self, int64_t token, int64_t orientation, int64_t spacing) {
    (void)self;
    GtkWidget *w = widget_live(token);
    if (!GTK_IS_BOX(w) || orientation < 0 || orientation > 1 || spacing < 0 || spacing > G_MAXINT)
        fatal("invalid box layout");
    gtk_orientable_set_orientation(GTK_ORIENTABLE(w), (GtkOrientation)orientation);
    gtk_box_set_spacing(GTK_BOX(w), (int)spacing);
}

void cwhip_gtk_checkbox_set(void *self, int64_t token, bool active) {
    (void)self;
    GtkWidget *w = g_object_ref(widget_live(token));
    if (!GTK_IS_CHECK_BUTTON(w)) fatal("operation requires CheckButton");
    gtk_check_button_set_active(GTK_CHECK_BUTTON(w), active);
    g_object_unref(w);
}

bool cwhip_gtk_checkbox_get(void *self, int64_t token) {
    (void)self;
    GtkWidget *w = widget_live(token);
    if (!GTK_IS_CHECK_BUTTON(w)) fatal("operation requires CheckButton");
    return gtk_check_button_get_active(GTK_CHECK_BUTTON(w)) != FALSE;
}

void cwhip_gtk_notebook_append(void *self, int64_t notebook, int64_t child, void *title) {
    (void)self;
    GtkWidget *parent = widget_live(notebook);
    GtkWidget *page = widget_live(child);
    WidgetRecord *pr = record_find(notebook), *cr = record_find(child);
    if (!GTK_IS_NOTEBOOK(parent) || GTK_IS_WINDOW(page) || pr == cr ||
        cr->parent || gtk_widget_get_parent(page))
        fatal("invalid notebook page");
    for (WidgetRecord *r = pr; r; r = r->parent)
        if (r == cr) fatal("parenting cycle");
    char *label = text_copy(title);
    gtk_notebook_append_page(GTK_NOTEBOOK(parent), page, gtk_label_new(label));
    g_free(label);
    cr->parent = pr;
}

int64_t cwhip_gtk_notebook_current(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_NOTEBOOK(widget)) fatal("operation requires Notebook");
    return gtk_notebook_get_current_page(GTK_NOTEBOOK(widget));
}

void cwhip_gtk_notebook_set_current(void *self, int64_t token, int64_t page) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_NOTEBOOK(widget) || page < 0 ||
        page >= gtk_notebook_get_n_pages(GTK_NOTEBOOK(widget)))
        fatal("invalid notebook page");
    gtk_notebook_set_current_page(GTK_NOTEBOOK(widget), (int)page);
}

int64_t cwhip_gtk_notebook_count(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_NOTEBOOK(widget)) fatal("operation requires Notebook");
    return gtk_notebook_get_n_pages(GTK_NOTEBOOK(widget));
}

void cwhip_gtk_notebook_title(void *self, int64_t token, int64_t page, void *title) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_NOTEBOOK(widget) || page < 0 ||
        page >= gtk_notebook_get_n_pages(GTK_NOTEBOOK(widget)))
        fatal("invalid notebook page");
    GtkWidget *tab = gtk_notebook_get_tab_label(GTK_NOTEBOOK(widget),
                                                gtk_notebook_get_nth_page(GTK_NOTEBOOK(widget), (int)page));
    if (GTK_IS_BOX(tab)) tab = gtk_widget_get_first_child(tab);
    if (!GTK_IS_LABEL(tab)) fatal("notebook tab label is not a Label");
    char *label = text_copy(title);
    if (g_strcmp0(gtk_label_get_text(GTK_LABEL(tab)), label) != 0)
        gtk_label_set_text(GTK_LABEL(tab), label);
    g_free(label);
}

static void css_provider_release(gpointer data) {
    GtkCssProvider *provider = data;
    GdkDisplay *display = g_object_get_data(G_OBJECT(provider), "cwhip-css-display");
    gtk_style_context_remove_provider_for_display(display, GTK_STYLE_PROVIDER(provider));
    g_object_unref(provider);
}

static void notebook_bordered(GtkWidget *notebook) {
    gtk_widget_add_css_class(notebook, "cwhip-file-tabs");
    if (!g_object_get_data(G_OBJECT(notebook), "cwhip-tab-css")) {
        GtkCssProvider *css = gtk_css_provider_new();
        const char *style =
            "notebook.cwhip-file-tabs > header > tabs > tab {"
            "border: 1px solid @borders; border-radius: 4px 4px 0 0; margin: 0 2px; }";
#if GTK_CHECK_VERSION(4, 12, 0)
        gtk_css_provider_load_from_string(css, style);
#else
        gtk_css_provider_load_from_data(css, style, -1);
#endif
        GdkDisplay *display = gtk_widget_get_display(notebook);
        g_object_set_data_full(G_OBJECT(css), "cwhip-css-display",
                               g_object_ref(display), g_object_unref);
        gtk_style_context_add_provider_for_display(display,
            GTK_STYLE_PROVIDER(css), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
        g_object_set_data_full(G_OBJECT(notebook), "cwhip-tab-css", css, css_provider_release);
    }
}

void cwhip_gtk_notebook_closable(void *self, int64_t token, int64_t child,
                                void *title, void *close) {
    cwhip_gtk_notebook_append(self, token, child, title);
    GtkWidget *notebook = widget_live(token);
    GtkWidget *page = widget_live(child);
    GtkWidget *label = gtk_notebook_get_tab_label(GTK_NOTEBOOK(notebook), page);
    g_object_ref(label);
    GtkWidget *tab = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6);
    gtk_notebook_set_tab_label(GTK_NOTEBOOK(notebook), page, tab);
    gtk_box_append(GTK_BOX(tab), label);
    g_object_unref(label);
    GtkWidget *button = gtk_button_new_from_icon_name("window-close-symbolic");
    gtk_widget_set_focus_on_click(button, FALSE);
    gtk_widget_set_tooltip_text(button, "Close tab");
    gtk_accessible_update_property(GTK_ACCESSIBLE(button),
                                   GTK_ACCESSIBLE_PROPERTY_LABEL, "Close tab", -1);
    gtk_widget_add_css_class(button, "flat");
    gtk_box_append(GTK_BOX(tab), button);
    cwhip_gtk_connect_clicked(GTK_BUTTON(button), close);
    notebook_bordered(notebook);
}

void cwhip_gtk_notebook_bordered(void *self, int64_t token) {
    (void)self;
    GtkWidget *notebook = widget_live(token);
    if (!GTK_IS_NOTEBOOK(notebook)) fatal("operation requires Notebook");
    notebook_bordered(notebook);
}

void cwhip_gtk_entry_editable(void *self, int64_t token, bool editable) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_EDITABLE(widget)) fatal("operation requires Entry");
    gtk_editable_set_editable(GTK_EDITABLE(widget), editable);
}

void cwhip_gtk_tree_single_click(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_LIST_VIEW(widget)) fatal("operation requires Tree");
    gtk_list_view_set_single_click_activate(GTK_LIST_VIEW(widget), enabled);
}

void cwhip_gtk_grid_attach(void *self, int64_t token, int64_t child, int64_t column,
                           int64_t row, int64_t width, int64_t height) {
    (void)self;
    GtkWidget *grid = widget_live(token), *widget = widget_live(child);
    WidgetRecord *pr = record_find(token), *cr = record_find(child);
    if (!GTK_IS_GRID(grid) || GTK_IS_WINDOW(widget) || cr->parent ||
        gtk_widget_get_parent(widget) || column < 0 || row < 0 || width < 1 ||
        height < 1 || column > G_MAXINT - width || row > G_MAXINT - height)
        fatal("invalid grid attachment");
    for (WidgetRecord *r = pr; r; r = r->parent)
        if (r == cr) fatal("parenting cycle");
    gtk_grid_attach(GTK_GRID(grid), widget, (int)column, (int)row, (int)width, (int)height);
    cr->parent = pr;
}

static int text_click_line(GtkWidget *widget, double x, double y) {
    GtkTextView *view = GTK_TEXT_VIEW(widget);
    int bx, by;
    gtk_text_view_window_to_buffer_coords(view, GTK_TEXT_WINDOW_WIDGET, x, y, &bx, &by);
    GtkTextIter start, end;
    gtk_text_view_get_iter_at_location(view, &start, bx, by);
    int line = gtk_text_iter_get_line(&start);
    gtk_text_iter_set_line_offset(&start, 0);
    GtkTextBuffer *buffer = gtk_text_view_get_buffer(view);
    if (g_object_get_data(G_OBJECT(widget), "cwhip-line-selection")) {
        end = start;
        gtk_text_iter_forward_to_line_end(&end);
        gtk_text_buffer_select_range(buffer, &start, &end);
    } else {
        gtk_text_buffer_place_cursor(buffer, &start);
    }
    return line + 1;
}

/* A context click inside the current selection keeps it, so menu actions
   such as Copy operate on what the user selected. */
static bool click_in_selection(GtkWidget *widget, double x, double y) {
    GtkTextView *view = GTK_TEXT_VIEW(widget);
    GtkTextIter start, end, hit;
    if (!gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(view), &start, &end))
        return false;
    int bx, by;
    gtk_text_view_window_to_buffer_coords(view, GTK_TEXT_WINDOW_WIDGET, x, y, &bx, &by);
    gtk_text_view_get_iter_at_location(view, &hit, bx, by);
    return gtk_text_iter_in_range(&hit, &start, &end);
}

static void context_pressed(GtkGestureClick *gesture, int count, double x, double y,
                            gpointer data) {
    (void)count;
    GtkPopover *popover = data;
    GtkWidget *owner_widget = gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(gesture));
    Connection *popup = g_object_get_data(G_OBJECT(popover), "cwhip-popup");
    if (popup && !popup->closed) {
        /* Deliver owner-local coords before opening so the app can rebuild. */
        int acquired = signal_enter(popup);
        typedef void (*Adapter)(CwhipCallbackContext *, double, double);
        ((Adapter)cwhip_callback_adapter(popup->context))(popup->context, x, y);
        signal_leave(popup, acquired);
        if (popup->closed || !GTK_IS_POPOVER(popover)) {
            gtk_gesture_set_state(GTK_GESTURE(gesture), GTK_EVENT_SEQUENCE_CLAIMED);
            return;
        }
    }
    if (GTK_IS_TEXT_VIEW(owner_widget) && !click_in_selection(owner_widget, x, y))
        text_click_line(owner_widget, x, y);
    GdkRectangle point = { (int)x, (int)y, 1, 1 };
    gtk_popover_set_pointing_to(popover, &point);
    gtk_popover_popup(popover);
    gtk_gesture_set_state(GTK_GESTURE(gesture), GTK_EVENT_SEQUENCE_CLAIMED);
}

bool cwhip_gtk_window_maximized(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_WINDOW(widget)) fatal("operation requires Window");
    return gtk_window_is_maximized(GTK_WINDOW(widget));
}

/* GtkNotebook scroll arrows change the current page via a capture-phase click
 * gesture that claims the press and tracks pressed_button privately. If the
 * release is lost (common when switch-page moves focus into a SourceView),
 * later arrow clicks hit the arrow, claim the sequence, and no-op until some
 * other click clears the stuck press. Resetting click gestures after a page
 * change restores left/right arrow use. Hold-to-repeat on the arrows may stop
 * after the first step; single clicks remain reliable.
 *
 * Resizing so the arrows hide and reappear recreates (or remaps) the arrow
 * widgets without a page change, so the same unstick/wire path must also run
 * when the notebook allocation changes. */
static void notebook_schedule_wire_scroll_arrows(GtkNotebook *notebook);

static void notebook_reset_click_gestures(GtkWidget *widget) {
    GListModel *controllers = gtk_widget_observe_controllers(widget);
    guint n = g_list_model_get_n_items(controllers);
    for (guint i = 0; i < n; i++) {
        GtkEventController *controller = g_list_model_get_item(controllers, i);
        if (GTK_IS_GESTURE_CLICK(controller))
            gtk_event_controller_reset(controller);
        g_object_unref(controller);
    }
    g_object_unref(controllers);
}

static void notebook_reset_click_gestures_walk(GtkWidget *widget) {
    notebook_reset_click_gestures(widget);
    for (GtkWidget *child = gtk_widget_get_first_child(widget); child;
         child = gtk_widget_get_next_sibling(child))
        notebook_reset_click_gestures_walk(child);
}

static gboolean notebook_scroll_unstick(gpointer data) {
    GtkWidget *notebook = data;
    g_object_set_data(G_OBJECT(notebook), "cwhip-scroll-unstick", NULL);
    /* Reset gestures on the notebook and its arrow children; the stuck
     * pressed_button lives on the arrow's capture-phase click gesture. */
    notebook_reset_click_gestures_walk(notebook);
    return G_SOURCE_REMOVE;
}

static void notebook_schedule_scroll_unstick(GtkNotebook *notebook) {
    GtkWidget *widget = GTK_WIDGET(notebook);
    if (g_object_get_data(G_OBJECT(widget), "cwhip-scroll-unstick")) return;
    g_object_set_data(G_OBJECT(widget), "cwhip-scroll-unstick", GINT_TO_POINTER(1));
    g_idle_add_full(G_PRIORITY_DEFAULT_IDLE, notebook_scroll_unstick,
                    g_object_ref(widget), g_object_unref);
}

static void notebook_refresh_scroll_arrows(GtkNotebook *notebook) {
    notebook_schedule_scroll_unstick(notebook);
    notebook_schedule_wire_scroll_arrows(notebook);
}

static void notebook_page_notify_scroll(GObject *object, GParamSpec *pspec,
                                       gpointer data) {
    (void)pspec;
    (void)data;
    notebook_refresh_scroll_arrows(GTK_NOTEBOOK(object));
}

static void notebook_pages_changed(GtkNotebook *notebook, GtkWidget *child,
                                  guint page_num, gpointer data) {
    (void)child;
    (void)page_num;
    (void)data;
    notebook_refresh_scroll_arrows(notebook);
}

static void notebook_arrow_clicked(GtkButton *button, gpointer data) {
    GtkNotebook *notebook = data;
    if (GPOINTER_TO_INT(g_object_get_data(G_OBJECT(button), "cwhip-notebook-prev")))
        gtk_notebook_prev_page(notebook);
    else
        gtk_notebook_next_page(notebook);
}

static void notebook_arrow_map(GtkWidget *arrow, gpointer data) {
    (void)arrow;
    GtkNotebook *notebook = data;
    notebook_schedule_scroll_unstick(notebook);
    notebook_schedule_wire_scroll_arrows(notebook);
}

static void notebook_wire_scroll_arrow(GtkNotebook *notebook, GtkWidget *arrow,
                                      bool previous) {
    if (g_object_get_data(G_OBJECT(arrow), "cwhip-arrow-wired")) return;
    g_object_set_data(G_OBJECT(arrow), "cwhip-arrow-wired", GINT_TO_POINTER(1));
    g_object_set_data(G_OBJECT(arrow), "cwhip-notebook-prev",
                      GINT_TO_POINTER(previous ? 1 : 0));
    gtk_widget_set_focus_on_click(arrow, FALSE);
    g_signal_connect_object(arrow, "clicked", G_CALLBACK(notebook_arrow_clicked),
                            notebook, 0);
    /* Arrows are often destroyed/recreated or unmapped when the tab bar no
     * longer needs scrolling; remapping must re-run the unstick/wire path. */
    g_signal_connect_object(arrow, "map", G_CALLBACK(notebook_arrow_map),
                            notebook, 0);
    notebook_reset_click_gestures(arrow);
}

static void notebook_wire_scroll_arrows_walk(GtkNotebook *notebook, GtkWidget *widget) {
    if (GTK_IS_BUTTON(widget) &&
        g_strcmp0(gtk_widget_get_css_name(widget), "arrow") == 0) {
        bool previous = gtk_widget_has_css_class(widget, "down");
        notebook_wire_scroll_arrow(notebook, widget, previous);
    }
    for (GtkWidget *child = gtk_widget_get_first_child(widget); child;
         child = gtk_widget_get_next_sibling(child))
        notebook_wire_scroll_arrows_walk(notebook, child);
}

static gboolean notebook_wire_scroll_arrows_idle(gpointer data) {
    GtkNotebook *notebook = data;
    g_object_set_data(G_OBJECT(notebook), "cwhip-scroll-wire", NULL);
    notebook_wire_scroll_arrows_walk(notebook, GTK_WIDGET(notebook));
    return G_SOURCE_REMOVE;
}

static void notebook_schedule_wire_scroll_arrows(GtkNotebook *notebook) {
    GtkWidget *widget = GTK_WIDGET(notebook);
    if (g_object_get_data(G_OBJECT(widget), "cwhip-scroll-wire")) return;
    g_object_set_data(G_OBJECT(widget), "cwhip-scroll-wire", GINT_TO_POINTER(1));
    g_idle_add_full(G_PRIORITY_DEFAULT_IDLE, notebook_wire_scroll_arrows_idle,
                    g_object_ref(widget), g_object_unref);
}

static gboolean notebook_scroll_tick(GtkWidget *widget, GdkFrameClock *clock,
                                    gpointer data) {
    (void)clock;
    (void)data;
    int width = gtk_widget_get_width(widget);
    int height = gtk_widget_get_height(widget);
    int prev_w = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(widget), "cwhip-nb-w"));
    int prev_h = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(widget), "cwhip-nb-h"));
    if (width != prev_w || height != prev_h) {
        g_object_set_data(G_OBJECT(widget), "cwhip-nb-w", GINT_TO_POINTER(width));
        g_object_set_data(G_OBJECT(widget), "cwhip-nb-h", GINT_TO_POINTER(height));
        notebook_schedule_wire_scroll_arrows(GTK_NOTEBOOK(widget));
        notebook_schedule_scroll_unstick(GTK_NOTEBOOK(widget));
    }
    return G_SOURCE_CONTINUE;
}

void cwhip_gtk_notebook_scrollable(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_NOTEBOOK(widget)) fatal("operation requires Notebook");
    gtk_notebook_set_scrollable(GTK_NOTEBOOK(widget), enabled);
    if (!enabled) return;
    if (!g_object_get_data(G_OBJECT(widget), "cwhip-scroll-page-hook")) {
        g_signal_connect(widget, "notify::page", G_CALLBACK(notebook_page_notify_scroll),
                         NULL);
        /* Overflow arrows can appear/disappear when pages are added/removed
         * without a notebook allocation change. */
        g_signal_connect(widget, "page-added", G_CALLBACK(notebook_pages_changed),
                         NULL);
        g_signal_connect(widget, "page-removed", G_CALLBACK(notebook_pages_changed),
                         NULL);
        g_object_set_data(G_OBJECT(widget), "cwhip-scroll-page-hook", GINT_TO_POINTER(1));
    }
    if (!g_object_get_data(G_OBJECT(widget), "cwhip-scroll-tick")) {
        gtk_widget_add_tick_callback(widget, notebook_scroll_tick, NULL, NULL);
        g_object_set_data(G_OBJECT(widget), "cwhip-scroll-tick", GINT_TO_POINTER(1));
    }
    notebook_schedule_wire_scroll_arrows(GTK_NOTEBOOK(widget));
}

void cwhip_gtk_window_maximize(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_WINDOW(widget)) fatal("operation requires Window");
    if (enabled) gtk_window_maximize(GTK_WINDOW(widget));
    else gtk_window_unmaximize(GTK_WINDOW(widget));
}

void cwhip_gtk_context_menu_bind(void *self, int64_t token, int64_t owner_token) {
    (void)self;
    GtkWidget *menu = widget_live(token), *owner_widget = widget_live(owner_token);
    WidgetRecord *pr = record_find(owner_token), *cr = record_find(token);
    if (!GTK_IS_POPOVER(menu) || cr->parent || gtk_widget_get_parent(menu))
        fatal("invalid context menu owner");
    for (WidgetRecord *r = pr; r; r = r->parent)
        if (r == cr) fatal("parenting cycle");
    gtk_widget_set_parent(menu, owner_widget);
    cr->parent = pr;
    GtkGesture *gesture = gtk_gesture_click_new();
    gtk_event_controller_set_propagation_phase(GTK_EVENT_CONTROLLER(gesture), GTK_PHASE_CAPTURE);
    gtk_gesture_single_set_button(GTK_GESTURE_SINGLE(gesture), GDK_BUTTON_SECONDARY);
    g_signal_connect_object(gesture, "pressed", G_CALLBACK(context_pressed), menu, 0);
    gtk_widget_add_controller(owner_widget, GTK_EVENT_CONTROLLER(gesture));
}

void cwhip_gtk_context_menu_popup_at(void *self, int64_t token, double x, double y) {
    (void)self;
    GtkWidget *menu = widget_live(token);
    if (!GTK_IS_POPOVER(menu)) fatal("operation requires ContextMenu");
    GdkRectangle point = { (int)x, (int)y, 1, 1 };
    gtk_popover_set_pointing_to(GTK_POPOVER(menu), &point);
    gtk_popover_popup(GTK_POPOVER(menu));
}

static GtkAdjustment *scrollbar_adjustment(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SCROLLBAR(widget)) fatal("operation requires Scrollbar");
    return gtk_scrollbar_get_adjustment(GTK_SCROLLBAR(widget));
}

void cwhip_gtk_scrollbar_configure(void *self, int64_t token, double value, double lower,
                                   double upper, double step, double page, double page_size) {
    (void)self;
    if (!(upper > lower) || page_size < 0.0 || step < 0.0 || page < 0.0)
        fatal("invalid scrollbar adjustment range");
    gtk_adjustment_configure(scrollbar_adjustment(token), value, lower, upper, step, page,
                             page_size);
}

void cwhip_gtk_scrollbar_set_value(void *self, int64_t token, double value) {
    (void)self;
    gtk_adjustment_set_value(scrollbar_adjustment(token), value);
}

double cwhip_gtk_scrollbar_get_value(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_value(scrollbar_adjustment(token));
}

double cwhip_gtk_scrollbar_get_lower(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_lower(scrollbar_adjustment(token));
}

double cwhip_gtk_scrollbar_get_upper(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_upper(scrollbar_adjustment(token));
}

double cwhip_gtk_scrollbar_get_page_size(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_page_size(scrollbar_adjustment(token));
}

static void scrollbar_value_changed(GtkAdjustment *adjustment, gpointer data) {
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, double);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, gtk_adjustment_get_value(adjustment));
    signal_leave(connection, acquired);
}

static GtkAdjustment *scale_adjustment(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SCALE(widget)) fatal("operation requires Scale");
    return gtk_range_get_adjustment(GTK_RANGE(widget));
}

void cwhip_gtk_scale_configure(void *self, int64_t token, double value, double lower,
                               double upper, double step) {
    (void)self;
    if (!(upper > lower) || !(step > 0.0))
        fatal("invalid scale range or step");
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SCALE(widget)) fatal("operation requires Scale");
    gtk_adjustment_configure(gtk_range_get_adjustment(GTK_RANGE(widget)), value, lower, upper,
                             step, step * 10.0, 0.0);
    /* Match gtk_scale_new_with_range digit heuristic for common step sizes. */
    int digits = 0;
    double probe = step;
    while (digits < 6 && probe < 1.0) {
        probe *= 10.0;
        ++digits;
    }
    gtk_scale_set_digits(GTK_SCALE(widget), digits);
}

void cwhip_gtk_scale_set_value(void *self, int64_t token, double value) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SCALE(widget)) fatal("operation requires Scale");
    gtk_range_set_value(GTK_RANGE(widget), value);
}

double cwhip_gtk_scale_get_value(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SCALE(widget)) fatal("operation requires Scale");
    return gtk_range_get_value(GTK_RANGE(widget));
}

double cwhip_gtk_scale_get_lower(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_lower(scale_adjustment(token));
}

double cwhip_gtk_scale_get_upper(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_upper(scale_adjustment(token));
}

double cwhip_gtk_scale_get_step(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_step_increment(scale_adjustment(token));
}

static void scale_value_changed(GtkAdjustment *adjustment, gpointer data) {
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, double);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, gtk_adjustment_get_value(adjustment));
    signal_leave(connection, acquired);
}

static GtkProgressBar *progress_bar_live(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_PROGRESS_BAR(widget)) fatal("operation requires ProgressBar");
    return GTK_PROGRESS_BAR(widget);
}

void cwhip_gtk_progress_bar_set_fraction(void *self, int64_t token, double fraction) {
    (void)self;
    if (!(fraction >= 0.0) || !(fraction <= 1.0))
        fatal("progress fraction must be between 0.0 and 1.0");
    gtk_progress_bar_set_fraction(progress_bar_live(token), fraction);
}

double cwhip_gtk_progress_bar_get_fraction(void *self, int64_t token) {
    (void)self;
    return gtk_progress_bar_get_fraction(progress_bar_live(token));
}

void cwhip_gtk_progress_bar_set_text(void *self, int64_t token, void *text) {
    (void)self;
    char *label = text_copy(text);
    /* Empty string clears custom text so GTK may show a percentage. */
    gtk_progress_bar_set_text(progress_bar_live(token), label[0] ? label : NULL);
    g_free(label);
}

void *cwhip_gtk_progress_bar_get_text(void *self, int64_t token) {
    (void)self;
    const char *text = gtk_progress_bar_get_text(progress_bar_live(token));
    if (!text) text = "";
    return cwhip_string_new(&cwhip_string_class_meta, text, strlen(text));
}

void cwhip_gtk_progress_bar_set_show_text(void *self, int64_t token, bool show) {
    (void)self;
    gtk_progress_bar_set_show_text(progress_bar_live(token), show);
}

bool cwhip_gtk_progress_bar_get_show_text(void *self, int64_t token) {
    (void)self;
    return gtk_progress_bar_get_show_text(progress_bar_live(token));
}

void cwhip_gtk_progress_bar_pulse(void *self, int64_t token) {
    (void)self;
    gtk_progress_bar_pulse(progress_bar_live(token));
}

void cwhip_gtk_progress_bar_set_pulse_step(void *self, int64_t token, double step) {
    (void)self;
    if (!(step > 0.0) || !(step <= 1.0))
        fatal("progress pulse step must be in (0.0, 1.0]");
    gtk_progress_bar_set_pulse_step(progress_bar_live(token), step);
}

double cwhip_gtk_progress_bar_get_pulse_step(void *self, int64_t token) {
    (void)self;
    return gtk_progress_bar_get_pulse_step(progress_bar_live(token));
}

static GtkAdjustment *spin_button_adjustment(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SPIN_BUTTON(widget)) fatal("operation requires SpinButton");
    return gtk_spin_button_get_adjustment(GTK_SPIN_BUTTON(widget));
}

static int spin_button_digits_for_step(double step) {
    int digits = 0;
    double probe = step;
    while (digits < 6 && probe < 1.0) {
        probe *= 10.0;
        ++digits;
    }
    return digits;
}

void cwhip_gtk_spin_button_configure(void *self, int64_t token, double value, double lower,
                                     double upper, double step) {
    (void)self;
    if (!(upper > lower) || !(step > 0.0))
        fatal("invalid spin button range or step");
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SPIN_BUTTON(widget)) fatal("operation requires SpinButton");
    gtk_adjustment_configure(gtk_spin_button_get_adjustment(GTK_SPIN_BUTTON(widget)), value,
                             lower, upper, step, step * 10.0, 0.0);
    gtk_spin_button_set_digits(GTK_SPIN_BUTTON(widget), spin_button_digits_for_step(step));
}

void cwhip_gtk_spin_button_set_value(void *self, int64_t token, double value) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SPIN_BUTTON(widget)) fatal("operation requires SpinButton");
    gtk_spin_button_set_value(GTK_SPIN_BUTTON(widget), value);
}

double cwhip_gtk_spin_button_get_value(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_SPIN_BUTTON(widget)) fatal("operation requires SpinButton");
    return gtk_spin_button_get_value(GTK_SPIN_BUTTON(widget));
}

double cwhip_gtk_spin_button_get_lower(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_lower(spin_button_adjustment(token));
}

double cwhip_gtk_spin_button_get_upper(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_upper(spin_button_adjustment(token));
}

double cwhip_gtk_spin_button_get_step(void *self, int64_t token) {
    (void)self;
    return gtk_adjustment_get_step_increment(spin_button_adjustment(token));
}

static void spin_button_value_changed(GtkSpinButton *spin, gpointer data) {
    Connection *connection = data;
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, double);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, gtk_spin_button_get_value(spin));
    signal_leave(connection, acquired);
}

static GtkStringList *drop_down_strings(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_DROP_DOWN(widget)) fatal("operation requires DropDown");
    GListModel *model = gtk_drop_down_get_model(GTK_DROP_DOWN(widget));
    if (!GTK_IS_STRING_LIST(model)) fatal("DropDown model is not a string list");
    return GTK_STRING_LIST(model);
}

void cwhip_gtk_drop_down_clear(void *self, int64_t token) {
    (void)self;
    GtkStringList *strings = drop_down_strings(token);
    guint n = g_list_model_get_n_items(G_LIST_MODEL(strings));
    if (n > 0) gtk_string_list_splice(strings, 0, n, NULL);
    gtk_drop_down_set_selected(GTK_DROP_DOWN(widget_live(token)), GTK_INVALID_LIST_POSITION);
}

void cwhip_gtk_drop_down_append(void *self, int64_t token, void *label_text) {
    (void)self;
    char *label = text_copy(label_text);
    gtk_string_list_append(drop_down_strings(token), label);
    g_free(label);
}

void cwhip_gtk_drop_down_set_selected(void *self, int64_t token, int64_t index) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_DROP_DOWN(widget)) fatal("operation requires DropDown");
    if (index < -1) fatal("invalid DropDown selection");
    if (index < 0) {
        gtk_drop_down_set_selected(GTK_DROP_DOWN(widget), GTK_INVALID_LIST_POSITION);
        return;
    }
    guint n = g_list_model_get_n_items(G_LIST_MODEL(drop_down_strings(token)));
    if ((guint)index >= n) fatal("DropDown selection out of range");
    gtk_drop_down_set_selected(GTK_DROP_DOWN(widget), (guint)index);
}

int64_t cwhip_gtk_drop_down_get_selected(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_DROP_DOWN(widget)) fatal("operation requires DropDown");
    guint selected = gtk_drop_down_get_selected(GTK_DROP_DOWN(widget));
    if (selected == GTK_INVALID_LIST_POSITION) return -1;
    return (int64_t)selected;
}

int64_t cwhip_gtk_drop_down_get_size(void *self, int64_t token) {
    (void)self;
    return (int64_t)g_list_model_get_n_items(G_LIST_MODEL(drop_down_strings(token)));
}

void *cwhip_gtk_drop_down_get_item(void *self, int64_t token, int64_t index) {
    (void)self;
    if (index < 0) fatal("DropDown item index out of range");
    GtkStringList *strings = drop_down_strings(token);
    guint n = g_list_model_get_n_items(G_LIST_MODEL(strings));
    if ((guint)index >= n) fatal("DropDown item index out of range");
    const char *text = gtk_string_list_get_string(strings, (guint)index);
    if (!text) text = "";
    return cwhip_string_new(&cwhip_string_class_meta, text, strlen(text));
}

void *cwhip_gtk_drop_down_get_selected_text(void *self, int64_t token) {
    (void)self;
    int64_t index = cwhip_gtk_drop_down_get_selected(self, token);
    if (index < 0) return cwhip_string_new(&cwhip_string_class_meta, "", 0);
    return cwhip_gtk_drop_down_get_item(self, token, index);
}

static void drop_down_selected(GObject *object, GParamSpec *property, gpointer data) {
    (void)property;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    guint selected = gtk_drop_down_get_selected(GTK_DROP_DOWN(object));
    int64_t index = selected == GTK_INVALID_LIST_POSITION ? -1 : (int64_t)selected;
    typedef void (*Adapter)(CwhipCallbackContext *, int64_t);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context, index);
    signal_leave(connection, acquired);
}

void cwhip_gtk_frame_set_label(void *self, int64_t token, void *label_text) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_FRAME(widget)) fatal("operation requires Frame");
    char *label = text_copy(label_text);
    gtk_frame_set_label(GTK_FRAME(widget), label[0] ? label : NULL);
    g_free(label);
}

void *cwhip_gtk_frame_get_label(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_FRAME(widget)) fatal("operation requires Frame");
    const char *text = gtk_frame_get_label(GTK_FRAME(widget));
    if (!text) text = "";
    return cwhip_string_new(&cwhip_string_class_meta, text, strlen(text));
}

void cwhip_gtk_expander_set_label(void *self, int64_t token, void *label_text) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_EXPANDER(widget)) fatal("operation requires Expander");
    char *label = text_copy(label_text);
    gtk_expander_set_label(GTK_EXPANDER(widget), label);
    g_free(label);
}

void *cwhip_gtk_expander_get_label(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_EXPANDER(widget)) fatal("operation requires Expander");
    const char *text = gtk_expander_get_label(GTK_EXPANDER(widget));
    if (!text) text = "";
    return cwhip_string_new(&cwhip_string_class_meta, text, strlen(text));
}

void cwhip_gtk_expander_set_expanded(void *self, int64_t token, bool expanded) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_EXPANDER(widget)) fatal("operation requires Expander");
    gtk_expander_set_expanded(GTK_EXPANDER(widget), expanded);
}

bool cwhip_gtk_expander_get_expanded(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_EXPANDER(widget)) fatal("operation requires Expander");
    return gtk_expander_get_expanded(GTK_EXPANDER(widget)) != FALSE;
}

static GtkTextBuffer *text_view_buffer(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_TEXT_VIEW(widget)) fatal("operation requires TextView");
#ifdef CWHIP_GTK_SOURCEVIEW
    /* SourceView has its own buffer APIs; reject accidental cross-use. */
    if (GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires TextView");
#endif
    return gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget));
}

void cwhip_gtk_text_view_set_text(void *self, int64_t token, void *text) {
    (void)self;
    char *bytes = text_copy(text);
    gtk_text_buffer_set_text(text_view_buffer(token), bytes, -1);
    g_free(bytes);
}

void *cwhip_gtk_text_view_get_text(void *self, int64_t token) {
    (void)self;
    GtkTextBuffer *buffer = text_view_buffer(token);
    GtkTextIter start, end;
    gtk_text_buffer_get_bounds(buffer, &start, &end);
    char *bytes = gtk_text_buffer_get_text(buffer, &start, &end, FALSE);
    void *result = cwhip_string_new(&cwhip_string_class_meta, bytes, strlen(bytes));
    g_free(bytes);
    return result;
}

void cwhip_gtk_text_view_set_editable(void *self, int64_t token, bool editable) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_TEXT_VIEW(widget)) fatal("operation requires TextView");
    gtk_text_view_set_editable(GTK_TEXT_VIEW(widget), editable);
    gtk_text_view_set_cursor_visible(GTK_TEXT_VIEW(widget), editable);
}

bool cwhip_gtk_text_view_get_editable(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_TEXT_VIEW(widget)) fatal("operation requires TextView");
    return gtk_text_view_get_editable(GTK_TEXT_VIEW(widget)) != FALSE;
}

void cwhip_gtk_text_view_set_wrap(void *self, int64_t token, bool wrap) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_TEXT_VIEW(widget)) fatal("operation requires TextView");
    gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(widget),
                                wrap ? GTK_WRAP_WORD_CHAR : GTK_WRAP_NONE);
}

bool cwhip_gtk_text_view_get_wrap(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_TEXT_VIEW(widget)) fatal("operation requires TextView");
    return gtk_text_view_get_wrap_mode(GTK_TEXT_VIEW(widget)) != GTK_WRAP_NONE;
}

static void text_view_changed(GtkTextBuffer *buffer, gpointer data) {
    Connection *connection = data;
    int acquired = signal_enter(connection);
    GtkTextIter start, end;
    gtk_text_buffer_get_bounds(buffer, &start, &end);
    char *bytes = gtk_text_buffer_get_text(buffer, &start, &end, FALSE);
    void *text = cwhip_string_new(&cwhip_string_class_meta, bytes, strlen(bytes));
    g_free(bytes);
    void *slots[] = { &text };
    CwhipRootFrame frame = {0};
    cwhip_gc_push_or_abort(&frame, slots, 1);
    typedef void (*Adapter)(CwhipCallbackContext *, void *);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context, text);
    cwhip_gc_pop_or_abort(&frame);
    signal_leave(connection, acquired);
}

static void shortcut_free(ShortcutBinding *binding) {
    g_free(binding->trigger);
    free(binding);
}

static gboolean shortcut_invoke(GtkWidget *widget, GVariant *args, gpointer data) {
    (void)widget;
    (void)args;
    cwhip_gtk_require_owner();
    ShortcutBinding *binding = data;
    if (!binding->context || binding->release_pending) return FALSE;
    int acquired = cwhip_runtime_managed_enter();
    ++binding->active;
    typedef void (*Adapter)(CwhipCallbackContext *);
    ((Adapter)cwhip_callback_adapter(binding->context))(binding->context);
    if (--binding->active == 0) {
        if (binding->release_pending) shortcut_release(binding);
        if (binding->orphaned) shortcut_free(binding);
    }
    cwhip_runtime_managed_leave(acquired);
    return TRUE;
}

/* GtkCallbackAction destroy notify. GTK may finalize the action while its
 * callback is still running (the view or window was disposed from inside the
 * shortcut); shortcut_invoke then completes the release on unwind. */
static void shortcut_context_dispose(gpointer data) {
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    ShortcutBinding *binding = data;
    if (binding->owner) {
        ShortcutBinding **link = &binding->owner->shortcuts;
        while (*link && *link != binding) link = &(*link)->next;
        if (*link == binding) *link = binding->next;
        binding->owner = NULL;
    }
    shortcut_release(binding);
    if (binding->active) binding->orphaned = true;
    else shortcut_free(binding);
    cwhip_runtime_managed_leave(acquired);
}

static bool shortcut_bind(GtkWidget *widget, int64_t token, void *trigger_text,
                          void *callback, GtkShortcutScope scope) {
    char *trigger_name = text_copy(trigger_text);
    GtkShortcutTrigger *trigger = gtk_shortcut_trigger_parse_string(trigger_name);
    if (!trigger) {
        g_free(trigger_name);
        return false;
    }
    ShortcutBinding *binding = calloc(1, sizeof(*binding));
    if (!binding) fatal("allocation failed");
    binding->owner = record_find(token);
    binding->context = cwhip_callback_acquire(callback, "callback<void()>");
    binding->trigger = trigger_name;
    binding->next = binding->owner->shortcuts;
    binding->owner->shortcuts = binding;
    GtkShortcutAction *action = gtk_callback_action_new(
        shortcut_invoke, binding, shortcut_context_dispose);
    if (!action) fatal("could not create GTK shortcut action");
    GtkShortcut *shortcut = gtk_shortcut_new(trigger, action);
    GtkEventController *controller = gtk_shortcut_controller_new();
    binding->controller = controller;
    gtk_shortcut_controller_set_scope(GTK_SHORTCUT_CONTROLLER(controller), scope);
    gtk_shortcut_controller_add_shortcut(GTK_SHORTCUT_CONTROLLER(controller), shortcut);
    gtk_widget_add_controller(widget, controller);
    return true;
}

static bool shortcut_bound(WidgetRecord *record, void *trigger_text) {
    char *trigger = text_copy(trigger_text);
    bool found = false;
    for (ShortcutBinding *binding = record->shortcuts; binding; binding = binding->next)
        if (g_str_equal(binding->trigger, trigger)) {
            found = true;
            break;
        }
    g_free(trigger);
    return found;
}

/* GTK Windows consume F10 for the menubar accelerator by default. Cwhip apps
 * that bind F10 (for example a debugger's Step Over) must turn that off or the
 * first keypress only focuses the menubar and never runs the shortcut. */
void cwhip_gtk_window_handle_menubar_accel(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_WINDOW(widget)) fatal("operation requires Window");
    gtk_window_set_handle_menubar_accel(GTK_WINDOW(widget), enabled);
}

bool cwhip_gtk_window_handles_menubar_accel(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_WINDOW(widget)) fatal("operation requires Window");
    return gtk_window_get_handle_menubar_accel(GTK_WINDOW(widget));
}

/* A window-level controller sees key events bubbling up from any focused
 * descendant, including entries and read-only source panes. */
bool cwhip_gtk_window_bind_shortcut(void *self, int64_t token, void *trigger_text,
                                    void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_WINDOW(widget)) fatal("operation requires Window");
    char *trigger = text_copy(trigger_text);
    if (g_strcmp0(trigger, "F10") == 0)
        gtk_window_set_handle_menubar_accel(GTK_WINDOW(widget), FALSE);
    g_free(trigger);
    return shortcut_bind(widget, token, trigger_text, callback, GTK_SHORTCUT_SCOPE_LOCAL);
}

bool cwhip_gtk_window_has_shortcut(void *self, int64_t token, void *trigger_text) {
    (void)self;
    WidgetRecord *record = record_find(token);
    if (!GTK_IS_WINDOW(record->widget)) fatal("operation requires Window");
    return shortcut_bound(record, trigger_text);
}

#ifdef CWHIP_GTK_SOURCEVIEW
void cwhip_gtk_source_view_emoji_menu(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires SourceView");
    GtkInputHints hints = gtk_text_view_get_input_hints(GTK_TEXT_VIEW(widget));
    gtk_text_view_set_input_hints(GTK_TEXT_VIEW(widget),
        enabled ? hints & ~GTK_INPUT_HINT_NO_EMOJI : hints | GTK_INPUT_HINT_NO_EMOJI);
}

/* Appends a labeled action to the native text-view context menu without
 * replacing Cut/Copy/Paste or other built-in entries. */
void cwhip_gtk_source_view_context_action(void *self, int64_t token, void *label_text,
                                          void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires SourceView");
    char *label = text_copy(label_text);
    GMenu *menu = g_object_get_data(G_OBJECT(widget), "cwhip-extra-menu");
    GSimpleActionGroup *actions = g_object_get_data(G_OBJECT(widget), "cwhip-extra-actions");
    if (!menu) {
        menu = g_menu_new();
        actions = g_simple_action_group_new();
        gtk_widget_insert_action_group(widget, "cwhip", G_ACTION_GROUP(actions));
        gtk_text_view_set_extra_menu(GTK_TEXT_VIEW(widget), G_MENU_MODEL(menu));
        g_object_set_data_full(G_OBJECT(widget), "cwhip-extra-menu", menu, g_object_unref);
        g_object_set_data_full(G_OBJECT(widget), "cwhip-extra-actions", actions, g_object_unref);
    }
    char *name = g_strdup_printf("extra%" G_GINT64_FORMAT, token_new());
    GSimpleAction *action = g_simple_action_new(name, NULL);
    connect_signal(G_OBJECT(action), "activate", G_CALLBACK(menu_activated), callback,
                   "callback<void()>");
    g_action_map_add_action(G_ACTION_MAP(actions), G_ACTION(action));
    char *detailed = g_strconcat("cwhip.", name, NULL);
    g_menu_append(menu, label, detailed);
    g_object_unref(action);
    g_free(detailed);
    g_free(name);
    g_free(label);
}

static GtkSourceBuffer *source_buffer(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires GtkSourceView");
    return GTK_SOURCE_BUFFER(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)));
}

int64_t cwhip_gtk_source_view_changed(void *self, int64_t token, void *callback) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    int64_t connection = connect_signal(G_OBJECT(buffer), "changed", G_CALLBACK(changed_no_args),
                                        callback, "callback<void()>");
    connect_state(connection, "notify::can-undo");
    connect_state(connection, "notify::can-redo");
    return connection;
}

int64_t cwhip_gtk_source_view_cursor_moved(void *self, int64_t token, void *callback) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    int64_t connection = connect_signal(G_OBJECT(buffer), "mark-set", G_CALLBACK(cursor_moved),
                                        callback, "callback<void()>");
    connect_state(connection, "notify::has-selection");
    return connection;
}

void cwhip_gtk_source_view_line_selection(void *self, int64_t token, bool enabled) {
    (void)self;
    source_buffer(token);
    g_object_set_data(G_OBJECT(widget_live(token)), "cwhip-line-selection",
                      enabled ? GINT_TO_POINTER(1) : NULL);
}

static void source_line_pressed(GtkGestureClick *gesture, int count, double x, double y,
                                gpointer data) {
    if (count != 1) return;
    Connection *connection = data;
    int acquired = signal_enter(connection);
    GtkWidget *widget = gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(gesture));
    int line = text_click_line(widget, x, y);
    /* Do not claim the sequence. Claiming on press and then losing the release
     * (common when focus moves during the click) leaves the capture gesture
     * stuck so a later toolbar click is swallowed until a second press. */
    (void)gesture;
    typedef void (*Adapter)(CwhipCallbackContext *, int64_t);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context, line);
    signal_leave(connection, acquired);
}

int64_t cwhip_gtk_source_view_line_activated(void *self, int64_t token, void *callback) {
    (void)self;
    source_buffer(token);
    GtkWidget *widget = widget_live(token);
    GtkGesture *gesture = gtk_gesture_click_new();
    gtk_gesture_single_set_button(GTK_GESTURE_SINGLE(gesture), GDK_BUTTON_PRIMARY);
    gtk_event_controller_set_propagation_phase(GTK_EVENT_CONTROLLER(gesture), GTK_PHASE_CAPTURE);
    int64_t connection = connect_signal(G_OBJECT(gesture), "pressed",
        G_CALLBACK(source_line_pressed), callback, "callback<void(int64)>");
    gtk_widget_add_controller(widget, GTK_EVENT_CONTROLLER(gesture));
    return connection;
}

static gchar *mark_tooltip_text(GtkSourceMarkAttributes *attributes, GtkSourceMark *mark,
                                gpointer data) {
    (void)attributes;
    (void)data;
    const char *text = g_object_get_data(G_OBJECT(mark), "cwhip-tooltip");
    return text ? g_strdup(text) : NULL;
}

static gboolean source_query_tooltip(GtkWidget *widget, gint x, gint y, gboolean keyboard_mode,
                                     GtkTooltip *tooltip, gpointer data) {
    (void)data;
    GtkTextView *view = GTK_TEXT_VIEW(widget);
    GtkTextIter iter;
    if (keyboard_mode) {
        GtkTextBuffer *buffer = gtk_text_view_get_buffer(view);
        GtkTextMark *insert = gtk_text_buffer_get_insert(buffer);
        gtk_text_buffer_get_iter_at_mark(buffer, &iter, insert);
    } else {
        int buffer_x = 0, buffer_y = 0;
        gtk_text_view_window_to_buffer_coords(view, GTK_TEXT_WINDOW_WIDGET, x, y, &buffer_x,
                                              &buffer_y);
        gtk_text_view_get_iter_at_location(view, &iter, buffer_x, buffer_y);
    }
    GSList *marks = gtk_source_buffer_get_source_marks_at_line(
        GTK_SOURCE_BUFFER(gtk_text_view_get_buffer(view)), gtk_text_iter_get_line(&iter), NULL);
    const char *text = NULL;
    for (GSList *node = marks; node; node = node->next) {
        const char *candidate = g_object_get_data(G_OBJECT(node->data), "cwhip-tooltip");
        if (candidate && *candidate) {
            text = candidate;
            break;
        }
    }
    g_slist_free(marks);
    if (!text) return FALSE;
    gtk_tooltip_set_text(tooltip, text);
    return TRUE;
}

static void source_ensure_tooltips(GtkWidget *widget) {
    if (g_object_get_data(G_OBJECT(widget), "cwhip-tooltip-connected")) return;
    gtk_widget_set_has_tooltip(widget, TRUE);
    g_signal_connect(widget, "query-tooltip", G_CALLBACK(source_query_tooltip), NULL);
    g_object_set_data(G_OBJECT(widget), "cwhip-tooltip-connected", GINT_TO_POINTER(1));
}

static GtkTextTag *source_mark_tag(GtkTextBuffer *buffer, const char *category, const GdkRGBA *rgba) {
    char *name = g_strdup_printf("cwhip-mark:%s", category);
    GtkTextTagTable *table = gtk_text_buffer_get_tag_table(buffer);
    GtkTextTag *tag = gtk_text_tag_table_lookup(table, name);
    if (!tag) {
        tag = gtk_text_buffer_create_tag(buffer, name, "underline", PANGO_UNDERLINE_ERROR,
                                         "paragraph-background-rgba", rgba, NULL);
    } else {
        g_object_set(tag, "underline", PANGO_UNDERLINE_ERROR, "paragraph-background-rgba", rgba,
                     NULL);
    }
    g_free(name);
    return tag;
}

void cwhip_gtk_source_view_line_mark_tooltip(void *self, int64_t token, void *category_text,
                                             int64_t line, void *tooltip_text);

void cwhip_gtk_source_view_mark_style(void *self, int64_t token, void *category_text,
                                     void *icon_text, void *color_text, bool line_highlight) {
    (void)self;
    GtkSourceBuffer *buffer = source_buffer(token);
    GtkWidget *widget = widget_live(token);
    char *category = text_copy(category_text), *icon = text_copy(icon_text);
    char *color = text_copy(color_text);
    GdkRGBA rgba;
    if (!*category || !gdk_rgba_parse(&rgba, color)) fatal("invalid source mark style");
    GtkSourceMarkAttributes *attributes = gtk_source_mark_attributes_new();
    gtk_source_mark_attributes_set_icon_name(attributes, icon);
    /* Background tints the gutter cell and, with a line tag, the paragraph. Skip both
     * when line_highlight is false so marks stay as icons only. */
    if (line_highlight) gtk_source_mark_attributes_set_background(attributes, &rgba);
    g_signal_connect(attributes, "query-tooltip-text", G_CALLBACK(mark_tooltip_text), NULL);
    gtk_source_view_set_mark_attributes(GTK_SOURCE_VIEW(widget), category, attributes, 10);
    gtk_source_view_set_show_line_marks(GTK_SOURCE_VIEW(widget), TRUE);
    char *highlight_key = g_strdup_printf("cwhip-mark-highlight:%s", category);
    /* Avoid GINT_TO_POINTER(0): g_object_set_data treats NULL as "remove key". */
    g_object_set_data(G_OBJECT(widget), g_intern_string(highlight_key),
                      GINT_TO_POINTER(line_highlight ? 1 : 2));
    g_free(highlight_key);
    char *tag_name = g_strdup_printf("cwhip-mark:%s", category);
    GtkTextTag *existing =
        gtk_text_tag_table_lookup(gtk_text_buffer_get_tag_table(GTK_TEXT_BUFFER(buffer)), tag_name);
    if (existing) {
        GtkTextIter start, end;
        gtk_text_buffer_get_bounds(GTK_TEXT_BUFFER(buffer), &start, &end);
        gtk_text_buffer_remove_tag(GTK_TEXT_BUFFER(buffer), existing, &start, &end);
    }
    g_free(tag_name);
    if (line_highlight) source_mark_tag(GTK_TEXT_BUFFER(buffer), category, &rgba);
    source_ensure_tooltips(widget);
    char *color_key = g_strdup_printf("cwhip-mark-color:%s", category);
    g_object_set_data_full(G_OBJECT(widget), g_intern_string(color_key), gdk_rgba_copy(&rgba),
                           (GDestroyNotify)gdk_rgba_free);
    g_free(color_key);
    g_object_unref(attributes);
    g_free(category);
    g_free(icon);
    g_free(color);
}

void cwhip_gtk_source_view_line_mark(void *self, int64_t token, void *category_text, int64_t line) {
    cwhip_gtk_source_view_line_mark_tooltip(self, token, category_text, line, NULL);
}

void cwhip_gtk_source_view_line_mark_tooltip(void *self, int64_t token, void *category_text,
                                             int64_t line, void *tooltip_text) {
    (void)self;
    GtkSourceBuffer *buffer = source_buffer(token);
    GtkWidget *widget = widget_live(token);
    char *category = text_copy(category_text);
    char *tooltip = tooltip_text ? text_copy(tooltip_text) : g_strdup("");
    if (!*category || line < 1 || line > G_MAXINT) fatal("invalid source mark");
    if (line <= gtk_text_buffer_get_line_count(GTK_TEXT_BUFFER(buffer))) {
        GtkTextIter start, end;
        gtk_text_buffer_get_iter_at_line(GTK_TEXT_BUFFER(buffer), &start, line - 1);
        end = start;
        if (!gtk_text_iter_ends_line(&end)) gtk_text_iter_forward_to_line_end(&end);
        GSList *marks = gtk_source_buffer_get_source_marks_at_line(buffer, line - 1, category);
        GtkSourceMark *mark = marks ? marks->data : NULL;
        if (!mark) mark = gtk_source_buffer_create_source_mark(buffer, NULL, category, &start);
        g_slist_free(marks);
        if (*tooltip)
            g_object_set_data_full(G_OBJECT(mark), "cwhip-tooltip", g_strdup(tooltip), g_free);
        else g_object_set_data(G_OBJECT(mark), "cwhip-tooltip", NULL);
        char *highlight_key = g_strdup_printf("cwhip-mark-highlight:%s", category);
        bool line_highlight =
            GPOINTER_TO_INT(g_object_get_data(G_OBJECT(widget), g_intern_string(highlight_key))) == 1;
        g_free(highlight_key);
        char *color_key = g_strdup_printf("cwhip-mark-color:%s", category);
        GdkRGBA *rgba = g_object_get_data(G_OBJECT(widget), g_intern_string(color_key));
        g_free(color_key);
        if (line_highlight && rgba) {
            GtkTextTag *tag = source_mark_tag(GTK_TEXT_BUFFER(buffer), category, rgba);
            gtk_text_buffer_apply_tag(GTK_TEXT_BUFFER(buffer), tag, &start, &end);
        }
        source_ensure_tooltips(widget);
    }
    g_free(category);
    g_free(tooltip);
}

void cwhip_gtk_source_view_clear_marks(void *self, int64_t token, void *category_text) {
    (void)self;
    GtkSourceBuffer *buffer = source_buffer(token);
    char *category = text_copy(category_text);
    if (!*category) fatal("invalid source mark category");
    GtkTextIter start, end;
    gtk_text_buffer_get_bounds(GTK_TEXT_BUFFER(buffer), &start, &end);
    gtk_source_buffer_remove_source_marks(buffer, &start, &end, category);
    char *tag_name = g_strdup_printf("cwhip-mark:%s", category);
    GtkTextTag *tag = gtk_text_tag_table_lookup(gtk_text_buffer_get_tag_table(GTK_TEXT_BUFFER(buffer)),
                                                tag_name);
    if (tag) gtk_text_buffer_remove_tag(GTK_TEXT_BUFFER(buffer), tag, &start, &end);
    g_free(tag_name);
    g_free(category);
}

bool cwhip_gtk_source_view_bind_shortcut(void *self, int64_t token, void *trigger_text,
                                        void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires GtkSourceView");
    return shortcut_bind(widget, token, trigger_text, callback, GTK_SHORTCUT_SCOPE_LOCAL);
}

bool cwhip_gtk_source_view_has_shortcut(void *self, int64_t token, void *trigger_text) {
    (void)self;
    WidgetRecord *record = record_find(token);
    if (!GTK_SOURCE_IS_VIEW(record->widget)) fatal("operation requires GtkSourceView");
    return shortcut_bound(record, trigger_text);
}

void cwhip_gtk_source_view_set_text(void *self, int64_t token, void *text) {
    (void)self;
    char *bytes = text_copy(text);
    gtk_text_buffer_set_text(GTK_TEXT_BUFFER(source_buffer(token)), bytes, -1);
    g_free(bytes);
}

void *cwhip_gtk_source_view_get_text(void *self, int64_t token) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter start, end;
    gtk_text_buffer_get_bounds(buffer, &start, &end);
    char *text = gtk_text_buffer_get_text(buffer, &start, &end, TRUE);
    void *result = cwhip_string_new(&cwhip_string_class_meta, text, strlen(text));
    g_free(text);
    return result;
}

bool cwhip_gtk_source_view_modified(void *self, int64_t token) {
    (void)self;
    return gtk_text_buffer_get_modified(GTK_TEXT_BUFFER(source_buffer(token))) != FALSE;
}

void cwhip_gtk_source_view_mark_saved(void *self, int64_t token) {
    (void)self;
    gtk_text_buffer_set_modified(GTK_TEXT_BUFFER(source_buffer(token)), FALSE);
}

void cwhip_gtk_source_view_undo(void *self, int64_t token) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    if (gtk_text_buffer_get_can_undo(buffer)) gtk_text_buffer_undo(buffer);
}

void cwhip_gtk_source_view_redo(void *self, int64_t token) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    if (gtk_text_buffer_get_can_redo(buffer)) gtk_text_buffer_redo(buffer);
}

/* Removes trailing spaces and tabs from every line as one undoable action. */
bool cwhip_gtk_source_view_strip_trailing_spaces(void *self, int64_t token) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    bool changed = false;
    gtk_text_buffer_begin_user_action(buffer);
    int lines = gtk_text_buffer_get_line_count(buffer);
    for (int line = 0; line < lines; ++line) {
        GtkTextIter end, start;
        gtk_text_buffer_get_iter_at_line(buffer, &end, line);
        if (!gtk_text_iter_ends_line(&end)) gtk_text_iter_forward_to_line_end(&end);
        start = end;
        while (!gtk_text_iter_starts_line(&start)) {
            GtkTextIter previous = start;
            gtk_text_iter_backward_char(&previous);
            gunichar c = gtk_text_iter_get_char(&previous);
            if (c != ' ' && c != '\t') break;
            start = previous;
        }
        if (!gtk_text_iter_equal(&start, &end)) {
            gtk_text_buffer_delete(buffer, &start, &end);
            changed = true;
        }
    }
    gtk_text_buffer_end_user_action(buffer);
    return changed;
}

#define AUTO_PAIR_ENABLED "cwhip-auto-pair-enabled"
#define AUTO_PAIR_CONTROLLER "cwhip-auto-pair-controller"

static gunichar pair_close(gunichar c) {
    switch (c) {
    case '(': return ')';
    case '[': return ']';
    case '{': return '}';
    case '"': return '"';
    case '\'': return '\'';
    default: return 0;
    }
}

static gboolean auto_pair_key(GtkEventControllerKey *controller, guint keyval, guint keycode,
                              GdkModifierType state, gpointer data) {
    (void)keycode;
    (void)data;
    GtkWidget *widget = gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(controller));
    if (!g_object_get_data(G_OBJECT(widget), AUTO_PAIR_ENABLED)) return FALSE;
    if (!gtk_text_view_get_editable(GTK_TEXT_VIEW(widget))) return FALSE;
    if (state & (GDK_CONTROL_MASK | GDK_SUPER_MASK | GDK_META_MASK)) return FALSE;
    gunichar c = gdk_keyval_to_unicode(keyval);
    if (keyval != GDK_KEY_BackSpace &&
        c != '(' && c != ')' && c != '[' && c != ']' &&
        c != '{' && c != '}' && c != '"' && c != '\'') return FALSE;
    GtkTextBuffer *buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget));
    GtkTextIter start, end;
    bool selected = gtk_text_buffer_get_selection_bounds(buffer, &start, &end);
    gunichar next = gtk_text_iter_get_char(&end);
    gunichar previous = 0;
    GtkTextIter before = start;
    if (gtk_text_iter_backward_char(&before)) previous = gtk_text_iter_get_char(&before);
    if (keyval == GDK_KEY_BackSpace) {
        if (selected || !previous || pair_close(previous) == 0 || pair_close(previous) != next)
            return FALSE;
        GtkTextIter after = end;
        gtk_text_iter_forward_char(&after);
        gtk_text_buffer_begin_user_action(buffer);
        gtk_text_buffer_delete(buffer, &before, &after);
        gtk_text_buffer_end_user_action(buffer);
        return TRUE;
    }
    if (!c) return FALSE;
    bool closing = c == ')' || c == ']' || c == '}' || c == '"' || c == '\'';
    if (closing && !selected && next == c) {
        GtkTextIter after = end;
        gtk_text_iter_forward_char(&after);
        gtk_text_buffer_place_cursor(buffer, &after);
        return TRUE;
    }
    gunichar close = pair_close(c);
    if (!close) return FALSE;
    /* Apostrophes inside words (don't, it's) are not quote pairs. */
    if (!selected && c == '\'' && previous && g_unichar_isalnum(previous)) return FALSE;
    char open_text[8] = {0}, close_text[8] = {0};
    g_unichar_to_utf8(c, open_text);
    g_unichar_to_utf8(close, close_text);
    gtk_text_buffer_begin_user_action(buffer);
    if (selected) {
        GtkTextMark *first = gtk_text_buffer_create_mark(buffer, NULL, &start, TRUE);
        GtkTextMark *last = gtk_text_buffer_create_mark(buffer, NULL, &end, FALSE);
        gtk_text_buffer_insert(buffer, &end, close_text, -1);
        gtk_text_buffer_get_iter_at_mark(buffer, &start, first);
        gtk_text_buffer_insert(buffer, &start, open_text, -1);
        gtk_text_buffer_get_iter_at_mark(buffer, &start, first);
        gtk_text_iter_forward_char(&start);
        gtk_text_buffer_get_iter_at_mark(buffer, &end, last);
        gtk_text_iter_backward_char(&end);
        gtk_text_buffer_select_range(buffer, &start, &end);
        gtk_text_buffer_delete_mark(buffer, first);
        gtk_text_buffer_delete_mark(buffer, last);
    } else {
        gtk_text_buffer_insert(buffer, &start, open_text, -1);
        GtkTextMark *cursor = gtk_text_buffer_create_mark(buffer, NULL, &start, TRUE);
        gtk_text_buffer_insert(buffer, &start, close_text, -1);
        gtk_text_buffer_get_iter_at_mark(buffer, &start, cursor);
        gtk_text_buffer_place_cursor(buffer, &start);
        gtk_text_buffer_delete_mark(buffer, cursor);
    }
    gtk_text_buffer_end_user_action(buffer);
    gtk_text_view_scroll_mark_onscreen(GTK_TEXT_VIEW(widget), gtk_text_buffer_get_insert(buffer));
    return TRUE;
}

void cwhip_gtk_source_view_auto_pair(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires GtkSourceView");
    if (!g_object_get_data(G_OBJECT(widget), AUTO_PAIR_CONTROLLER)) {
        GtkEventController *controller = gtk_event_controller_key_new();
        gtk_event_controller_set_propagation_phase(controller, GTK_PHASE_CAPTURE);
        g_signal_connect(controller, "key-pressed", G_CALLBACK(auto_pair_key), NULL);
        gtk_widget_add_controller(widget, controller);
        g_object_set_data(G_OBJECT(widget), AUTO_PAIR_CONTROLLER, controller);
    }
    g_object_set_data(G_OBJECT(widget), AUTO_PAIR_ENABLED, GINT_TO_POINTER(enabled ? 1 : 0));
}

#define SELECTED_LINES_ENABLED "cwhip-selected-lines-enabled"
#define SELECTED_LINES_CONTROLLER "cwhip-selected-lines-controller"

static gboolean selected_lines_key(GtkEventControllerKey *controller, guint keyval, guint keycode,
                                   GdkModifierType state, gpointer data) {
    (void)keycode;
    (void)data;
    GtkWidget *widget = gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(controller));
    if (!g_object_get_data(G_OBJECT(widget), SELECTED_LINES_ENABLED)) return FALSE;
    if (!gtk_text_view_get_editable(GTK_TEXT_VIEW(widget))) return FALSE;
    if (state & (GDK_CONTROL_MASK | GDK_ALT_MASK | GDK_SUPER_MASK | GDK_META_MASK)) return FALSE;
    GtkTextBuffer *buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget));
    GtkTextIter start, end;
    if (!gtk_text_buffer_get_selection_bounds(buffer, &start, &end)) return FALSE;
    int start_line = gtk_text_iter_get_line(&start);
    int end_line = gtk_text_iter_get_line(&end);
    int start_col = gtk_text_iter_get_line_offset(&start);
    if (gtk_text_iter_get_line_offset(&end) == 0 && end_line > start_line) --end_line;
    if (end_line <= start_line) return FALSE;
    gunichar c = gdk_keyval_to_unicode(keyval);
    bool backspace = keyval == GDK_KEY_BackSpace;
    bool del = keyval == GDK_KEY_Delete;
    if (!backspace && !del && (c < 32 || g_unichar_iscntrl(c))) return FALSE;
    if (keyval == GDK_KEY_Return || keyval == GDK_KEY_Tab || keyval == GDK_KEY_ISO_Left_Tab)
        return FALSE;
    char insert[8] = {0};
    if (!backspace && !del) g_unichar_to_utf8(c, insert);
    gtk_text_buffer_begin_user_action(buffer);
    for (int line = end_line; line >= start_line; --line) {
        GtkTextIter at;
        gtk_text_buffer_get_iter_at_line(buffer, &at, line);
        int length = gtk_text_iter_ends_line(&at) ? 0 : gtk_text_iter_get_chars_in_line(&at);
        if (length && gtk_text_iter_get_line(&at) < gtk_text_buffer_get_line_count(buffer) - 1)
            --length;
        int col = start_col;
        if (col > length) col = length;
        gtk_text_iter_set_line_offset(&at, col);
        if (backspace) {
            if (col <= 0) continue;
            GtkTextIter before = at;
            gtk_text_iter_backward_char(&before);
            gtk_text_buffer_delete(buffer, &before, &at);
        } else if (del) {
            if (col >= length) continue;
            GtkTextIter after = at;
            gtk_text_iter_forward_char(&after);
            gtk_text_buffer_delete(buffer, &at, &after);
        } else {
            gtk_text_buffer_insert(buffer, &at, insert, -1);
        }
    }
    gtk_text_buffer_get_iter_at_line_offset(buffer, &start, start_line, start_col);
    int end_col = start_col;
    if (!backspace && !del) end_col = start_col + 1;
    gtk_text_buffer_get_iter_at_line(buffer, &end, end_line);
    int end_length = gtk_text_iter_ends_line(&end) ? 0 : gtk_text_iter_get_chars_in_line(&end);
    if (end_length && gtk_text_iter_get_line(&end) < gtk_text_buffer_get_line_count(buffer) - 1)
        --end_length;
    if (end_col > end_length) end_col = end_length;
    gtk_text_iter_set_line_offset(&end, end_col);
    gtk_text_buffer_select_range(buffer, &start, &end);
    gtk_text_buffer_end_user_action(buffer);
    return TRUE;
}

void cwhip_gtk_source_view_selected_lines_edit(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires GtkSourceView");
    if (!g_object_get_data(G_OBJECT(widget), SELECTED_LINES_CONTROLLER)) {
        GtkEventController *controller = gtk_event_controller_key_new();
        gtk_event_controller_set_propagation_phase(controller, GTK_PHASE_CAPTURE);
        g_signal_connect(controller, "key-pressed", G_CALLBACK(selected_lines_key), NULL);
        gtk_widget_add_controller(widget, controller);
        g_object_set_data(G_OBJECT(widget), SELECTED_LINES_CONTROLLER, controller);
    }
    g_object_set_data(G_OBJECT(widget), SELECTED_LINES_ENABLED, GINT_TO_POINTER(enabled ? 1 : 0));
}

bool cwhip_gtk_source_view_can_undo(void *self, int64_t token) {
    (void)self;
    return gtk_text_buffer_get_can_undo(GTK_TEXT_BUFFER(source_buffer(token))) != FALSE;
}

bool cwhip_gtk_source_view_can_redo(void *self, int64_t token) {
    (void)self;
    return gtk_text_buffer_get_can_redo(GTK_TEXT_BUFFER(source_buffer(token))) != FALSE;
}

bool cwhip_gtk_source_view_has_selection(void *self, int64_t token) {
    (void)self;
    return gtk_text_buffer_get_has_selection(GTK_TEXT_BUFFER(source_buffer(token))) != FALSE;
}

void cwhip_gtk_source_view_edit(void *self, int64_t token, int64_t operation) {
    (void)self;
    GtkTextBuffer *buffer = g_object_ref(GTK_TEXT_BUFFER(source_buffer(token)));
    GtkWidget *widget = g_object_ref(widget_live(token));
    GdkClipboard *clipboard = gtk_widget_get_clipboard(widget);
    bool editable = gtk_text_view_get_editable(GTK_TEXT_VIEW(widget));
    if (operation == 0) gtk_text_buffer_cut_clipboard(buffer, clipboard, editable);
    else if (operation == 1) gtk_text_buffer_copy_clipboard(buffer, clipboard);
    else if (operation == 2) gtk_text_buffer_paste_clipboard(buffer, clipboard, NULL, editable);
    else if (operation == 3) {
        GtkTextIter start, end;
        gtk_text_buffer_get_bounds(buffer, &start, &end);
        gtk_text_buffer_select_range(buffer, &start, &end);
    } else fatal("invalid source editing operation");
    g_object_unref(widget);
    g_object_unref(buffer);
}

void cwhip_gtk_source_view_monospace(void *self, int64_t token, bool monospace) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires GtkSourceView");
    gtk_text_view_set_monospace(GTK_TEXT_VIEW(widget), monospace);
}

void cwhip_gtk_source_view_clear_shortcuts(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    WidgetRecord *record = record_find(token);
    while (record->shortcuts) {
        ShortcutBinding *binding = record->shortcuts;
        record->shortcuts = binding->next;
        binding->owner = NULL;
        shortcut_release(binding);
        gtk_widget_remove_controller(widget, binding->controller);
    }
}

void cwhip_gtk_source_view_configure(void *self, int64_t token, void *font_text,
                                   int64_t size, int64_t tabs, bool spaces,
                                   bool numbers, bool wrap, bool highlight) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires GtkSourceView");
    if (size < 6 || size > 72 || tabs < 1 || tabs > 16) fatal("invalid source view settings");
    char *font = text_copy(font_text);
    /* CSS quoting prevents a user-editable font name from injecting rules. */
    GString *quoted = g_string_new("\"");
    for (const char *p = font; *p; ++p) {
        if (*p == '\\' || *p == '"') g_string_append_c(quoted, '\\');
        g_string_append_c(quoted, *p);
    }
    g_string_append_c(quoted, '"');
    char *style_class = g_strdup_printf("cwhip-font-%" G_GINT64_FORMAT, token);
    char *css = g_strdup_printf("textview.%s { font-family: %s; font-size: %" G_GINT64_FORMAT
                               "pt; }", style_class, quoted->str, size);
    const char *previous_css = g_object_get_data(G_OBJECT(widget), "cwhip-font-css");
    if (g_strcmp0(previous_css, css) != 0) {
        GtkCssProvider *provider = gtk_css_provider_new();
#if GTK_CHECK_VERSION(4, 12, 0)
        gtk_css_provider_load_from_string(provider, css);
#else
        gtk_css_provider_load_from_data(provider, css, -1);
#endif
        GdkDisplay *display = gtk_widget_get_display(widget);
        g_object_set_data_full(G_OBJECT(provider), "cwhip-css-display",
                               g_object_ref(display), g_object_unref);
        g_object_set_data(G_OBJECT(widget), "cwhip-font-provider", NULL);
        gtk_widget_add_css_class(widget, style_class);
        gtk_style_context_add_provider_for_display(display, GTK_STYLE_PROVIDER(provider),
                                                   GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
        g_object_set_data_full(G_OBJECT(widget), "cwhip-font-provider", provider, css_provider_release);
        g_object_set_data_full(G_OBJECT(widget), "cwhip-font-css", g_strdup(css), g_free);
    }
    gtk_text_view_set_monospace(GTK_TEXT_VIEW(widget), TRUE);
    gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(widget), wrap ? GTK_WRAP_WORD_CHAR : GTK_WRAP_NONE);
    gtk_source_view_set_tab_width(GTK_SOURCE_VIEW(widget), (guint)tabs);
    gtk_source_view_set_insert_spaces_instead_of_tabs(GTK_SOURCE_VIEW(widget), spaces);
    gtk_source_view_set_show_line_numbers(GTK_SOURCE_VIEW(widget), numbers);
    gtk_source_view_set_highlight_current_line(GTK_SOURCE_VIEW(widget), highlight);
    g_free(font);
    g_free(css);
    g_free(style_class);
    g_string_free(quoted, TRUE);
}

static CwhipSourceView *cwhip_source(int64_t token) {
    GtkWidget *widget = widget_live(token);
    if (!G_TYPE_CHECK_INSTANCE_TYPE(widget, cwhip_source_view_get_type()))
        fatal("operation requires GtkSourceView");
    return (CwhipSourceView *)widget;
}

static void source_apply_space_drawer(CwhipSourceView *view) {
    GtkSourceSpaceDrawer *drawer = gtk_source_view_get_space_drawer(GTK_SOURCE_VIEW(view));
    GtkSourceSpaceTypeFlags types = GTK_SOURCE_SPACE_TYPE_NONE;
    if (view->show_spaces) {
        types |= GTK_SOURCE_SPACE_TYPE_SPACE | GTK_SOURCE_SPACE_TYPE_TAB |
                 GTK_SOURCE_SPACE_TYPE_NBSP;
    }
    if (view->show_line_ends) types |= GTK_SOURCE_SPACE_TYPE_NEWLINE;
    /* Types alone do nothing until the matrix is enabled. */
    gtk_source_space_drawer_set_enable_matrix(drawer, types != GTK_SOURCE_SPACE_TYPE_NONE);
    gtk_source_space_drawer_set_types_for_locations(drawer, GTK_SOURCE_SPACE_LOCATION_ALL, types);
}

void cwhip_gtk_source_view_show_whitespace(void *self, int64_t token, bool show) {
    (void)self;
    CwhipSourceView *view = cwhip_source(token);
    view->show_spaces = show;
    source_apply_space_drawer(view);
}

void cwhip_gtk_source_view_show_line_ends(void *self, int64_t token, bool show) {
    (void)self;
    CwhipSourceView *view = cwhip_source(token);
    view->show_line_ends = show;
    source_apply_space_drawer(view);
}

void cwhip_gtk_source_view_show_indent(void *self, int64_t token, bool show) {
    (void)self;
    CwhipSourceView *view = cwhip_source(token);
    view->indent_markers = show;
    gtk_widget_queue_draw(GTK_WIDGET(view));
}

bool cwhip_gtk_source_view_indent_visible(void *self, int64_t token) {
    (void)self;
    return cwhip_source(token)->indent_markers;
}

/* Search option bits shared with GtkSource.View in sourceview.cw. */
enum {
    SEARCH_CASE_SENSITIVE = 1,
    SEARCH_WHOLE_WORDS = 2,
    SEARCH_IN_SELECTION = 4,
    SEARCH_BACKWARD = 8,
};

/* The "in selection" scope and the last match are buffer marks so they track
 * edits: the scope start has left gravity and its end right gravity, so text
 * replaced at either boundary stays inside the scope. */
#define SCOPE_START "cwhip-search-scope-start"
#define SCOPE_END "cwhip-search-scope-end"
#define MATCH_START "cwhip-search-match-start"
#define MATCH_END "cwhip-search-match-end"

static void mark_set(GtkTextBuffer *buffer, const char *name, const GtkTextIter *where,
                     gboolean left_gravity) {
    GtkTextMark *mark = gtk_text_buffer_get_mark(buffer, name);
    if (mark) gtk_text_buffer_move_mark(buffer, mark, where);
    else gtk_text_buffer_create_mark(buffer, name, where, left_gravity);
}

static bool mark_iter(GtkTextBuffer *buffer, const char *name, GtkTextIter *iter) {
    GtkTextMark *mark = gtk_text_buffer_get_mark(buffer, name);
    if (!mark) return false;
    gtk_text_buffer_get_iter_at_mark(buffer, iter, mark);
    return true;
}

static void mark_clear(GtkTextBuffer *buffer, const char *name) {
    GtkTextMark *mark = gtk_text_buffer_get_mark(buffer, name);
    if (mark) gtk_text_buffer_delete_mark(buffer, mark);
}

static bool word_char(gunichar c) { return g_unichar_isalnum(c) || c == '_'; }

static bool at_word_bounds(const GtkTextIter *start, const GtkTextIter *end) {
    GtkTextIter before = *start;
    if (gtk_text_iter_backward_char(&before) && word_char(gtk_text_iter_get_char(&before)))
        return false;
    return gtk_text_iter_is_end(end) || !word_char(gtk_text_iter_get_char(end));
}

static bool search_bounds(GtkTextBuffer *buffer, int64_t flags, GtkTextIter *low,
                          GtkTextIter *high) {
    if (!(flags & SEARCH_IN_SELECTION)) {
        gtk_text_buffer_get_bounds(buffer, low, high);
        return true;
    }
    return mark_iter(buffer, SCOPE_START, low) && mark_iter(buffer, SCOPE_END, high) &&
           gtk_text_iter_compare(low, high) < 0;
}

static bool search_range(GtkTextIter from, const GtkTextIter *high, const char *query,
                         int64_t flags, GtkTextIter *match_start, GtkTextIter *match_end) {
    GtkTextSearchFlags mode = flags & SEARCH_CASE_SENSITIVE ? 0 : GTK_TEXT_SEARCH_CASE_INSENSITIVE;
    while (gtk_text_iter_compare(&from, high) < 0) {
        if (!gtk_text_iter_forward_search(&from, query, mode, match_start, match_end, high))
            return false;
        if (!(flags & SEARCH_WHOLE_WORDS) || at_word_bounds(match_start, match_end)) return true;
        from = *match_start;
        if (!gtk_text_iter_forward_char(&from)) return false;
    }
    return false;
}

static bool search_range_backward(GtkTextIter from, const GtkTextIter *low, const char *query,
                                  int64_t flags, GtkTextIter *match_start,
                                  GtkTextIter *match_end) {
    GtkTextSearchFlags mode = flags & SEARCH_CASE_SENSITIVE ? 0 : GTK_TEXT_SEARCH_CASE_INSENSITIVE;
    while (gtk_text_iter_compare(&from, low) > 0) {
        if (!gtk_text_iter_backward_search(&from, query, mode, match_start, match_end, low))
            return false;
        if (!(flags & SEARCH_WHOLE_WORDS) || at_word_bounds(match_start, match_end)) return true;
        from = *match_end;
        if (!gtk_text_iter_backward_char(&from)) return false;
    }
    return false;
}

static bool selection_matches(GtkTextBuffer *buffer, const char *query, int64_t flags,
                              GtkTextIter *start, GtkTextIter *end) {
    GtkTextIter low, high, match_start, match_end;
    if (!gtk_text_buffer_get_selection_bounds(buffer, start, end)) return false;
    if (!search_bounds(buffer, flags, &low, &high)) return false;
    if (gtk_text_iter_compare(start, &low) < 0 || gtk_text_iter_compare(end, &high) > 0)
        return false;
    return search_range(*start, end, query, flags, &match_start, &match_end) &&
           gtk_text_iter_equal(&match_start, start) && gtk_text_iter_equal(&match_end, end);
}

static bool source_find(int64_t token, const char *query, int64_t flags) {
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter low, high, from, selection_end, match_start, match_end;
    if (!*query || !search_bounds(buffer, flags, &low, &high)) return false;
    bool backward = flags & SEARCH_BACKWARD;
    if (!gtk_text_buffer_get_selection_bounds(buffer, &from, &selection_end))
        gtk_text_buffer_get_iter_at_mark(buffer, &from, gtk_text_buffer_get_insert(buffer));
    else if (!backward) from = selection_end;
    bool found;
    if (backward) {
        if (gtk_text_iter_compare(&from, &low) < 0 || gtk_text_iter_compare(&from, &high) > 0)
            from = high;
        found = search_range_backward(from, &low, query, flags, &match_start, &match_end);
        if (!found && !gtk_text_iter_equal(&from, &high))
            found = search_range_backward(high, &low, query, flags, &match_start, &match_end);
    } else {
        if (gtk_text_iter_compare(&from, &low) < 0 || gtk_text_iter_compare(&from, &high) > 0)
            from = low;
        found = search_range(from, &high, query, flags, &match_start, &match_end);
        if (!found && !gtk_text_iter_equal(&from, &low))
            found = search_range(low, &high, query, flags, &match_start, &match_end);
    }
    if (found) {
        gtk_text_buffer_select_range(buffer, &match_start, &match_end);
        mark_set(buffer, MATCH_START, &match_start, TRUE);
        mark_set(buffer, MATCH_END, &match_end, FALSE);
        gtk_text_view_scroll_to_iter(GTK_TEXT_VIEW(widget_live(token)), &match_start, 0.1,
                                     FALSE, 0, 0);
    }
    return found;
}

bool cwhip_gtk_source_view_search(void *self, int64_t token, void *needle, int64_t flags) {
    (void)self;
    char *query = text_copy(needle);
    bool found = source_find(token, query, flags);
    g_free(query);
    return found;
}

bool cwhip_gtk_source_view_find(void *self, int64_t token, void *needle) {
    return cwhip_gtk_source_view_search(self, token, needle, 0);
}

bool cwhip_gtk_source_view_replace(void *self, int64_t token, void *needle, void *replacement,
                                  int64_t flags) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    char *query = text_copy(needle);
    char *text = text_copy(replacement);
    GtkTextIter start, end;
    bool replaced = false;
    if (*query && (selection_matches(buffer, query, flags, &start, &end) ||
                   (source_find(token, query, flags) &&
                    gtk_text_buffer_get_selection_bounds(buffer, &start, &end)))) {
        gtk_text_buffer_begin_user_action(buffer);
        gtk_text_buffer_delete(buffer, &start, &end);
        gtk_text_buffer_insert(buffer, &start, text, -1);
        gtk_text_buffer_end_user_action(buffer);
        replaced = true;
    }
    g_free(text);
    g_free(query);
    return replaced;
}

bool cwhip_gtk_source_view_replace_next(void *self, int64_t token, void *needle, void *replacement) {
    return cwhip_gtk_source_view_replace(self, token, needle, replacement, 0);
}

/* Replaces every match in the search range as one undoable action. Matches
 * are found after the previous replacement, so replacement text containing
 * the query is never matched again. */
int64_t cwhip_gtk_source_view_replace_all(void *self, int64_t token, void *needle,
                                         void *replacement, int64_t flags) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    char *query = text_copy(needle);
    char *text = text_copy(replacement);
    GtkTextIter low, high, match_start, match_end;
    int64_t count = 0;
    if (*query && search_bounds(buffer, flags, &low, &high)) {
        GtkTextMark *position = gtk_text_buffer_create_mark(buffer, NULL, &low, FALSE);
        gtk_text_buffer_begin_user_action(buffer);
        for (;;) {
            GtkTextIter from;
            gtk_text_buffer_get_iter_at_mark(buffer, &from, position);
            if (!search_bounds(buffer, flags, &low, &high) ||
                !search_range(from, &high, query, flags, &match_start, &match_end)) break;
            gtk_text_buffer_delete(buffer, &match_start, &match_end);
            gtk_text_buffer_insert(buffer, &match_start, text, -1);
            gtk_text_buffer_move_mark(buffer, position, &match_start);
            ++count;
        }
        gtk_text_buffer_end_user_action(buffer);
        gtk_text_buffer_delete_mark(buffer, position);
    }
    g_free(text);
    g_free(query);
    return count;
}

/* Captures the current selection as the "in selection" scope. Selecting a
 * Find result does not replace the scope, so Find/Replace can be reopened while
 * a match is selected; with no selection the scope is cleared. */
bool cwhip_gtk_source_view_capture_scope(void *self, int64_t token) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter start, end, match_start, match_end, scope_start;
    if (!gtk_text_buffer_get_selection_bounds(buffer, &start, &end)) {
        mark_clear(buffer, SCOPE_START);
        mark_clear(buffer, SCOPE_END);
        return false;
    }
    if (mark_iter(buffer, MATCH_START, &match_start) && mark_iter(buffer, MATCH_END, &match_end) &&
        gtk_text_iter_equal(&start, &match_start) && gtk_text_iter_equal(&end, &match_end))
        return mark_iter(buffer, SCOPE_START, &scope_start);
    mark_set(buffer, SCOPE_START, &start, TRUE);
    mark_set(buffer, SCOPE_END, &end, FALSE);
    return true;
}

bool cwhip_gtk_source_view_has_scope(void *self, int64_t token) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter low, high;
    return search_bounds(buffer, SEARCH_IN_SELECTION, &low, &high);
}

void *cwhip_gtk_source_view_selected_text(void *self, int64_t token) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter start, end;
    char *text = gtk_text_buffer_get_selection_bounds(buffer, &start, &end)
                     ? gtk_text_buffer_get_text(buffer, &start, &end, TRUE) : g_strdup("");
    void *result = cwhip_string_new(&cwhip_string_class_meta, text, strlen(text));
    g_free(text);
    return result;
}

int64_t cwhip_gtk_source_view_line(void *self, int64_t token) {
    (void)self;
    GtkTextIter cursor;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    gtk_text_buffer_get_iter_at_mark(buffer, &cursor, gtk_text_buffer_get_insert(buffer));
    return gtk_text_iter_get_line(&cursor) + 1;
}

static void source_cursor(int64_t token, int64_t line, int64_t column, bool center) {
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter cursor;
    int lines = gtk_text_buffer_get_line_count(buffer);
    if (line < 1) line = 1;
    if (line > lines) line = lines;
    gtk_text_buffer_get_iter_at_line(buffer, &cursor, (int)line - 1);
    int length = gtk_text_iter_ends_line(&cursor) ? 0 : gtk_text_iter_get_chars_in_line(&cursor);
    if (length && gtk_text_iter_get_line(&cursor) < lines - 1) --length;
    if (column < 1) column = 1;
    if (column - 1 > length) column = length + 1;
    gtk_text_iter_set_line_offset(&cursor, (int)column - 1);
    gtk_text_buffer_place_cursor(buffer, &cursor);
    GtkTextView *view = GTK_TEXT_VIEW(widget_live(token));
    if (center)
        gtk_text_view_scroll_to_mark(view, gtk_text_buffer_get_insert(buffer),
                                    0.0, TRUE, 0.0, 0.5);
    else
        gtk_text_view_scroll_mark_onscreen(view, gtk_text_buffer_get_insert(buffer));
}

/* Moves the insertion point to a 1-based line/column, clamped to the buffer. */
void cwhip_gtk_source_view_set_cursor(void *self, int64_t token, int64_t line, int64_t column) {
    (void)self;
    source_cursor(token, line, column, false);
}

void cwhip_gtk_source_view_center_cursor(void *self, int64_t token, int64_t line, int64_t column) {
    (void)self;
    source_cursor(token, line, column, true);
}

void cwhip_gtk_source_view_editable(void *self, int64_t token, bool editable) {
    (void)self;
    source_buffer(token);
    gtk_text_view_set_editable(GTK_TEXT_VIEW(widget_live(token)), editable);
}

int64_t cwhip_gtk_source_view_column(void *self, int64_t token) {
    (void)self;
    GtkTextIter cursor;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    gtk_text_buffer_get_iter_at_mark(buffer, &cursor, gtk_text_buffer_get_insert(buffer));
    return gtk_text_iter_get_line_offset(&cursor) + 1;
}

/* "" selects plain text (no highlighting). Other ids must name a language
 * definition shipped by the sourceview package; see doc/GTK.md. */
bool cwhip_gtk_source_view_language(void *self, int64_t token, void *language_id) {
    (void)self;
    char *id = text_copy(language_id);
    GtkSourceLanguage *language = NULL;
    if (*id && g_hash_table_contains(registered_languages, id))
        language = gtk_source_language_manager_get_language(source_language_manager, id);
    bool accepted = !*id || language;
    g_free(id);
    if (!accepted) return false;
    GtkSourceBuffer *buffer = source_buffer(token);
    GtkSourceView *view = GTK_SOURCE_VIEW(widget_live(token));
    gtk_source_buffer_set_language(buffer, language);
    gtk_source_buffer_set_highlight_syntax(buffer, language != NULL);
    gtk_source_view_set_show_line_numbers(view, TRUE);
    /* Tab width, spaces, and auto-indent are left to configure / setAutoIndent. */
    return true;
}

/* Copies the previous line's leading whitespace (GtkSource default), then adds
 * one indent level when that line ends with { or [. If Enter was pressed
 * between a matching pair ({|} or [|]), also opens a line for the closer. */
typedef struct {
    GObject parent_instance;
} CwhipBracketIndenter;

typedef struct {
    GObjectClass parent_class;
} CwhipBracketIndenterClass;

static void cwhip_bracket_indenter_iface_init(GtkSourceIndenterInterface *iface);

G_DEFINE_TYPE_WITH_CODE(CwhipBracketIndenter, cwhip_bracket_indenter, G_TYPE_OBJECT,
                        G_IMPLEMENT_INTERFACE(GTK_SOURCE_TYPE_INDENTER,
                                              cwhip_bracket_indenter_iface_init))

static gboolean cwhip_bracket_char_is_space(gunichar ch) {
    return ch != '\n' && ch != '\r' && g_unichar_isspace(ch);
}

static gboolean cwhip_bracket_indenter_is_trigger(GtkSourceIndenter *self, GtkSourceView *view,
                                                  const GtkTextIter *location, GdkModifierType state,
                                                  guint keyval) {
    (void)self;
    (void)view;
    if ((state & (GDK_SHIFT_MASK | GDK_CONTROL_MASK | GDK_SUPER_MASK)) != 0) return FALSE;
    if (keyval != GDK_KEY_Return && keyval != GDK_KEY_KP_Enter) return FALSE;
    if (gtk_text_iter_starts_line(location)) return FALSE;
    return !gtk_text_buffer_get_has_selection(gtk_text_iter_get_buffer(location));
}

static char *cwhip_indent_unit_for_view(GtkSourceView *view) {
    guint tab = gtk_source_view_get_tab_width(view);
    if (tab < 1) tab = 4;
    int width = gtk_source_view_get_indent_width(view);
    if (width < 1) width = (int)tab;
    if (gtk_source_view_get_insert_spaces_instead_of_tabs(view))
        return g_strnfill((gsize)width, ' ');
    return g_strdup("\t");
}

static char *cwhip_copy_line_prefix(GtkTextBuffer *buffer, int line) {
    GtkTextIter begin, end;
    gtk_text_buffer_get_iter_at_line_offset(buffer, &begin, line, 0);
    end = begin;
    while (!gtk_text_iter_ends_line(&end) && cwhip_bracket_char_is_space(gtk_text_iter_get_char(&end)) &&
           gtk_text_iter_forward_char(&end)) {
    }
    return gtk_text_iter_get_slice(&begin, &end);
}

static gunichar cwhip_previous_line_last_nonspace(GtkTextBuffer *buffer, int line) {
    if (line < 0) return 0;
    GtkTextIter end;
    gtk_text_buffer_get_iter_at_line(buffer, &end, line);
    if (!gtk_text_iter_ends_line(&end)) gtk_text_iter_forward_to_line_end(&end);
    while (!gtk_text_iter_starts_line(&end)) {
        GtkTextIter prev = end;
        if (!gtk_text_iter_backward_char(&prev)) break;
        gunichar ch = gtk_text_iter_get_char(&prev);
        if (!cwhip_bracket_char_is_space(ch)) return ch;
        end = prev;
    }
    return 0;
}

static void cwhip_bracket_indenter_indent(GtkSourceIndenter *self, GtkSourceView *view,
                                         GtkTextIter *location) {
    (void)self;
    GtkTextBuffer *buffer = gtk_text_iter_get_buffer(location);
    int line = gtk_text_iter_get_line(location);
    GtkTextIter begin = *location;
    if (!gtk_text_iter_starts_line(&begin)) gtk_text_iter_set_line_offset(&begin, 0);
    GtkTextIter end = *location;
    while (!gtk_text_iter_ends_line(&end) && cwhip_bracket_char_is_space(gtk_text_iter_get_char(&end)) &&
           gtk_text_iter_forward_char(&end)) {
    }
    if (!gtk_text_iter_equal(&begin, &end)) gtk_text_buffer_delete(buffer, &begin, &end);

    char *prefix = line > 0 ? cwhip_copy_line_prefix(buffer, line - 1) : g_strdup("");
    gunichar open = cwhip_previous_line_last_nonspace(buffer, line - 1);
    bool deeper = open == '{' || open == '[';
    char *unit = deeper ? cwhip_indent_unit_for_view(view) : NULL;
    char *indent = deeper ? g_strconcat(prefix, unit, NULL) : g_strdup(prefix);
    gtk_text_buffer_insert(buffer, &begin, indent, -1);
    *location = begin;

    gunichar expect_close = open == '{' ? '}' : open == '[' ? ']' : 0;
    if (expect_close && gtk_text_iter_get_char(location) == expect_close) {
        GtkTextMark *here = gtk_text_buffer_create_mark(buffer, NULL, location, TRUE);
        gtk_text_buffer_insert(buffer, location, "\n", 1);
        gtk_text_buffer_insert(buffer, location, prefix, -1);
        gtk_text_buffer_get_iter_at_mark(buffer, location, here);
        gtk_text_buffer_delete_mark(buffer, here);
    }

    g_free(prefix);
    g_free(unit);
    g_free(indent);
}

static void cwhip_bracket_indenter_iface_init(GtkSourceIndenterInterface *iface) {
    iface->is_trigger = cwhip_bracket_indenter_is_trigger;
    iface->indent = cwhip_bracket_indenter_indent;
}

static void cwhip_bracket_indenter_class_init(CwhipBracketIndenterClass *klass) { (void)klass; }
static void cwhip_bracket_indenter_init(CwhipBracketIndenter *self) { (void)self; }

static GtkSourceIndenter *cwhip_bracket_indenter_get(void) {
    static GtkSourceIndenter *singleton;
    if (!singleton) singleton = g_object_new(cwhip_bracket_indenter_get_type(), NULL);
    return singleton;
}

void cwhip_gtk_source_view_auto_indent(void *self, int64_t token, bool enabled) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_SOURCE_IS_VIEW(widget)) fatal("operation requires GtkSourceView");
    GtkSourceView *view = GTK_SOURCE_VIEW(widget);
    gtk_source_view_set_auto_indent(view, enabled);
    /* Replace the copy-only default indenter with bracket-aware indentation. */
    if (enabled) gtk_source_view_set_indenter(view, cwhip_bracket_indenter_get());
}

void *cwhip_gtk_source_view_language_id(void *self, int64_t token) {
    (void)self;
    GtkSourceLanguage *language = gtk_source_buffer_get_language(source_buffer(token));
    const char *id = language ? gtk_source_language_get_id(language) : "";
    return cwhip_string_new(&cwhip_string_class_meta, id, strlen(id));
}

/* Maps a file name to a registered language id using the globs/mimetypes
 * metadata in the package's .lang files, or "" for plain text. */
void *cwhip_gtk_source_language_for(void *self, void *path) {
    (void)self;
    require_live();
    char *name = text_copy(path);
    GtkSourceLanguage *language = *name
        ? gtk_source_language_manager_guess_language(source_language_manager, name, NULL) : NULL;
    const char *id = language ? gtk_source_language_get_id(language) : "";
    if (!g_hash_table_contains(registered_languages, id)) id = "";
    void *result = cwhip_string_new(&cwhip_string_class_meta, id, strlen(id));
    g_free(name);
    return result;
}

bool cwhip_gtk_source_is_text(void *self, void *data) {
    (void)self;
    const char *bytes;
    uint64_t length;
    cwhip_string_bytes(data, &bytes, &length);
    return length == 0 || !memchr(bytes, 0, length);
}

bool cwhip_gtk_source_view_has_context(void *self, int64_t token, void *context_name,
                                     int64_t offset) {
    (void)self;
    GtkSourceBuffer *buffer = source_buffer(token);
    GtkTextIter start, end, position;
    gtk_text_buffer_get_bounds(GTK_TEXT_BUFFER(buffer), &start, &end);
    gtk_source_buffer_ensure_highlight(buffer, &start, &end);
    if (offset < 0 || offset > gtk_text_iter_get_offset(&end))
        fatal("source context offset is out of range");
    gtk_text_buffer_get_iter_at_offset(GTK_TEXT_BUFFER(buffer), &position, (int)offset);
    char *name = text_copy(context_name);
    gboolean has_context = gtk_source_buffer_iter_has_context_class(buffer, &position, name);
    g_free(name);
    return has_context != FALSE;
}
#endif

static WidgetRecord *record_for_widget(GtkWidget *widget) {
    for (WidgetRecord *r = widgets; r; r = r->next)
        if (r->widget == widget) return r;
    return NULL;
}

static void draw_connection_destroy(gpointer data) {
    cwhip_gtk_require_owner();
    int acquired = cwhip_runtime_managed_enter();
    Connection *connection = data;
    connection->object = NULL;
    connection->closed = true;
    connection->detached = true;
    connection_collect(connection);
    cwhip_runtime_managed_leave(acquired);
}

static void drawing_area_draw(GtkDrawingArea *area, cairo_t *cr, int width, int height,
                              gpointer data) {
    Connection *connection = data;
    WidgetRecord *record = record_for_widget(GTK_WIDGET(area));
    int acquired = signal_enter(connection);
    if (record) record->draw_cr = cr;
    typedef void (*Adapter)(CwhipCallbackContext *, int64_t, int64_t);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, (int64_t)width, (int64_t)height);
    if (record) record->draw_cr = NULL;
    signal_leave(connection, acquired);
}

static void drawing_area_pointer_enter(GtkEventControllerMotion *controller, double x,
                                       double y, gpointer data) {
    (void)controller;
    WidgetRecord *record = data;
    record->pointer_x = x;
    record->pointer_y = y;
    record->pointer_inside = true;
}

static void drawing_area_pointer_leave(GtkEventControllerMotion *controller, gpointer data) {
    (void)controller;
    WidgetRecord *record = data;
    record->pointer_inside = false;
}

static void drawing_area_pointer_motion(GtkEventControllerMotion *controller, double x,
                                        double y, gpointer data) {
    (void)controller;
    WidgetRecord *record = data;
    record->pointer_x = x;
    record->pointer_y = y;
    record->pointer_inside = true;
}

static void drawing_area_click_released(GtkGestureClick *gesture, gint n_press, gdouble x,
                                        gdouble y, gpointer data) {
    if (n_press != 1) return;
    Connection *connection = data;
    guint button = gtk_gesture_single_get_current_button(GTK_GESTURE_SINGLE(gesture));
    WidgetRecord *record =
        record_for_widget(gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(gesture)));
    if (record) {
        record->pointer_x = x;
        record->pointer_y = y;
        record->pointer_inside = true;
    }
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, int64_t, double, double);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, (int64_t)button, x, y);
    signal_leave(connection, acquired);
}

static void drawing_area_drag_begin(GtkGestureDrag *gesture, gdouble x, gdouble y,
                                    gpointer data) {
    Connection *connection = data;
    WidgetRecord *record =
        record_for_widget(gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(gesture)));
    if (record) {
        record->pointer_x = x;
        record->pointer_y = y;
        record->pointer_inside = true;
    }
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, int64_t, double, double, double, double);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, 0, x, y, 0.0, 0.0);
    signal_leave(connection, acquired);
}

static void drawing_area_drag_update(GtkGestureDrag *gesture, gdouble offset_x,
                                     gdouble offset_y, gpointer data) {
    Connection *connection = data;
    double start_x = 0.0;
    double start_y = 0.0;
    gtk_gesture_drag_get_start_point(gesture, &start_x, &start_y);
    WidgetRecord *record =
        record_for_widget(gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(gesture)));
    if (record) {
        record->pointer_x = start_x + offset_x;
        record->pointer_y = start_y + offset_y;
        record->pointer_inside = true;
    }
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, int64_t, double, double, double, double);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, 1, start_x, start_y, offset_x, offset_y);
    signal_leave(connection, acquired);
}

static void drawing_area_drag_end(GtkGestureDrag *gesture, gdouble offset_x, gdouble offset_y,
                                  gpointer data) {
    Connection *connection = data;
    double start_x = 0.0;
    double start_y = 0.0;
    gtk_gesture_drag_get_start_point(gesture, &start_x, &start_y);
    WidgetRecord *record =
        record_for_widget(gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(gesture)));
    if (record) {
        record->pointer_x = start_x + offset_x;
        record->pointer_y = start_y + offset_y;
        record->pointer_inside = true;
    }
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, int64_t, double, double, double, double);
    ((Adapter)cwhip_callback_adapter(connection->context))(
        connection->context, 2, start_x, start_y, offset_x, offset_y);
    signal_leave(connection, acquired);
}

static gboolean drawing_area_scroll(GtkEventControllerScroll *controller, gdouble dx,
                                    gdouble dy, gpointer data) {
    Connection *connection = data;
    WidgetRecord *record =
        record_for_widget(gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(controller)));
    double x = record ? record->pointer_x : 0.0;
    double y = record ? record->pointer_y : 0.0;
    GdkEvent *event = gtk_event_controller_get_current_event(GTK_EVENT_CONTROLLER(controller));
    if (event) {
        double event_x = 0.0;
        double event_y = 0.0;
        if (gdk_event_get_position(event, &event_x, &event_y)) {
            x = event_x;
            y = event_y;
            if (record) {
                record->pointer_x = x;
                record->pointer_y = y;
                record->pointer_inside = true;
            }
        }
    }
    int acquired = signal_enter(connection);
    typedef void (*Adapter)(CwhipCallbackContext *, double, double, double, double);
    ((Adapter)cwhip_callback_adapter(connection->context))(connection->context, x, y, dx, dy);
    signal_leave(connection, acquired);
    return TRUE;
}

static cairo_t *drawing_cr(int64_t token) {
    WidgetRecord *record = record_find(token);
    GtkWidget *widget = record->widget;
    if (!widget || !GTK_IS_DRAWING_AREA(widget))
        fatal("operation requires DrawingArea");
    if (!record->draw_cr)
        fatal("DrawingArea paint methods require an active onDraw callback");
    return record->draw_cr;
}

void cwhip_gtk_drawing_area_queue_draw(void *self, int64_t token) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_DRAWING_AREA(widget)) fatal("operation requires DrawingArea");
    gtk_widget_queue_draw(widget);
}

void cwhip_gtk_drawing_area_set_content_size(void *self, int64_t token, int64_t width,
                                             int64_t height) {
    (void)self;
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_DRAWING_AREA(widget) || width < 0 || height < 0 ||
        width > G_MAXINT || height > G_MAXINT)
        fatal("invalid DrawingArea content size");
    gtk_drawing_area_set_content_width(GTK_DRAWING_AREA(widget), (int)width);
    gtk_drawing_area_set_content_height(GTK_DRAWING_AREA(widget), (int)height);
}

void cwhip_gtk_drawing_area_set_color(void *self, int64_t token, double r, double g,
                                      double b, double a) {
    (void)self;
    cairo_set_source_rgba(drawing_cr(token), r, g, b, a);
}

void cwhip_gtk_drawing_area_set_line_width(void *self, int64_t token, double width) {
    (void)self;
    if (!(width > 0.0)) fatal("line width must be positive");
    cairo_set_line_width(drawing_cr(token), width);
}

void cwhip_gtk_drawing_area_fill_rect(void *self, int64_t token, double x, double y,
                                      double width, double height) {
    (void)self;
    cairo_t *cr = drawing_cr(token);
    cairo_rectangle(cr, x, y, width, height);
    cairo_fill(cr);
}

void cwhip_gtk_drawing_area_stroke_rect(void *self, int64_t token, double x, double y,
                                        double width, double height) {
    (void)self;
    cairo_t *cr = drawing_cr(token);
    cairo_rectangle(cr, x, y, width, height);
    cairo_stroke(cr);
}

void cwhip_gtk_drawing_area_fill_circle(void *self, int64_t token, double cx, double cy,
                                        double radius) {
    (void)self;
    if (!(radius >= 0.0)) fatal("circle radius must be nonnegative");
    cairo_t *cr = drawing_cr(token);
    cairo_arc(cr, cx, cy, radius, 0.0, G_PI * 2.0);
    cairo_fill(cr);
}

void cwhip_gtk_drawing_area_stroke_circle(void *self, int64_t token, double cx, double cy,
                                          double radius) {
    (void)self;
    if (!(radius >= 0.0)) fatal("circle radius must be nonnegative");
    cairo_t *cr = drawing_cr(token);
    cairo_arc(cr, cx, cy, radius, 0.0, G_PI * 2.0);
    cairo_stroke(cr);
}

void cwhip_gtk_drawing_area_stroke_line(void *self, int64_t token, double x1, double y1,
                                        double x2, double y2) {
    (void)self;
    cairo_t *cr = drawing_cr(token);
    cairo_move_to(cr, x1, y1);
    cairo_line_to(cr, x2, y2);
    cairo_stroke(cr);
}

int64_t cwhip_gtk_widget_signal(void *self, int64_t token, int64_t kind, void *callback) {
    (void)self;
    GtkWidget *w = widget_live(token);
    if (kind == 0) return cwhip_gtk_connect_clicked(GTK_BUTTON(w), callback);
    if (kind == 1) {
        if (!GTK_IS_EDITABLE(w)) fatal("changed requires Entry");
        return connect_signal(G_OBJECT(w), "changed", G_CALLBACK(text_changed),
                              callback, "callback<void(String)>");
    }
    if (kind == 2) return cwhip_gtk_connect_close_request(GTK_WINDOW(w), callback);
    if (kind == 3) {
        if (!GTK_IS_CHECK_BUTTON(w)) fatal("toggled requires CheckButton");
        return connect_signal(G_OBJECT(w), "toggled", G_CALLBACK(toggled),
                              callback, "callback<void(bool)>");
    }
    if (kind == 4) {
        if (!GTK_IS_NOTEBOOK(w)) fatal("page change requires GtkNotebook");
        return connect_signal(G_OBJECT(w), "switch-page", G_CALLBACK(page_switched),
                              callback, "callback<void()>");
    }
    fatal("invalid signal kind");
}

static int64_t source_token(void *source) {
    require_live();
    if (!source) fatal("null signal source");
    void *receiver = cwhip_gc_root(source);
    for (WidgetRecord *r = widgets; r; r = r->next)
        if (r->receiver == receiver && r->widget) return r->token;
    fatal("widget has been disposed or is not initialized");
}

int64_t cwhip_gtk_drawing_area_signal(void *self, void *source, void *callback) {
    (void)self;
    int64_t token = source_token(source);
    GtkWidget *widget = widget_live(token);
    if (!GTK_IS_DRAWING_AREA(widget)) fatal("draw requires DrawingArea");
    Connection *connection = calloc(1, sizeof(*connection));
    if (!connection) fatal("allocation failed");
    connection->token = token_new();
    connection->object = G_OBJECT(widget);
    connection->context = cwhip_callback_acquire(callback, "callback<void(int64,int64)>");
    connection->closures = 1;
    connection->draw_func = true;
    connection->next = connections;
    connections = connection;
    gtk_drawing_area_set_draw_func(GTK_DRAWING_AREA(widget), drawing_area_draw, connection,
                                   draw_connection_destroy);
    return connection->token;
}

int64_t cwhip_gtk_drawing_area_click_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(source_token(source));
    if (!GTK_IS_DRAWING_AREA(widget)) fatal("click requires DrawingArea");
    GtkGesture *gesture = gtk_gesture_click_new();
    /* Button 0 = any mouse button; the callback reports which one fired. */
    gtk_gesture_single_set_button(GTK_GESTURE_SINGLE(gesture), 0);
    gtk_event_controller_set_propagation_phase(GTK_EVENT_CONTROLLER(gesture),
                                               GTK_PHASE_BUBBLE);
    int64_t token = connect_signal(G_OBJECT(gesture), "released",
        G_CALLBACK(drawing_area_click_released), callback,
        "callback<void(int64,fp64,fp64)>");
    gtk_widget_add_controller(widget, GTK_EVENT_CONTROLLER(gesture));
    return token;
}

int64_t cwhip_gtk_drawing_area_drag_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(source_token(source));
    if (!GTK_IS_DRAWING_AREA(widget)) fatal("drag requires DrawingArea");
    GtkGesture *gesture = gtk_gesture_drag_new();
    gtk_gesture_single_set_button(GTK_GESTURE_SINGLE(gesture), GDK_BUTTON_PRIMARY);
    gtk_event_controller_set_propagation_phase(GTK_EVENT_CONTROLLER(gesture),
                                               GTK_PHASE_BUBBLE);
    int64_t token = connect_signal(G_OBJECT(gesture), "drag-begin",
        G_CALLBACK(drawing_area_drag_begin), callback,
        "callback<void(int64,fp64,fp64,fp64,fp64)>");
    /* Group begin/update/end on one Connection so disconnect() drops all three. */
    Connection *connection = connections;
    while (connection && connection->token != token) connection = connection->next;
    if (!connection || connection->additional_count + 2 > G_N_ELEMENTS(connection->additional))
        fatal("invalid grouped signal connection");
    ++connection->closures;
    connection->additional[connection->additional_count++] = g_signal_connect_data(
        connection->object, "drag-update", G_CALLBACK(drawing_area_drag_update), connection,
        connection_destroy, 0);
    ++connection->closures;
    connection->additional[connection->additional_count++] = g_signal_connect_data(
        connection->object, "drag-end", G_CALLBACK(drawing_area_drag_end), connection,
        connection_destroy, 0);
    if (!connection->additional[0] || !connection->additional[1])
        fatal("signal connection failed");
    gtk_widget_add_controller(widget, GTK_EVENT_CONTROLLER(gesture));
    return token;
}

int64_t cwhip_gtk_drawing_area_scroll_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(source_token(source));
    if (!GTK_IS_DRAWING_AREA(widget)) fatal("scroll requires DrawingArea");
    GtkEventController *controller =
        gtk_event_controller_scroll_new(GTK_EVENT_CONTROLLER_SCROLL_BOTH_AXES);
    gtk_event_controller_set_propagation_phase(controller, GTK_PHASE_BUBBLE);
    int64_t token = connect_signal(G_OBJECT(controller), "scroll",
        G_CALLBACK(drawing_area_scroll), callback, "callback<void(fp64,fp64,fp64,fp64)>");
    gtk_widget_add_controller(widget, controller);
    return token;
}

int64_t cwhip_gtk_context_menu_popup_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(source_token(source));
    if (!GTK_IS_POPOVER_MENU(widget)) fatal("popup requires ContextMenu");
    Connection *previous = g_object_get_data(G_OBJECT(widget), "cwhip-popup");
    if (previous && !previous->closed) cwhip_gtk_disconnect(previous->token);
    Connection *connection = calloc(1, sizeof(*connection));
    if (!connection) fatal("allocation failed");
    connection->token = token_new();
    connection->object = G_OBJECT(widget);
    connection->context = cwhip_callback_acquire(callback, "callback<void(fp64,fp64)>");
    connection->closures = 1;
    connection->popup_func = true;
    connection->next = connections;
    connections = connection;
    g_object_set_data(G_OBJECT(widget), "cwhip-popup", connection);
    return connection->token;
}

int64_t cwhip_gtk_scrollbar_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkAdjustment *adjustment = scrollbar_adjustment(source_token(source));
    return connect_signal(G_OBJECT(adjustment), "value-changed",
                          G_CALLBACK(scrollbar_value_changed), callback,
                          "callback<void(fp64)>");
}

int64_t cwhip_gtk_scale_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkAdjustment *adjustment = scale_adjustment(source_token(source));
    return connect_signal(G_OBJECT(adjustment), "value-changed",
                          G_CALLBACK(scale_value_changed), callback,
                          "callback<void(fp64)>");
}

int64_t cwhip_gtk_spin_button_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(source_token(source));
    if (!GTK_IS_SPIN_BUTTON(widget)) fatal("value change requires SpinButton");
    return connect_signal(G_OBJECT(widget), "value-changed",
                          G_CALLBACK(spin_button_value_changed), callback,
                          "callback<void(fp64)>");
}

int64_t cwhip_gtk_drop_down_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(source_token(source));
    if (!GTK_IS_DROP_DOWN(widget)) fatal("selection change requires DropDown");
    return connect_signal(G_OBJECT(widget), "notify::selected",
                          G_CALLBACK(drop_down_selected), callback,
                          "callback<void(int64)>");
}

int64_t cwhip_gtk_text_view_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkTextBuffer *buffer = text_view_buffer(source_token(source));
    return connect_signal(G_OBJECT(buffer), "changed", G_CALLBACK(text_view_changed),
                          callback, "callback<void(String)>");
}

int64_t cwhip_gtk_button_signal(void *self, void *source, void *callback) {
    return cwhip_gtk_widget_signal(self, source_token(source), 0, callback);
}
int64_t cwhip_gtk_entry_signal(void *self, void *source, void *callback) {
    return cwhip_gtk_widget_signal(self, source_token(source), 1, callback);
}
int64_t cwhip_gtk_window_signal(void *self, void *source, void *callback) {
    return cwhip_gtk_widget_signal(self, source_token(source), 2, callback);
}
int64_t cwhip_gtk_checkbox_signal(void *self, void *source, void *callback) {
    return cwhip_gtk_widget_signal(self, source_token(source), 3, callback);
}
int64_t cwhip_gtk_notebook_signal(void *self, void *source, void *callback) {
    return cwhip_gtk_widget_signal(self, source_token(source), 4, callback);
}
int64_t cwhip_gtk_window_focus_signal(void *self, void *source, void *callback) {
    (void)self;
    GtkWidget *widget = widget_live(source_token(source));
    if (!GTK_IS_WINDOW(widget)) fatal("focus change requires Window");
    return connect_signal(G_OBJECT(widget), "notify::is-active",
                          G_CALLBACK(window_focus_changed), callback, "callback<void(bool)>");
}

/* Clamps a 1-based line/column to a buffer iter (same rules as setCursor). */
static void source_iter_at(GtkTextBuffer *buffer, int64_t line, int64_t column,
                           GtkTextIter *iter) {
    int lines = gtk_text_buffer_get_line_count(buffer);
    if (line < 1) line = 1;
    if (line > lines) line = lines;
    gtk_text_buffer_get_iter_at_line(buffer, iter, (int)line - 1);
    int length = gtk_text_iter_ends_line(iter) ? 0 : gtk_text_iter_get_chars_in_line(iter);
    if (length && gtk_text_iter_get_line(iter) < lines - 1) --length;
    if (column < 1) column = 1;
    if (column - 1 > length) column = length + 1;
    gtk_text_iter_set_line_offset(iter, (int)column - 1);
}

static void source_selection_edge(int64_t token, bool start_edge, int64_t *line, int64_t *column) {
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter a, b, *edge;
    if (gtk_text_buffer_get_selection_bounds(buffer, &a, &b))
        edge = start_edge ? &a : &b;
    else {
        gtk_text_buffer_get_iter_at_mark(buffer, &a, gtk_text_buffer_get_insert(buffer));
        edge = &a;
    }
    *line = gtk_text_iter_get_line(edge) + 1;
    *column = gtk_text_iter_get_line_offset(edge) + 1;
}

void cwhip_gtk_source_view_set_right_margin(void *self, int64_t token, bool show, int64_t column) {
    (void)self;
    CwhipSourceView *view = cwhip_source(token);
    if (column < 1) column = 1;
    if (column > 512) column = 512;
    view->show_right_margin = show;
    view->right_margin_column = (int)column;
    gtk_source_view_set_right_margin_position(GTK_SOURCE_VIEW(view), (guint)column);
    /* Keep the stock GSV flag off; our snapshot draw is the visible guide. */
    gtk_source_view_set_show_right_margin(GTK_SOURCE_VIEW(view), FALSE);
    gtk_widget_queue_draw(GTK_WIDGET(view));
}

bool cwhip_gtk_source_view_right_margin_shown(void *self, int64_t token) {
    (void)self;
    return cwhip_source(token)->show_right_margin;
}

int64_t cwhip_gtk_source_view_right_margin_column(void *self, int64_t token) {
    (void)self;
    return cwhip_source(token)->right_margin_column;
}

int64_t cwhip_gtk_source_view_selection_start_line(void *self, int64_t token) {
    (void)self;
    int64_t line = 1, column = 1;
    source_selection_edge(token, true, &line, &column);
    return line;
}

int64_t cwhip_gtk_source_view_selection_start_column(void *self, int64_t token) {
    (void)self;
    int64_t line = 1, column = 1;
    source_selection_edge(token, true, &line, &column);
    return column;
}

int64_t cwhip_gtk_source_view_selection_end_line(void *self, int64_t token) {
    (void)self;
    int64_t line = 1, column = 1;
    source_selection_edge(token, false, &line, &column);
    return line;
}

int64_t cwhip_gtk_source_view_selection_end_column(void *self, int64_t token) {
    (void)self;
    int64_t line = 1, column = 1;
    source_selection_edge(token, false, &line, &column);
    return column;
}

void cwhip_gtk_source_view_begin_user_action(void *self, int64_t token) {
    (void)self;
    gtk_text_buffer_begin_user_action(GTK_TEXT_BUFFER(source_buffer(token)));
}

void cwhip_gtk_source_view_end_user_action(void *self, int64_t token) {
    (void)self;
    gtk_text_buffer_end_user_action(GTK_TEXT_BUFFER(source_buffer(token)));
}

void cwhip_gtk_source_view_insert_text(void *self, int64_t token, int64_t line, int64_t column,
                                       void *text) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter iter;
    source_iter_at(buffer, line, column, &iter);
    char *bytes = text_copy(text);
    gtk_text_buffer_insert(buffer, &iter, bytes, -1);
    g_free(bytes);
}

void cwhip_gtk_source_view_delete_range(void *self, int64_t token, int64_t start_line,
                                        int64_t start_column, int64_t end_line,
                                        int64_t end_column) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter start, end;
    source_iter_at(buffer, start_line, start_column, &start);
    source_iter_at(buffer, end_line, end_column, &end);
    if (gtk_text_iter_compare(&start, &end) > 0) {
        GtkTextIter swap = start;
        start = end;
        end = swap;
    }
    if (!gtk_text_iter_equal(&start, &end)) gtk_text_buffer_delete(buffer, &start, &end);
}

void cwhip_gtk_source_view_replace_range(void *self, int64_t token, int64_t start_line,
                                         int64_t start_column, int64_t end_line,
                                         int64_t end_column, void *text) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter start, end;
    source_iter_at(buffer, start_line, start_column, &start);
    source_iter_at(buffer, end_line, end_column, &end);
    if (gtk_text_iter_compare(&start, &end) > 0) {
        GtkTextIter swap = start;
        start = end;
        end = swap;
    }
    char *bytes = text_copy(text);
    gtk_text_buffer_begin_user_action(buffer);
    if (!gtk_text_iter_equal(&start, &end)) gtk_text_buffer_delete(buffer, &start, &end);
    gtk_text_buffer_insert(buffer, &start, bytes, -1);
    gtk_text_buffer_end_user_action(buffer);
    g_free(bytes);
}

void cwhip_gtk_source_view_select_range(void *self, int64_t token, int64_t start_line,
                                        int64_t start_column, int64_t end_line,
                                        int64_t end_column) {
    (void)self;
    GtkTextBuffer *buffer = GTK_TEXT_BUFFER(source_buffer(token));
    GtkTextIter start, end;
    source_iter_at(buffer, start_line, start_column, &start);
    source_iter_at(buffer, end_line, end_column, &end);
    gtk_text_buffer_select_range(buffer, &start, &end);
}

static char *clipboard_cache = NULL;

void cwhip_gtk_clipboard_set_text(void *self, void *text) {
    (void)self;
    require_live();
    char *bytes = text_copy(text);
    g_free(clipboard_cache);
    clipboard_cache = g_strdup(bytes);
    GdkDisplay *display = gdk_display_get_default();
    if (display) gdk_clipboard_set_text(gdk_display_get_clipboard(display), bytes);
    g_free(bytes);
}

void *cwhip_gtk_clipboard_text(void *self) {
    (void)self;
    require_live();
    /* GDK clipboard reads are asynchronous; return the last setText value for
     * same-process use (plugins/tests). Empty when nothing was set here. */
    const char *text = clipboard_cache ? clipboard_cache : "";
    return cwhip_string_new(&cwhip_string_class_meta, text, strlen(text));
}

#include "gtk_config.c"
