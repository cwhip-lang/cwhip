import gtk
import system

// Demonstrates Gtk.SpinButton: range/step configure, get/set value, and
// value-changed callbacks for bounded numeric entry.
class Demo {
    Gtk.Window window
    Gtk.Label readout
    Gtk.SpinButton spin
    fp64 lastValue
    int64 changes
    void<fp64> changedAction
    void<> testAction

    void updateReadout() {
        readout.setText(format("value={}  changes={}", lastValue, changes))
    }
    void moved(fp64 value) {
        lastValue = value
        changes = changes + 1
        updateReadout()
    }
    void test() {
        spin.setValue(42.0f64)
        print("Hello SpinButton")
        window.close()
    }
    void activate() {
        window = Gtk.Window("Cwhip GTK SpinButton")
        window.setDefaultSize(360, 140)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        window.setChild(root)
        readout = Gtk.Label("spin a value")
        root.append(readout)

        spin = Gtk.SpinButton()
        spin.configure(10.0f64, 0.0f64, 100.0f64, 1.0f64)
        spin.setHExpand(true)
        spin.onValueChanged(changedAction)
        lastValue = spin.value()
        root.append(spin)

        window.present()
        if (System.Process().arg(1).equals("--test")) {
            Gtk.Application().post(testAction)
        }
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.SpinButtonDemo")
    Demo demo = Demo()
    demo.changedAction = demo.moved
    demo.testAction = demo.test
    app.onActivate(demo.activate)
    app.run()
    app.shutdown()
}
