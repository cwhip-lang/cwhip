/*
 * examples/gtk.cw — Demonstrates gtk.
 *
 * Created: 2026-10-06
 * Author: chuck
 *
 * Changelog:
 *   2026-10-06  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import gtk
import system

/*
 * Editor is a class, used by this example.
 *
 * Its methods include activate, edit, toggle, close, test.
 */
class Editor {
    public:
    Gtk.Window window
    Gtk.Label preview
    Gtk.Entry entry
    Gtk.CheckButton enabled
    void<String> editAction
    void<bool> toggleAction
    void<> closeAction
    void<> testAction

    /*
     * Handles activate for this Editor.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void activate() {
        if (window != null) {
            if (!window.disposed()) {
                window.present()
                return
            }
        }
        window = Gtk.Window("Cwhip GTK editor")
        window.setDefaultSize(420, 200)
        Gtk.Box layout = Gtk.Box(Gtk.Box.VERTICAL, 8)
        window.setChild(layout)
        preview = Gtk.Label("Type below")
        entry = Gtk.Entry("")
        enabled = Gtk.CheckButton("Enable editing")
        Gtk.Button close = Gtk.Button("Close")
        Gtk.ScrolledWindow scroll = Gtk.ScrolledWindow()
        scroll.setChild(preview)
        layout.append(scroll)
        layout.append(entry)
        layout.append(enabled)
        layout.append(close)
        entry.onChanged(editAction)
        enabled.onToggled(toggleAction)
        close.onClicked(closeAction)
        enabled.setActive(true)
        window.present()
        if (System.Process().arg(1).equals("--test")) {
            Gtk.Application().post(testAction)
        }
    }

    /*
     * Handles edit for this Editor.
     *
     * Parameters:
     *   text — String text.
     *
     * Does not return a value.
     */
    void edit(String text) {
        preview.setText(text)
    }

    /*
     * Handles toggle for this Editor.
     *
     * Parameters:
     *   active — bool active.
     *
     * Does not return a value.
     */
    void toggle(bool active) {
        entry.setSensitive(active)
    }

    /*
     * Closes the Editor state.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void close() {
        window.close()
    }

    /*
     * Handles test for this Editor.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void test() {
        entry.setText("Hello GTK")
        print(preview.text())
        window.close()
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.Editor")
    Editor editor = Editor()
    editor.editAction = editor.edit
    editor.toggleAction = editor.toggle
    editor.closeAction = editor.close
    editor.testAction = editor.test
    app.onActivate(editor.activate)
    app.run()
    app.shutdown()
}
