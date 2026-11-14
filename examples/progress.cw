import gtk
import system

// Demonstrates Gtk.ProgressBar: determinate fraction with overlay text,
// and indeterminate pulse mode for unknown ETA.
class Demo {
    public:
    Gtk.Window window
    Gtk.Label readout
    Gtk.ProgressBar determinate
    Gtk.ProgressBar pulsing
    int64 pulses
    void<> tickAction
    void<> testAction

    void updateReadout() {
        readout.setText(format("fraction={}  pulses={}  pulseStep={}",
            determinate.fraction(), pulses, pulsing.pulseStep()))
    }
    void tick() {
        pulses = pulses + 1
        pulsing.pulse()
        updateReadout()
        if (pulses < 3) {
            Gtk.Application().schedule(50, tickAction)
        }
    }
    void test() {
        determinate.setFraction(0.75f64)
        determinate.setText("75%")
        pulsing.setPulseStep(0.2f64)
        pulsing.pulse()
        pulses = pulses + 1
        updateReadout()
        print("Hello ProgressBar")
        window.close()
    }
    void activate() {
        window = Gtk.Window("Cwhip GTK ProgressBar")
        window.setDefaultSize(420, 180)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        window.setChild(root)
        readout = Gtk.Label("progress")
        root.append(readout)

        determinate = Gtk.ProgressBar(Gtk.ProgressBar.HORIZONTAL)
        determinate.setHExpand(true)
        determinate.setShowText(true)
        determinate.setText("developing…")
        determinate.setFraction(0.35f64)
        root.append(determinate)

        pulsing = Gtk.ProgressBar(Gtk.ProgressBar.HORIZONTAL)
        pulsing.setHExpand(true)
        pulsing.setShowText(true)
        pulsing.setText("building…")
        pulsing.setPulseStep(0.15f64)
        root.append(pulsing)

        updateReadout()
        window.present()
        if (System.Process().arg(1).equals("--test")) {
            Gtk.Application().post(testAction)
        } else {
            Gtk.Application().schedule(50, tickAction)
        }
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.ProgressBarDemo")
    Demo demo = Demo()
    demo.tickAction = demo.tick
    demo.testAction = demo.test
    app.onActivate(demo.activate)
    app.run()
    app.shutdown()
}
