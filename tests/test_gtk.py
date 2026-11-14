"""Real GTK 4 adapters and worker scheduling through compiled Cwhip programs."""

import argparse
from pathlib import Path
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile

from program_runner import environment, invoke
from gtk_support import headless


NATIVE = """
import gtk
class F {
    public:
    handle button()
    handle entry()
    handle window()
    int64 clicked(handle object, void<> cb)
    int64 changed(handle object, void<> cb)
    int64 closeSignal(handle object, bool<> cb)
    bool disconnect(int64 token)
    void emit(handle object)
    void text(handle object)
    bool updated(handle object)
    bool request(handle object)
    void drop(handle object)
    void collect()
    void owner()
    void destroyed()
    int64 count()
    void unblock(handle sem)
    void foreign()
    void unlocked(void<> cb)
    void clickPublic()
    void destroyPublic()
    void releasePublic()
    bool registered()
    void trackPublic()
    int64 finalized()
    String badUtf8()
}
handle F.button() from "fixture_gtk_button"
handle F.entry() from "fixture_gtk_entry"
handle F.window() from "fixture_gtk_window"
int64 F.clicked(handle object, void<> cb) from "fixture_gtk_clicked"
int64 F.changed(handle object, void<> cb) from "fixture_gtk_changed"
int64 F.closeSignal(handle object, bool<> cb) from "fixture_gtk_close"
bool F.disconnect(int64 token) from "fixture_gtk_disconnect"
void F.emit(handle object) from "fixture_gtk_emit"
void F.text(handle object) from "fixture_gtk_text"
bool F.updated(handle object) from "fixture_gtk_is_updated"
bool F.request(handle object) from "fixture_gtk_request"
void F.drop(handle object) from "fixture_gtk_drop"
void F.collect() from "fixture_gtk_collect"
void F.owner() from "fixture_gtk_owner"
void F.destroyed() from "fixture_gtk_destroyed"
int64 F.count() from "fixture_gtk_count"
void F.unblock(handle sem) from "fixture_gtk_unblock"
void F.foreign() from "fixture_gtk_foreign"
void F.unlocked(void<> cb) from "fixture_gtk_unlocked_post"
void F.clickPublic() from "fixture_gtk_public_click"
void F.destroyPublic() from "fixture_gtk_public_destroy"
void F.releasePublic() from "fixture_gtk_public_release"
bool F.registered() from "fixture_gtk_public_registered"
void F.trackPublic() from "fixture_gtk_public_track"
int64 F.finalized() from "fixture_gtk_finalized"
String F.badUtf8() from "fixture_gtk_bad_utf8"
class Thread {
    public:
    handle launch()
    void join(handle thread)
}
handle Thread.launch() from "cwhip_thread_start"
void Thread.join(handle thread) from "cwhip_thread_join"
class Sem {
    public:
    handle create(int64 n)
    void wait(handle sem)
    void release(handle sem)
}
handle Sem.create(int64 n) from "cwhip_semaphore_create"
void Sem.wait(handle sem) from "cwhip_semaphore_wait"
void Sem.release(handle sem) from "cwhip_semaphore_release"
"""

SUBCLASS_FIXTURE = """
namespace Gtk {
    class FixturePair : Button, Entry {
        public:
        FixturePair() { super Button("left")
            super Entry("right") }
    }
    class FixtureMarker {
        public:
        int64 value
        FixtureMarker() { value = 7 }
    }
    class FixtureDerived : FixtureMarker, Button {
        public:
        FixtureDerived() { super FixtureMarker()
            super Button("derived") }
    }
}
"""

CASES = [
    ("public_widgets", """
class UI {
    public:
    Gtk.Window window
    Gtk.Box box
    Gtk.Button button
    Gtk.Entry entry
    Gtk.Label label
    Gtk.CheckButton check
    Gtk.ScrolledWindow scroll
    Gtk.SignalConnection click
    Gtk.SignalConnection changed
    Gtk.SignalConnection close
    Gtk.SignalConnection toggled
    void<> clickAction
    void<String> editAction
    void<bool> toggleAction
    bool<> preventAction
    bool<> allowAction
    void<> finishAction
    String saved
    int64 nesting
    void edited(String text) {
        F().collect()
        saved = text
        label.setText(text)
        int64 n = 0
        while (n < 200) { String garbage = format("allocate {}", n)
            n = n + 1 }
        F().collect()
        print(text)
    }
    void toggledHandler(bool active) { F().collect()
        print(active) }
    void clicked() {
        F().collect()
        if (nesting == 0) {
            nesting = 1
            F().clickPublic()
            print(click.disconnect())
            button.dispose()
        }
        print("click")
    }
    bool preventClose() { F().collect()
        print("prevent")
        return(true) }
    bool allowClose() { print("allow")
        return(false) }
    void activate() {
        print(F().registered())
        print(Gtk.Application().id())
        window = Gtk.Window("Cwhip")
        window.setDefaultSize(400, 300)
        box = Gtk.Box(1, 6)
        window.setChild(box)
        scroll = Gtk.ScrolledWindow()
        Gtk.Box contents = Gtk.Box(0, 3)
        scroll.setChild(contents)
        box.append(scroll)
        label = Gtk.Label("")
        contents.append(label)
        button = Gtk.Button("Click")
        box.append(button)
        entry = Gtk.Entry("")
        box.append(entry)
        check = Gtk.CheckButton("Check")
        box.append(check)
        box.setLayout(1, 8)
        window.setTitle("Ready")
        print(window.title())
        print(button.label())
        check.setLabel("Enabled")
        print(check.label())
        window.setVisible(true)
        button.setSensitive(false)
        button.setSensitive(true)
        click = button.onClicked(clickAction)
        changed = entry.onChanged(editAction)
        toggled = check.onToggled(toggleAction)
        close = window.onCloseRequest(preventAction)
        window.present()
        Gtk.Application().post(finishAction)
    }
    void finish() {
        F().collect()
        entry.setText("first")
        print(saved)
        print(label.text())
        print(entry.text())
        String snapshot = saved
        entry.setText("later")
        F().collect()
        print(snapshot)
        check.setActive(true)
        print(check.active())
        F().clickPublic()
        print(click.connected())
        Gtk.Widget alias = button
        Gtk.Button secondAlias = alias as Gtk.Button
        print(alias.disposed())
        alias.dispose()
        secondAlias.dispose()
        window.close()
        print(window.disposed())
        print(close.disconnect())
        close = window.onCloseRequest(allowAction)
        window.close()
        print(window.disposed())
        print(entry.disposed())
        print(changed.connected())
        print(toggled.connected())
        print(close.connected())
        Gtk.Application().quit()
    }
}
class Setup {
    public:
    void install() {
        UI ui = UI()
        ui.clickAction = ui.clicked
        ui.editAction = ui.edited
        ui.toggleAction = ui.toggledHandler
        ui.preventAction = ui.preventClose
        ui.allowAction = ui.allowClose
        ui.finishAction = ui.finish
        Gtk.Application().onActivate(ui.activate)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Public")
    Setup().install()
    F().collect()
    app.run()
    app.shutdown()
    app.shutdown()
}
""", "trueorg.cwhip.PublicReadyClickEnabledfirstfirstfirstfirstlaterfirsttruetrueclicktrueclickfalsetruepreventfalsetrueallowtruetruefalsefalsefalse", None),
    ("public_parenting", """
class UI {
    public:
    Gtk.Window window
    Gtk.Button orphan
    Gtk.Button child
    Gtk.SignalConnection connection
    void<> clickAction
    void action() { print("must-not-run") }
    void activate() {
        window = Gtk.Window("Tree")
        Gtk.Box box = Gtk.Box(1, 0)
        window.setChild(box)
        orphan = Gtk.Button("orphan")
        child = Gtk.Button("child")
        box.append(orphan)
        box.remove(orphan)
        box.append(orphan)
        box.remove(orphan)
        box.append(child)
        connection = child.onClicked(clickAction)
        F().destroyPublic()
        print(window.disposed())
        print(box.disposed())
        print(child.disposed())
        print(connection.connected())
        print(orphan.disposed())
        orphan.setLabel("still alive")
        print(orphan.label())
        F().collect()
        F().releasePublic()
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Parent")
    UI ui = UI()
    ui.clickAction = ui.action
    app.onActivate(ui.activate)
    app.run()
    app.shutdown()
    print(ui.orphan.disposed())
    ui.orphan.dispose()
}
""", "truetruetruefalsefalsestill alivetrue", None),
    ("public_dispose_handler", """
class UI {
    public:
    Gtk.Window window
    Gtk.Button button
    Gtk.SignalConnection connection
    void<> clickAction
    void click() { window.dispose()
        F().collect()
        print(connection.connected())
        print(button.disposed()) }
    void activate() {
        window = Gtk.Window("Dispose")
        button = Gtk.Button("Dispose")
        window.setChild(button)
        connection = button.onClicked(clickAction)
        F().clickPublic()
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Dispose")
    UI ui = UI()
    ui.clickAction = ui.click
    app.onActivate(ui.activate)
    app.run()
    app.shutdown()
}
""", "falsetrue", None),
    ("signals", """
class Handler {
    public:
    handle button
    handle entry
    int64 clicked
    int64 changed
    int64 nesting
    Handler(handle b, handle e) { button = b
        entry = e }
    void click() {
        F().owner()
        F().collect()
        if (nesting == 0) {
            nesting = 1
            F().emit(button)
            print(F().disconnect(clicked))
            F().text(entry)
        }
        print("click")
    }
    void edit() {
        F().collect()
        print(F().updated(entry))
        print(F().disconnect(changed))
    }
    bool closeYes() { F().collect()
        return(true) }
    bool closeNo() { return(false) }
    void trigger() {
        F().emit(button)
        F().emit(button)
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application()
    app.initialize()
    handle b = F().button()
    handle e = F().entry()
    handle w = F().window()
    Handler h = Handler(b, e)
    h.clicked = F().clicked(b, h.click)
    h.changed = F().changed(e, h.edit)
    int64 close = F().closeSignal(w, h.closeYes)
    print(F().request(w))
    print(F().disconnect(close))
    close = F().closeSignal(w, h.closeNo)
    print(F().request(w))
    F().disconnect(close)
    app.post(h.trigger)
    app.run()
    print(F().disconnect(h.clicked))
    F().drop(b)
    F().drop(e)
    F().drop(w)
    app.shutdown()
}
""", "truetruefalseclicktruetruetrueclickfalse", None),
    ("destroy_during_signal", """
class Handler {
    public:
    handle button
    int64 token
    Handler(handle b) { button = b }
    void click() {
        F().drop(button)
        F().collect()
        print("alive")
    }
}
class Setup {
    public:
    int64 install(handle button) {
        Handler handler = Handler(button)
        return(F().clicked(button, handler.click))
    }
}
start {
    Gtk.Application().initialize()
    handle button = F().button()
    int64 token = Setup().install(button)
    F().collect()
    F().emit(button)
    print(F().disconnect(token))
    F().collect()
    Gtk.Application().shutdown()
}
""", "alivefalse", None),
    ("root_and_cancellation", """
class Payload {
    public:
    void note()
    destroy { note() }
    void work() { F().owner()
        F().collect()
        print("retained")
        Gtk.Application().post(Payload().pending)
        Gtk.Application().quit() }
    void pending() { print("must-not-run") }
}
void Payload.note() from "fixture_gtk_destroyed"
class Setup {
    public:
    int64 submit() { return(Gtk.Application().post(Payload().work)) }
    int64 connect(handle button) { return(F().clicked(button, Payload().work)) }
}
start {
    Gtk.Application app = Gtk.Application()
    app.initialize()
    int64 cancel = Setup().submit()
    F().collect()
    print(F().count())
    print(app.cancel(cancel))
    print(app.cancel(cancel))
    F().collect()
    print(F().count())
    handle button = F().button()
    Setup().connect(button)
    F().collect()
    print(F().count())
    F().drop(button)
    F().collect()
    print(F().count())
    Setup().submit()
    F().collect()
    app.run()
    app.shutdown()
    F().collect()
    print(F().count())
}
""", "0truefalse112retained4", None),
    ("worker_progress", """
class Payload {
    public:
    int64 value
    Payload(int64 n) { value = n }
    void done() {
        F().owner()
        F().collect()
        print(value)
        Gtk.Application().quit()
    }
}
class Worker : Thread {
    public:
    handle gate
    Worker(handle sem) { gate = sem }
    void submit(int64 n) { Gtk.Application().post(Payload(n).done) }
    void run() {
        Sem().wait(gate)
        int64 n = 0
        while (n < 10000) { n = n + 1 }
        submit(n)
        F().collect()
    }
}
start {
    Gtk.Application app = Gtk.Application()
    app.initialize()
    handle gate = Sem().create(0)
    Worker worker = Worker(gate)
    handle thread = worker.launch()
    F().unblock(gate)
    app.run()
    worker.join(thread)
    Sem().release(gate)
    app.shutdown()
}
""", "10000", None),
    ("shutdown_in_handler", """
class Handler {
    public:
    handle button
    Handler(handle b) { button = b }
    void click() { Gtk.Application().shutdown()
        F().collect()
        print("shutdown") }
    void pending() { print("must-not-run") }
    void trigger() {
        Gtk.Application().post(Handler(button).pending)
        F().emit(button)
    }
}
start {
    Gtk.Application().initialize()
    handle b = F().button()
    Handler h = Handler(b)
    int64 token = F().clicked(b, h.click)
    Gtk.Application().post(h.trigger)
    Gtk.Application().post(h.pending)
    Gtk.Application().run()
    print(F().disconnect(token))
    F().drop(b)
    Gtk.Application().shutdown()
}
""", "shutdownfalse", None),
    ("wrong_thread", """
class Worker : Thread {
    public:
    void run() { Gtk.Application().quit() }
}
start {
    Gtk.Application().initialize()
    Worker w = Worker()
    handle thread = w.launch()
    w.join(thread)
}
""", "", "operation requires the GUI owner thread"),
    ("foreign_thread", """
start { Gtk.Application().initialize()
    F().foreign() }
""", "", "operation requires the GUI owner thread"),
    ("post_after_shutdown", """
class Handler { public: void run() {} }
start { Gtk.Application().initialize()
    Gtk.Application().shutdown()
    Gtk.Application().post(Handler().run) }
""", "", "post requires a live application"),
    ("unlocked_post", """
class Handler { public: void run() {} }
start { Gtk.Application().initialize()
    F().unlocked(Handler().run) }
""", "", "operation requires the managed runtime lock"),
    ("exception_boundary", """
class Handler { public: void run() { raise(Exception("gtk boundary")) } }
start { Gtk.Application().initialize()
    Gtk.Application().post(Handler().run)
    Gtk.Application().run() }
""", "", "Cwhip native callback error: uncaught Cwhip exception: gtk boundary"),
]


def misuse(name, action, diagnostic):
    return (name, """
class UI {
    public:
    void noop() {}
    void activate() {
        Gtk.Window window = Gtk.Window("Misuse")
        Gtk.Box box = Gtk.Box(1, 0)
        Gtk.Entry entry = Gtk.Entry("")
        Gtk.Button button = Gtk.Button("")
        window.setChild(box)
""" + action + """
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Misuse")
    app.onActivate(UI().activate)
    app.run()
    app.shutdown()
}
""", "", diagnostic)


CASES += [
    misuse("disposed_widget", 'entry.dispose()\nentry.setText("bad")',
           "widget has been disposed"),
    misuse("null_text", "entry.setText(null)", "null text"),
    misuse("invalid_orientation", "Gtk.Box invalid = Gtk.Box(2, 0)",
           "invalid layout orientation or spacing"),
    misuse("negative_spacing", "box.setLayout(0, -1)", "invalid box layout"),
    misuse("invalid_size", "window.setDefaultSize(0, 100)", "invalid window size"),
    misuse("multiple_parents", "box.append(button)\nbox.append(button)",
           "already parented"),
    misuse("container_occupied", "window.setChild(entry)", "container already has a child"),
    misuse("parenting_cycle", "window.remove(box)\nGtk.Box nested = Gtk.Box(0, 0)\nbox.append(nested)\nnested.append(box)",
           "parenting cycle"),
    misuse("window_child", "box.append(window)", "child is a window"),
    misuse("wrong_child_remove", "box.remove(button)", "not a child"),
    misuse("null_handler", "button.onClicked(null)", "null callback"),
    misuse("disposed_signal", "entry.dispose()\nentry.onChanged(null)",
           "widget has been disposed or is not initialized"),
    misuse("null_child", "box.append(null)", "null reference"),
    misuse("embedded_nul", 'entry.setText(format("{:c}", 0))',
           "text must be UTF-8 without embedded NUL"),
    misuse("invalid_utf8", "entry.setText(F().badUtf8())",
           "String bytes are not valid UTF-8"),
    misuse("unpresented_close", "window.close()", "close requires a presented window"),
    misuse("nested_run", "Gtk.Application().run()", "nested application run"),
    ("before_activation", """
start { Gtk.Application app = Gtk.Application("org.cwhip.Early")
    Gtk.Window window = Gtk.Window("early") }
""", "", "widgets must be created during or after local activation"),
    ("invalid_id", 'start { Gtk.Application app = Gtk.Application("invalid") }',
     "", "invalid application ID"),
    ("null_id", "start { Gtk.Application app = Gtk.Application(null) }",
     "", "null text"),
    ("wrong_widget_thread", """
class Worker : Thread {
    public:
    Gtk.Entry entry
    Worker(Gtk.Entry value) { entry = value }
    void run() { entry.setText("worker") }
}
class UI {
    public:
    void activate() {
        Gtk.Entry entry = Gtk.Entry("")
        Worker worker = Worker(entry)
        handle thread = worker.launch()
        worker.join(thread)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Thread")
    app.onActivate(UI().activate)
    app.run()
}
""", "", "operation requires the GUI owner thread"),
    ("public_shutdown_handler", """
class UI {
    public:
    Gtk.Window window
    Gtk.Button button
    Gtk.SignalConnection connection
    void<> action
    void click() {
        Gtk.Application().shutdown()
        F().collect()
        print(button.disposed())
        print(connection.connected())
        button.dispose()
    }
    void activate() {
        window = Gtk.Window("Shutdown")
        button = Gtk.Button("Shutdown")
        window.setChild(button)
        connection = button.onClicked(action)
        F().clickPublic()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Shutdown")
    UI ui = UI()
    ui.action = ui.click
    app.onActivate(ui.activate)
    app.run()
    app.shutdown()
}
""", "truefalse", None),
    ("null_signal_source", """
class Handler { public: void run() {} }
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Null")
    Gtk.Button button = null
    Gtk.SignalConnection connection = Gtk.SignalConnection(button, Handler().run)
}
""", "", "null signal source"),
    ("wrong_native_type", """
class Handler { public: void run() {} }
start {
    Gtk.Application().initialize()
    F().clicked(F().entry(), Handler().run)
}
""", "", "clicked requires GtkButton"),
    ("public_entry_dispose", """
class Handler {
    public:
    Gtk.Entry entry
    Gtk.SignalConnection connection
    Handler(Gtk.Entry source) { entry = source }
    void edit(String text) {
        entry.dispose()
        F().collect()
        print(text)
        print(entry.disposed())
        print(connection.connected())
    }
}
class UI {
    public:
    void activate() {
        Gtk.Window window = Gtk.Window("Entry")
        Gtk.Entry entry = Gtk.Entry("")
        window.setChild(entry)
        Handler handler = Handler(entry)
        handler.connection = entry.onChanged(handler.edit)
        F().collect()
        entry.setText("temporary")
        F().collect()
        window.dispose()
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.EntryDispose")
    app.onActivate(UI().activate)
    app.run()
}
""", "temporarytruefalse", None),
    ("public_close_dispose", """
class Handler {
    public:
    Gtk.Window window
    Handler(Gtk.Window source) { window = source }
    bool close() { window.dispose()
        F().collect()
        return(true) }
}
class UI {
    public:
    void activate() {
        Gtk.Window window = Gtk.Window("Close")
        window.onCloseRequest(Handler(window).close)
        F().collect()
        window.present()
        window.close()
        print(window.disposed())
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.CloseDispose")
    app.onActivate(UI().activate)
    app.run()
}
""", "true", None),
    ("public_native_finalization", """
class UI {
    public:
    void activate() {
        Gtk.Window window = Gtk.Window("References")
        Gtk.Box box = Gtk.Box(Gtk.Box.VERTICAL, 0)
        Gtk.Button button = Gtk.Button("")
        window.setChild(box)
        box.append(button)
        F().trackPublic()
        window.dispose()
        print(F().finalized())
        print(box.disposed())
        print(button.disposed())
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.References")
    app.onActivate(UI().activate)
    app.run()
}
""", "3truetrue", None),
    ("public_worker_post", """
class Payload {
    public:
    Gtk.Window window
    Gtk.Label label
    Payload(Gtk.Window w, Gtk.Label l) { window = w
        label = l }
    void done() {
        F().owner()
        F().collect()
        label.setText("worker")
        print(label.text())
        window.close()
    }
}
class Worker : Thread {
    public:
    Gtk.Window window
    Gtk.Label label
    handle gate
    Worker(Gtk.Window w, Gtk.Label l, handle g) { window = w
        label = l
        gate = g }
    void run() {
        Sem().wait(gate)
        Gtk.Application().post(Payload(window, label).done)
        F().collect()
    }
}
class UI {
    public:
    Worker worker
    handle thread
    handle gate
    Gtk.Label label
    void never() { print("must-not-run") }
    void<> pending
    void activate() {
        Gtk.Window window = Gtk.Window("Worker")
        label = Gtk.Label("")
        window.setChild(label)
        window.present()
        int64 token = Gtk.Application().post(pending)
        print(Gtk.Application().cancel(token))
        gate = Sem().create(0)
        worker = Worker(window, label, gate)
        thread = worker.launch()
        F().unblock(gate)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Worker")
    UI ui = UI()
    ui.pending = ui.never
    app.onActivate(ui.activate)
    app.run()
    ui.worker.join(ui.thread)
    Sem().release(ui.gate)
    print(ui.label.disposed())
    app.shutdown()
}
""", "trueworkertrue", None),
    ("close_exception_boundary", """
class Handler { public: bool close() { raise(Exception("close boundary")) } }
class UI {
    public:
    void activate() {
        Gtk.Window window = Gtk.Window("Exception")
        window.onCloseRequest(Handler().close)
        window.present()
        window.close()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Exception")
    app.onActivate(UI().activate)
    app.run()
}
""", "", "Cwhip native callback error: uncaught Cwhip exception: close boundary"),
    ("public_toggle_dispose", """
class Handler {
    public:
    Gtk.CheckButton check
    Gtk.SignalConnection connection
    Handler(Gtk.CheckButton source) { check = source }
    void toggle(bool value) {
        check.dispose()
        F().collect()
        print(value)
        print(connection.connected())
        try { raise(Exception("recoverable")) }
        except (Exception) as error { print("caught") }
    }
}
class UI {
    public:
    void activate() {
        Gtk.Window window = Gtk.Window("Toggle")
        Gtk.CheckButton check = Gtk.CheckButton("")
        window.setChild(check)
        Handler handler = Handler(check)
        handler.connection = check.onToggled(handler.toggle)
        check.setActive(true)
        print(check.disposed())
        window.dispose()
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.ToggleDispose")
    app.onActivate(UI().activate)
    app.run()
}
""", "truefalsecaughttrue", None),
    ("quit_before_run", """
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Quit")
    app.quit()
}
""", "", "quit requires a running application"),
    ("rerun", """
class Handler { public: void activate() { Gtk.Application().quit() } }
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Rerun")
    app.onActivate(Handler().activate)
    app.run()
    app.run()
}
""", "", "application has shut down"),
    ("multiple_widget_bases", """
class UI { public: void activate() { Gtk.FixturePair pair = Gtk.FixturePair() } }
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Multiple")
    app.onActivate(UI().activate)
    app.run()
}
""", "", "multiple Widget bases in one managed object are not supported"),
    ("widget_secondary_base", """
class Handler { public: void click() { F().collect()
    print("clicked") } }
class UI {
    public:
    void activate() {
        Gtk.Window window = Gtk.Window("Mixin")
        Gtk.FixtureDerived derived = Gtk.FixtureDerived()
        Gtk.Button button = derived
        window.setChild(button)
        Gtk.SignalConnection connection = button.onClicked(Handler().click)
        F().collect()
        print(derived.value)
        print(button.label())
        F().clickPublic()
        window.dispose()
        print(connection.connected())
        print(button.disposed())
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.Secondary")
    app.onActivate(UI().activate)
    app.run()
}
""", "7derivedclickedfalsetrue", None),
]

COMPILE_CASES = [
    ("wrong_callback", """
class Handler { public: void click(int64 n) {} }
start { Gtk.Button button = null
    button.onClicked(Handler().click) }
""", "callback"),
    ("private_forwarder", """
start { Gtk.Entry entry = null
    entry._create(5, "", 0, 0, null) }
""", "not accessible"),
    ("wrong_child_type", """
start { Gtk.Box box = null
    box.append("not a widget") }
""", "method argument type does not match"),
]


def gui_run(output, work, env, arguments=()):
    return invoke([str(output), *arguments], work, env)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--clang", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--work", type=Path, required=True)
    parser.add_argument("--sanitize", default="")
    parser.add_argument("--xvfb", required=True)
    parser.add_argument("--build", type=Path)
    args = parser.parse_args()
    expected_signals = next(case[2] for case in CASES if case[0] == "signals")
    args.work.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=args.work, prefix="gtk-") as directory:
        work = Path(directory).resolve()
        env = environment(work)
        env.update({"GTK_A11Y": "none", "GSK_RENDERER": "cairo", "GDK_DISABLE": "gl"})
        env.pop("DBUS_SESSION_BUS_ADDRESS", None)
        native = work / "fixture.o"
        flags = shlex.split(subprocess.check_output(
            ["pkg-config", "--cflags", "gtk4"], text=True))
        if args.sanitize:
            flags.append(f"-fsanitize={args.sanitize}")
        result = invoke([args.clang, "-std=c11", "-Wall", "-Wextra", "-Werror",
                         "-I", str(args.include.resolve()), "-I", str(args.native.resolve()),
                         "-c", str(args.fixture.resolve()), "-o", str(native)] + flags, work, env)
        assert result.returncode == 0, result.stderr
        # Constructor super names are currently unqualified in Cwhip. Put
        # test-only hierarchy extensions in the package's own compilation unit.
        module_root = work / "subclass-modules"
        package = module_root / "gtk/0.1.0"
        staged = args.compiler.resolve().parent.parent / "share/cwhip/modules/gtk/0.1.0"
        shutil.copytree(staged, package)
        source = package / "gtk.cw"
        source.write_text(source.read_text() + SUBCLASS_FIXTURE)
        with headless(args.xvfb, work, env) as env:
            for name, program, expected, diagnostic in CASES:
                source = work / f"{name}.cw"
                source.write_text(NATIVE + program)
                output = work / name
                command = [str(args.compiler.resolve()), str(source), str(native),
                           "-o", str(output)]
                if name in ("multiple_widget_bases", "widget_secondary_base"):
                    command += ["-M", str(module_root)]
                result = invoke(command, work, env)
                assert result.returncode == 0, f"{name}: {result.stderr}"
                result = gui_run(output, work, env)
                assert result.stdout == expected, (
                    f"{name}: exit {result.returncode}, {result.stdout!r}, {result.stderr}")
                if diagnostic:
                    assert result.returncode == -signal.SIGABRT and diagnostic in result.stderr, (
                        name, result.returncode, result.stderr)
                else:
                    assert result.returncode == 0, f"{name}: {result.stderr}"
                    # Session bus warnings are external GTK desktop integration;
                    # all critical/errors remain failures.
                    assert "CRITICAL" not in result.stderr and "ERROR" not in result.stderr, result.stderr
                print(f"PASS {name}")
            for name, program, diagnostic in COMPILE_CASES:
                source = work / f"{name}.cw"
                source.write_text("import gtk\n" + program)
                result = invoke([str(args.compiler.resolve()), str(source), "-o",
                                 str(work / name)], work, env)
                assert result.returncode != 0 and diagnostic in result.stderr, (name, result.stderr)
                print(f"PASS {name}")
            source = work / "single-instance.cw"
            source.write_text("""import gtk
import system
class UI {
    public:
    int64 count
    Gtk.Window window
    void activate() {
        count = count + 1
        if (count == 1) {
            window = Gtk.Window("Primary")
            window.present()
            print("first\\n")
            System.StandardIO().flush()
        } else {
            print("second\\n")
            Gtk.Application().quit()
        }
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.SingleInstance")
    app.onActivate(UI().activate)
    app.run()
}
""")
            result = invoke([str(args.compiler.resolve()), str(source), "-o",
                             str(work / "single-instance")], work, env)
            assert result.returncode == 0, result.stderr
            result = invoke([sys.executable,
                             str(Path(__file__).with_name("gtk_single_instance.py").resolve()),
                             str(work / "single-instance")], work, env)
            assert result.returncode == 0 and result.stdout == "single-instance\n", result.stderr
            print("PASS real GtkApplication single-instance forwarding")
            # The package's native dependencies must survive separate
            # compilation in the existing object link sidecar.
            source = work / "signals.cw"
            object_file = work / "signals.o"
            result = invoke([str(args.compiler.resolve()), str(source), "-c",
                             "-o", str(object_file)], work, env)
            assert result.returncode == 0, result.stderr
            result = invoke([str(args.compiler.resolve()), str(object_file), str(native),
                             "-o", str(work / "object-consumer")], work, env)
            assert result.returncode == 0, result.stderr
            result = gui_run(work / "object-consumer", work, env)
            assert result.returncode == 0 and result.stdout == expected_signals, result.stderr
            print("PASS compile-only package link sidecar")
            if args.build:
                prefix = work / "installed"
                result = invoke(["cmake", "--install", str(args.build.resolve()),
                                 "--prefix", str(prefix)], work, env)
                assert result.returncode == 0, result.stderr
                source = work / "installed.cw"
                source.write_text("""import gtk
class Handler {
    public:
    void run() { print("installed")
        Gtk.Application().quit() }
}
start {
    Gtk.Application().initialize()
    Gtk.Application().post(Handler().run)
    Gtk.Application().run()
    Gtk.Application().shutdown()
}
""")
                result = invoke([str(prefix / "bin/cwhip"), str(source), "-o",
                                 str(work / "installed") + "-program"], work, env)
                assert result.returncode == 0, result.stderr
                result = gui_run(str(work / "installed") + "-program", work, env)
                assert result.returncode == 0 and result.stdout == "installed", result.stderr
                print("PASS installed consumer")
                result = invoke([str(prefix / "bin/cwhip"), str(work / "signals.cw"),
                                 str(native), "-o", str(work / "installed-signals")], work, env)
                assert result.returncode == 0, result.stderr
                result = gui_run(work / "installed-signals", work, env)
                assert result.returncode == 0 and result.stdout == expected_signals, result.stderr
                print("PASS installed signal consumer")
                project = work / "locked-consumer"
                project.mkdir()
                for command in ("init", "install"):
                    result = invoke([str(prefix / "bin/cwhip-pkg"), command], project, env)
                    assert result.returncode == 0, result.stderr
                assert "gtk" in (project / "cwhip-pkg.lock").read_text()
                source = project / "editor.cw"
                source.write_text((Path(__file__).resolve().parent.parent /
                                   "examples/gtk.cw").read_text())
                result = invoke([str(prefix / "bin/cwhip"), str(source), "-o",
                                 str(project / "editor")], project, env)
                assert result.returncode == 0, result.stderr
                result = gui_run(project / "editor", project, env, ["--test"])
                assert result.returncode == 0 and result.stdout == "Hello GTK" and not result.stderr, result
                print("PASS installed public widgets with cwhip-pkg init/install lock")
                source = project / "plain.cw"
                source.write_text('start { print("plain") }\n')
                result = invoke([str(prefix / "bin/cwhip"), str(source), "-o",
                                 str(project / "plain")], project, env)
                assert result.returncode == 0, result.stderr
                result = invoke(["ldd", str(project / "plain")], project, env)
                assert result.returncode == 0 and not any(
                    name in result.stdout for name in ("libgtk", "libgio", "libgobject")), result.stdout
                print("PASS no-import consumer with a lock containing GTK")
            source = work / "no-import.cw"
            source.write_text('start { print("no gtk") }\n')
            result = invoke([str(args.compiler.resolve()), str(source), "-o",
                             str(work / "no-import")], work, env)
            assert result.returncode == 0, result.stderr
            for output in (work / "no-import", args.compiler.resolve()):
                result = invoke(["ldd", str(output)], work, env)
                assert result.returncode == 0 and not any(
                    name in result.stdout for name in ("libgtk", "libgio", "libgobject")), result.stdout
            print("PASS no-import and compiler linkage")
    print(f"Checked {len(CASES)} GTK cases, object/installed consumers and link isolation")


if __name__ == "__main__":
    main()
