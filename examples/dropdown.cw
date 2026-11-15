/*
 * examples/dropdown.cw — Demonstrates dropdown.
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
 * Demonstrates Gtk.DropDown: setChoices, selected index/text, and onSelected
 * callbacks for enum-style pickers.
 */
class Demo {
    public:
    Gtk.Window window
    Gtk.Label readout
    Gtk.DropDown role
    int64 lastIndex
    String lastText
    int64 changes
    void<int64> selectedAction
    void<> testAction

    /*
     * Updates readout for this Demo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void updateReadout() {
        readout.setText(format(
                "index={}  text={}  changes={}",
            lastIndex,
                lastText,
                changes))
    }

    /*
     * Handles picked for this Demo.
     *
     * Parameters:
     *   index — int64 index.
     *
     * Does not return a value.
     */
    void picked(int64 index) {
        lastIndex = index
        lastText = role.selectedText()
        changes = changes + 1
        updateReadout()
    }

    /*
     * Handles test for this Demo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void test() {
        role.setSelected(2)
        print("Hello DropDown")
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
