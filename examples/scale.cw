/*
 * examples/scale.cw — Demonstrates scale.
 *
 * Created: 2026-11-07
 * Author: chuck
 *
 * Changelog:
 *   2026-11-07  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import gtk
import system

/*
 * Demo is a class, used by this example.
 *
 * Demonstrates Gtk.Scale: range/step configure, get/set value, and
 * value-changed callbacks for horizontal and vertical sliders.
 */
class Demo {
    public:
    Gtk.Window window
    Gtk.Label readout
    Gtk.Scale horizontal
    Gtk.Scale vertical
    fp64 lastHorizontal
    fp64 lastVertical
    int64 changes
    void<fp64> horizontalAction
    void<fp64> verticalAction
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
                "H={}  V={}  changes={}",
            lastHorizontal,
                lastVertical,
                changes))
    }

    /*
     * Handles horizontal moved for this Demo.
     *
     * Parameters:
     *   value — fp64 value.
     *
     * Does not return a value.
     */
    void horizontalMoved(fp64 value) {
        lastHorizontal = value
        changes = changes + 1
        updateReadout()
    }

    /*
     * Handles vertical moved for this Demo.
     *
     * Parameters:
     *   value — fp64 value.
     *
     * Does not return a value.
     */
    void verticalMoved(fp64 value) {
        lastVertical = value
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
        horizontal.setValue(25.0f64)
        vertical.setValue(7.0f64)
        print("Hello Scale")
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
        window = Gtk.Window("Cwhip GTK Scale")
        window.setDefaultSize(420, 220)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        window.setChild(root)
        readout = Gtk.Label("move a slider")
        root.append(readout)

        horizontal = Gtk.Scale(Gtk.Scale.HORIZONTAL)
        horizontal.configure(50.0f64, 0.0f64, 100.0f64, 0.5f64)
        horizontal.setHExpand(true)
        horizontal.onValueChanged(horizontalAction)
        lastHorizontal = horizontal.value()
        root.append(horizontal)

        Gtk.Box row = Gtk.Box(Gtk.Box.HORIZONTAL, 8)
        vertical = Gtk.Scale(Gtk.Scale.VERTICAL)
        vertical.configure(5.0f64, 1.0f64, 10.0f64, 1.0f64)
        vertical.setVExpand(true)
        vertical.onValueChanged(verticalAction)
        lastVertical = vertical.value()
        row.append(vertical)
        row.append(Gtk.Label("vertical 1..10"))
        root.append(row)

        window.present()
        if (System.Process().arg(1).equals("--test")) {
            Gtk.Application().post(testAction)
        }
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.ScaleDemo")
    Demo demo = Demo()
    demo.horizontalAction = demo.horizontalMoved
    demo.verticalAction = demo.verticalMoved
    demo.testAction = demo.test
    app.onActivate(demo.activate)
    app.run()
    app.shutdown()
}
