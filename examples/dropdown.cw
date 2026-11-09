import gtk
import system

// Demonstrates Gtk.DropDown: setChoices, selected index/text, and
// onSelected callbacks for enum-style pickers.
class Demo {
    Gtk.Window window
    Gtk.Label readout
    Gtk.DropDown role
    int64 lastIndex
    String lastText
    int64 changes
    void<int64> selectedAction
    void<> testAction

    void updateReadout() {
        readout.setText(format("index={}  text={}  changes={}",
            lastIndex, lastText, changes))
    }
    void picked(int64 index) {
        lastIndex = index
        lastText = role.selectedText()
        changes = changes + 1
        updateReadout()
    }
    void test() {
        role.setSelected(2)
        print("Hello DropDown")
        window.close()
    }
    void activate() {
        window = Gtk.Window("Cwhip GTK DropDown")
        window.setDefaultSize(360, 140)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        window.setChild(root)
        readout = Gtk.Label("pick a role")
        root.append(readout)

        role = Gtk.DropDown()
        role.setChoices(["neutral", "conqueror", "pirate", "trader", "hermit"])
        role.setSelected(0)
        role.onSelected(selectedAction)
        lastIndex = role.selected()
        lastText = role.selectedText()
        root.append(role)

        window.present()
        if (System.Process().arg(1).equals("--test")) {
            Gtk.Application().post(testAction)
        }
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.DropDownDemo")
    Demo demo = Demo()
    demo.selectedAction = demo.picked
    demo.testAction = demo.test
    app.onActivate(demo.activate)
    app.run()
    app.shutdown()
}
