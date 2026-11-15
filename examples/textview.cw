/*
 * examples/textview.cw — Demonstrates textview.
 *
 * Created: 2026-11-09
 * Author: chuck
 *
 * Changelog:
 *   2026-11-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import gtk
import system

/*
 * Demo is a class, used by this example.
 *
 * Demonstrates Gtk.TextView: multiline set/get text, wrap/editable, and
 * onChanged for compose-style panes.
 */
class Demo {
    public:
    Gtk.Window window
    Gtk.Label readout
    Gtk.TextView body
    int64 changes
    void<String> changedAction
    void<> testAction

    /*
     * Updates readout for this Demo.
     *
     * Parameters:
     *   text — String text.
     *
     * Does not return a value.
     */
    void updateReadout(String text) {
        readout.setText(format("chars={}  changes={}  wrap={}",
            text.length, changes, body.wrap()))
    }

    /*
     * Handles edited for this Demo.
     *
     * Parameters:
     *   text — String text.
     *
     * Does not return a value.
     */
    void edited(String text) {
        changes = changes + 1
        updateReadout(text)
    }

    /*
     * Handles test for this Demo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void test() {
        body.setText("line one\nline two")
        print("Hello TextView")
        window.close()
    }

    /*
     * Handles activate for this Demo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void activate() {
        window = Gtk.Window("Cwhip GTK TextView")
        window.setDefaultSize(420, 240)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        window.setChild(root)
        readout = Gtk.Label("type below")
        root.append(readout)

        Gtk.ScrolledWindow scroll = Gtk.ScrolledWindow()
        scroll.setHExpand(true)
        scroll.setVExpand(true)
        body = Gtk.TextView()
        body.setText("compose…")
        body.onChanged(changedAction)
        scroll.setChild(body)
        root.append(scroll)

        Gtk.Frame framed = Gtk.Frame("Notes")
        Gtk.Expander more = Gtk.Expander("More")
        more.setExpanded(true)
        more.setChild(Gtk.Label("Frame + Expander + Separator demo chrome"))
        framed.setChild(more)
        root.append(framed)
        root.append(Gtk.Separator(Gtk.Separator.HORIZONTAL))

        updateReadout(body.text())
        window.present()
        if (System.Process().arg(1).equals("--test")) {
            Gtk.Application().post(testAction)
        }
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.TextViewDemo")
    Demo demo = Demo()
    demo.changedAction = demo.edited
    demo.testAction = demo.test
    app.onActivate(demo.activate)
    app.run()
    app.shutdown()
}
