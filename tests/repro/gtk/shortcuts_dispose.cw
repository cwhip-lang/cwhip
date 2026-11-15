/*
 * tests/repro/gtk/shortcuts_dispose.cw — shortcuts dispose.
 *
 * Created: 2026-10-30
 * Author: chuck
 *
 * Changelog:
 *   2026-10-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Action is a class, used as a fixture by this test.
 *
 * Its methods include constructor, run, note.
 */
class Action {
    public:
    Gtk.Window window
    Gtk.Notebook notebook
    Gtk.ScrolledWindow page

    /*
     * Constructs a Action and stores window, notebook, page.
     *
     * Parameters:
     *   owner — Gtk.Window owner.
     *   pages — Gtk.Notebook pages.
     *   closing — Gtk.ScrolledWindow closing.
     *
     * Returns the constructed Action.
     */
    Action(Gtk.Window owner, Gtk.Notebook pages, Gtk.ScrolledWindow closing) {
        window = owner
        notebook = pages
        page = closing
    }

    /*
     * Handles run for this Action.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {

        if (page != null) {
            notebook.remove(page)
            page.dispose()
            F().collect()
            print("closed;")
        }
        else {
            window.dispose()
            F().collect()
            print("quit;")
            Gtk.Application().quit()
        }

    }

    /*
     * Handles note for this Action by calling the native function
     * binding_released.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void note()

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        note()
    }
}
void Action.note() from "binding_released"

/*
 * UI is a class, used as a fixture by this test.
 *
 * Its methods include activate.
 */
class UI {
    public:
    Gtk.Window window
    Gtk.Notebook notebook
    Gtk.ScrolledWindow first
    GtkSource.View firstView
    GtkSource.View secondView

    /*
     * Handles activate for this UI.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void activate() {
        window = Gtk.Window("Shortcut bindings")
        notebook = Gtk.Notebook()
        window.setChild(notebook)
        first = Gtk.ScrolledWindow()
        firstView = GtkSource.View()
        first.setChild(firstView.widget())
        notebook.appendPage(first, "one")
        Gtk.ScrolledWindow second = Gtk.ScrolledWindow()
        secondView = GtkSource.View()
        second.setChild(secondView.widget())
        notebook.appendPage(second, "two")
        print(firstView.bindShortcut("<Control>w", Action(
                window,
                notebook,
                first).run))
        print(secondView.bindShortcut("<Control>q", Action(
                window,
                notebook,
                null).run))
        window.present()
        int64 closing = firstView._widgetToken()
        print(Keys().press(closing, "<Control>w"))
        print(Keys().press(secondView._widgetToken(), "<Control>q"))
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingShortcuts")
    app.onActivate(UI().activate)
    app.run()
    F().collect()
    print(F().receivers())
}
