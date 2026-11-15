/*
 * examples/drawing.cw — Demonstrates drawing.
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
 * Demonstrates DrawingArea view chrome: custom Scrollbars tied to pan/zoom
 * extents (path 2) plus ContextMenu owner/onPopup rebuild. Path 1
 * (ScrolledWindow + setContentSize) is documented in doc/GTK.md.
 */
class Demo {
    public:
    Gtk.DrawingArea area
    Gtk.Scrollbar hBar
    Gtk.Scrollbar vBar
    Gtk.ContextMenu menu
    int64 paints
    int64 clicks
    int64 drags
    int64 scrolls
    int64 popups
    int64 menuActions
    fp64 markX
    fp64 markY
    fp64 panX
    fp64 panY
    fp64 dragOriginX
    fp64 dragOriginY
    fp64 zoom
    fp64 viewW
    fp64 viewH
    bool syncingBars
    void<> doneAction
    void<int64, int64> paintAction
    void<int64, fp64, fp64> clickAction
    void<int64, fp64, fp64, fp64, fp64> dragAction
    void<fp64, fp64, fp64, fp64> scrollAction
    void<fp64, fp64> popupAction
    void<fp64> hScrollAction
    void<fp64> vScrollAction
    void<> jumpAction

    /*
     * Handles sync bars for this Demo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void syncBars() {
        fp64 world = 800.0f64 * zoom
        fp64 pageW = viewW
        fp64 pageH = viewH
        if (pageW < 1.0f64) {
            pageW = 1.0f64
        }
        if (pageH < 1.0f64) {
            pageH = 1.0f64
        }
        fp64 upperW = world
        fp64 upperH = world
        if (upperW < pageW) {
            upperW = pageW
        }
        if (upperH < pageH) {
            upperH = pageH
        }
        fp64 valueX = -panX
        fp64 valueY = -panY
        syncingBars = true
        hBar.configure(valueX, 0.0f64, upperW, 16.0f64, pageW, pageW)
        vBar.configure(valueY, 0.0f64, upperH, 16.0f64, pageH, pageH)
        syncingBars = false
    }

    /*
     * Handles paint for this Demo.
     *
     * Parameters:
     *   width — int64 width.
     *   height — int64 height.
     *
     * Does not return a value.
     */
    void paint(int64 width, int64 height) {
        paints = paints + 1
        viewW = width
        viewH = height
        area.setColor(0.12f64, 0.14f64, 0.20f64, 1.0f64)
        area.fillRect(0.0f64, 0.0f64, width, height)
        fp64 cx = width / 2 + panX
        fp64 cy = height / 2 + panY
        fp64 radius = 48.0f64 * zoom
        area.setColor(0.25f64, 0.75f64, 0.40f64, 1.0f64)
        area.fillCircle(cx, cy, radius)
        area.setColor(1.0f64, 1.0f64, 1.0f64, 1.0f64)
        area.setLineWidth(2.0f64)
        area.strokeCircle(cx, cy, radius + 8.0f64)
        if (clicks > 0) {
            area.setColor(0.95f64, 0.55f64, 0.20f64, 1.0f64)
            area.fillCircle(markX, markY, 6.0f64)
        }
        area.strokeRect(24.0f64, 24.0f64, width - 48, height - 48)
        syncBars()
    }

    /*
     * Handles clicked for this Demo.
     *
     * Parameters:
     *   button — int64 button.
     *   x — fp64 input value.
     *   y — fp64 input value.
     *
     * Does not return a value.
     */
    void clicked(int64 button, fp64 x, fp64 y) {
        if (button != Gtk.DrawingArea.BUTTON_PRIMARY) {
            return
        }
        clicks = clicks + 1
        markX = x
        markY = y
        area.queueDraw()
    }

    /*
     * Handles dragged for this Demo.
     *
     * Parameters:
     *   phase — int64 phase.
     *   startX — fp64 start x.
     *   startY — fp64 start y.
     *   offsetX — fp64 offset x.
     *   offsetY — fp64 offset y.
     *
     * Does not return a value.
     */
    void dragged(
            int64 phase,
            fp64 startX,
            fp64 startY,
            fp64 offsetX,
            fp64 offsetY) {
        if (phase == Gtk.DrawingArea.DRAG_BEGIN) {
            dragOriginX = panX
            dragOriginY = panY
            markX = startX
            markY = startY
        }
        panX = dragOriginX + offsetX
        panY = dragOriginY + offsetY
        drags = drags + 1
        area.queueDraw()
    }

    /*
     * Handles scrolled for this Demo.
     *
     * Parameters:
     *   x — fp64 input value.
     *   y — fp64 input value.
     *   dx — fp64 input value.
     *   dy — fp64 input value.
     *
     * Does not return a value.
     */
    void scrolled(fp64 x, fp64 y, fp64 dx, fp64 dy) {
        markX = x + dx
        markY = y
        if (dy < 0.0f64) {
            zoom = zoom * 1.1f64
        }
        if (dy > 0.0f64) {
            zoom = zoom / 1.1f64
        }
        if (zoom < 0.25f64) {
            zoom = 0.25f64
        }
        if (zoom > 4.0f64) {
            zoom = 4.0f64
        }
        scrolls = scrolls + 1
        area.queueDraw()
    }

    /*
     * Handles h scrolled for this Demo.
     *
     * Parameters:
     *   value — fp64 value.
     *
     * Does not return a value.
     */
    void hScrolled(fp64 value) {
        if (syncingBars) {
            return
        }
        panX = -value
        area.queueDraw()
    }

    /*
     * Handles v scrolled for this Demo.
     *
     * Parameters:
     *   value — fp64 value.
     *
     * Does not return a value.
     */
    void vScrolled(fp64 value) {
        if (syncingBars) {
            return
        }
        panY = -value
        area.queueDraw()
    }

    /*
     * Handles jump home for this Demo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void jumpHome() {
        menuActions = menuActions + 1
        panX = 0.0f64
        panY = 0.0f64
        zoom = 1.0f64
        area.queueDraw()
    }

    /*
     * Handles prepare menu for this Demo.
     *
     * Parameters:
     *   x — fp64 input value.
     *   y — fp64 input value.
     *
     * Does not return a value.
     */
    void prepareMenu(fp64 x, fp64 y) {
        popups = popups + 1
        markX = x
        markY = y
        menu.clear()
        menu.addItem("Mark here", jumpAction)
        menu.addSeparator()
        menu.addItem("Reset view", jumpAction)
        int64 places = menu.addSubmenu("Known places")
        menu.addItem(places, "Origin", jumpAction)
    }

    /*
     * Handles done for this Demo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void done() {
        if (paints < 1) {
            System.StandardIO().writeErrorLine("DrawingArea did not paint")
            System.Process().exit(1)
        }
        print("Hello DrawingArea")
        Gtk.Application().quit()
    }

    /*
     * Handles activate for this Demo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void activate() {
        zoom = 1.0f64
        Gtk.Window window = Gtk.Window("DrawingArea demo")
        window.setDefaultSize(520, 360)
        Gtk.Grid layout = Gtk.Grid(0)
        area = Gtk.DrawingArea()
        area.setHExpand(true)
        area.setVExpand(true)
        area.onDraw(paintAction)
        area.onClick(clickAction)
        area.onDrag(dragAction)
        area.onScroll(scrollAction)
        hBar = Gtk.Scrollbar(Gtk.Scrollbar.HORIZONTAL)
        vBar = Gtk.Scrollbar(Gtk.Scrollbar.VERTICAL)
        hBar.onValueChanged(hScrollAction)
        vBar.onValueChanged(vScrollAction)
        layout.attach(area, 0, 0, 1, 1)
        layout.attach(vBar, 1, 0, 1, 1)
        layout.attach(hBar, 0, 1, 1, 1)
        menu = Gtk.ContextMenu(area)
        menu.onPopup(popupAction)
        window.setChild(layout)
        window.present()
        area.queueDraw()
        if (System.Process().arg(1).equals("--test")) {
            Gtk.Application().schedule(250, doneAction)
        }
        else {
            Gtk.Application().schedule(8000, doneAction)
        }
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.DrawingDemo")
    Demo demo = Demo()
    demo.paintAction = demo.paint
    demo.clickAction = demo.clicked
    demo.dragAction = demo.dragged
    demo.scrollAction = demo.scrolled
    demo.popupAction = demo.prepareMenu
    demo.hScrollAction = demo.hScrolled
    demo.vScrollAction = demo.vScrolled
    demo.jumpAction = demo.jumpHome
    demo.doneAction = demo.done
    app.onActivate(demo.activate)
    app.run()
}
