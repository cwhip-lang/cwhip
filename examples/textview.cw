import gtk
import system

// Demonstrates Gtk.TextView: multiline set/get text, wrap/editable, and
// onChanged for compose-style panes.
class Demo {
    Gtk.Window window
    Gtk.Label readout
    Gtk.TextView body
    int64 changes
    void<String> changedAction
    void<> testAction

    void updateReadout(String text) {
        readout.setText(format("chars={}  changes={}  wrap={}",
            text.length, changes, body.wrap()))
    }
    void edited(String text) {
        changes = changes + 1
        updateReadout(text)
    }
    void test() {
        body.setText("line one\nline two")
        print("Hello TextView")
        window.close()
    }
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
