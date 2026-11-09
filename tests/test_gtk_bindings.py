"""Real menus, asynchronous native choosers, GC/teardown and view allocations."""
import argparse
from pathlib import Path
import shlex
import subprocess

from gtk_support import headless
from program_runner import environment, invoke


NATIVE = """
import gtk
class F {
    void collect()
    int64 dialogs()
    int64 finalizedObjects()
    int64 finalizedConfirmations()
    void drain(int64 expected)
    int64 receivers()
    void track()
    void respond(String path, bool accept)
    void confirm(bool accept)
    void waitSize(int64 token, int64 width, int64 height, void<> ready)
    void assertMenu(int64 token)
    void resize(int64 token, int64 width, int64 height)
    void click(int64 token, int64 button, fp64 x, fp64 y)
    void drag(int64 token, int64 phase, fp64 startX, fp64 startY, fp64 offsetX, fp64 offsetY)
    void scroll(int64 token, fp64 x, fp64 y, fp64 dx, fp64 dy)
    void popup(int64 token, fp64 x, fp64 y)
    void setBar(int64 token, fp64 value)
    void setScale(int64 token, fp64 value)
}
void F.collect() from "binding_collect"
int64 F.dialogs() from "binding_dialogs"
int64 F.finalizedObjects() from "binding_finalized_objects"
int64 F.finalizedConfirmations() from "binding_finalized_confirmations"
void F.drain(int64 expected) from "binding_drain"
int64 F.receivers() from "binding_receivers"
void F.track() from "binding_track"
void F.respond(String path, bool accept) from "binding_respond"
void F.confirm(bool accept) from "binding_confirm"
void F.waitSize(int64 token, int64 width, int64 height, void<> ready)
    from "binding_wait_size"
void F.assertMenu(int64 token) from "binding_assert_menu"
void F.resize(int64 token, int64 width, int64 height) from "binding_resize"
void F.click(int64 token, int64 button, fp64 x, fp64 y) from "binding_drawing_click"
void F.drag(int64 token, int64 phase, fp64 startX, fp64 startY, fp64 offsetX, fp64 offsetY)
    from "binding_drawing_drag"
void F.scroll(int64 token, fp64 x, fp64 y, fp64 dx, fp64 dy) from "binding_drawing_scroll"
void F.popup(int64 token, fp64 x, fp64 y) from "binding_context_popup"
void F.setBar(int64 token, fp64 value) from "binding_scrollbar_set"
void F.setScale(int64 token, fp64 value) from "binding_scale_set"
"""

SHORTCUT_NATIVE = """
import sourceview
class Keys {
    bool press(int64 token, String trigger)
    void viewProperties(int64 token, int64 tabs, bool enabled)
    void viewDisplay(int64 token, bool whitespace, bool indent)
}
bool Keys.press(int64 token, String trigger) from "binding_shortcut"
void Keys.viewProperties(int64 token, int64 tabs, bool enabled) from "binding_view_properties"
void Keys.viewDisplay(int64 token, bool whitespace, bool indent) from "binding_view_display"
"""

CONFIG = r'''
import system
class UI {
    String original
    String updated
    void<String> savedAction
    void<String> unexpectedAction
    void require(bool condition, String label) {
        if (!condition) {
            System.StandardIO().writeErrorLine(label)
            System.Process().exit(1)
        }
    }
    void activate() {
        Gtk.Window window = Gtk.Window("Config bindings")
        window.present()
        Gtk.Config config = Gtk.Config()
        original = "title = \"kept\"\n[view]\nsize = 12\nwrap = false\nitems = [\"a\", \"b\"]\n"
        require(config.validate(original).equals(""), "valid TOML")
        require(!config.validate("size = [").equals(""), "invalid TOML")
        require(config.value(original, "view", "size").equals("i12"), "integer value")
        require(config.value(original, "view", "wrap").equals("bfalse"), "boolean value")
        require(!config.key(original, "view", 0).equals(""), "key enumeration")
        require(config.arraySize(original, "view", "items") == 2, "array size")
        require(config.item(original, "view", "items", 1, "").equals("sb"), "array item")
        String quoted = format("text = {}\n", config.quote("quote \" slash \\"))
        require(config.validate(quoted).equals("") &&
                config.value(quoted, "", "text").equals("squote \" slash \\"), "quoted value")
        updated = config.merge(original, "[view]\nsize = 18\n")
        require(config.value(updated, "view", "size").equals("i18") &&
                config.value(updated, "", "title").equals("skept"), "merge preserves unrelated keys")
        String removed = config.remove(updated, "view", "items")
        require(config.arraySize(removed, "view", "items") == -1 &&
                config.value(removed, "view", "size").equals("i18"), "remove preserves unrelated keys")
        require(config.fileStatus("config-roundtrip.toml").equals("missing"), "missing file")
        require(config.saveNow("config-roundtrip.toml", original, "").equals(""), "atomic first save")
        require(config.fileStatus("config-roundtrip.toml").equals(""), "existing file")
        require(!config.saveNow("config-roundtrip.toml", updated, "stale").equals(""), "concurrent edit rejected")
        System.File file = System.File("config-roundtrip.toml", "r")
        require(file.readAll().equals(original), "rejected save preserves contents")
        file.close()
        config.save("config-roundtrip.toml", updated, original, savedAction)
        F().collect()
    }
    void saved(String error) {
        require(error.equals(""), "async save callback")
        System.File file = System.File("config-roundtrip.toml", "r")
        require(file.readAll().equals(updated), "async save contents")
        file.close()
        Gtk.Config().save("config-drain.toml", updated, "", unexpectedAction)
        Gtk.Application().shutdown()
        require(System.FileSystem().exists("config-drain.toml"), "shutdown drains pending save")
        print("PASS config")
    }
    void unexpected(String error) {
        require(false, "callback after shutdown")
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingConfig")
    UI ui = UI()
    ui.savedAction = ui.saved
    ui.unexpectedAction = ui.unexpected
    app.onActivate(ui.activate)
    app.run()
}
'''

MENU = """
class Handler {
    void action() { F().collect()
        print("action;") }
}
class Stop {
    void action() { Gtk.Application().shutdown()
        print("stopped;") }
}
class Check {
    void action(bool active) { print(format("check {};", active)) }
}
class UI {
    Gtk.Window window
    Gtk.MenuBar menus
    int64 item
    void activate() {
        window = Gtk.Window("Menu bindings")
        menus = Gtk.MenuBar()
        window.setChild(menus)
        int64 menu = menus.addMenu("File")
        item = menus.addItem(menu, "Open", Handler().action)
        F().assertMenu(menus._widgetToken())
        F().collect()
        menus.activateItem(item)
        menus.setItemEnabled(item, false)
        menus.activateItem(item)
        menus.setItemEnabled(item, true)
        menus.activateItem(item)
        int64 check = menus.addCheckItem(menu, "Numbers", false, Check().action)
        menus.activateItem(check)
        menus.setItemChecked(check, false)
        menus.activateItem(check)
        int64 stop = menus.addItem(menu, "Shutdown", Stop().action)
        menus.activateItem(stop)
        print(menus.disposed())
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingMenus")
    app.onActivate(UI().activate)
    app.run()
}
"""

DIALOG = """
class Relay {
    void<String> target
    Relay(void<String> action) { target = action }
    void deliver(String path) { F().collect()
        target(path) }
    void note()
    destroy { note() }
}
void Relay.note() from "binding_released"
class UI {
    Gtk.Window window
    Gtk.FileDialog dialog
    void<String> resultAction
    int64 phase
    void show(bool save, String path) {
        dialog = Gtk.FileDialog(window, save, path, Relay(resultAction).deliver)
        print(dialog.pending())
        F().track()
        F().collect()
    }
    void result(String path) {
        F().collect()
        print(path)
        print(";")
        print(dialog.pending())
        print(F().dialogs())
        phase = phase + 1
        if (phase == 1) {
            show(false, "")
            F().respond("", false)
            return()}
        if (phase == 2) {
            show(true, "fresh.cw")
            F().respond("fresh.cw", true)
            return()}
        if (phase == 3) {
            show(true, "existing.cw")
            F().respond("existing.cw", true)
            F().confirm(false)
            return()}
        if (phase == 4) {
            show(true, "existing.cw")
            F().respond("existing.cw", true)
            F().confirm(true)
            return()}
        {
            print(F().finalizedObjects() == 5)
            print(F().finalizedConfirmations() == 2)
            show(false, "")
            dialog.cancel()
            dialog.cancel()
            print(dialog.pending())
            print(F().dialogs())
            F().collect()
            print(F().receivers() == 5)
            show(false, "")
            window.dispose()
            print(dialog.pending())
            print(F().dialogs())
            F().collect()
            print(F().receivers() == 6)
            window = Gtk.Window("Shutdown")
            show(false, "")
            Gtk.Application().shutdown()
            print(dialog.pending())
            print(F().dialogs())
            F().collect()
            print(F().receivers() == 7)
        }
    }
    void activate() {
        window = Gtk.Window("Dialog bindings")
        window.present()
        show(false, "existing.cw")
        F().respond("existing.cw", true)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingDialogs")
    UI ui = UI()
    ui.resultAction = ui.result
    app.onActivate(ui.activate)
    app.run()
    F().drain(8)
    print(F().finalizedObjects())
    F().collect()
    print(F().receivers())
}
"""

DRAWING = """
import system
class UI {
    Gtk.Window window
    Gtk.DrawingArea area
    Gtk.DrawingArea paneArea
    Gtk.DrawingArea scrollChild
    Gtk.Scrollbar bar
    Gtk.ContextMenu menu
    int64 paints
    int64 clicks
    int64 drags
    int64 scrolls
    int64 popups
    int64 barChanges
    int64 menuItems
    int64 lastButton
    fp64 lastX
    fp64 lastY
    fp64 lastDx
    fp64 lastDy
    fp64 lastBar
    int64 lastPhase
    void<int64, int64> paintAction
    void<int64, int64> panePaintAction
    void<int64, int64> scrollPaintAction
    void<int64, fp64, fp64> clickAction
    void<int64, fp64, fp64, fp64, fp64> dragAction
    void<fp64, fp64, fp64, fp64> scrollAction
    void<fp64, fp64> popupAction
    void<fp64> barAction
    void<> noopAction
    void<> checkAction
    void require(bool condition, String label) {
        if (!condition) {
            System.StandardIO().writeErrorLine(label)
            System.Process().exit(1)
        }
    }
    void paint(int64 width, int64 height) {
        require(width > 0 && height > 0, "draw size")
        paints = paints + 1
        area.setColor(0.10f64, 0.12f64, 0.18f64, 1.0f64)
        area.fillRect(0.0f64, 0.0f64, width, height)
        area.setColor(0.20f64, 0.70f64, 0.35f64, 1.0f64)
        area.fillCircle(width / 2, height / 2, 24.0f64)
        area.setColor(1.0f64, 1.0f64, 1.0f64, 1.0f64)
        area.setLineWidth(2.0f64)
        area.strokeRect(8.0f64, 8.0f64, width - 16, height - 16)
        area.strokeCircle(width / 2, height / 2, 32.0f64)
        area.strokeLine(0.0f64, 0.0f64, width, height)
    }
    void panePaint(int64 width, int64 height) {
        paneArea.setColor(0.30f64, 0.30f64, 0.55f64, 1.0f64)
        paneArea.fillRect(0.0f64, 0.0f64, width, height)
        paints = paints + 1
    }
    void scrollPaint(int64 width, int64 height) {
        scrollChild.setColor(0.15f64, 0.20f64, 0.25f64, 1.0f64)
        scrollChild.fillRect(0.0f64, 0.0f64, width, height)
        paints = paints + 1
    }
    void clicked(int64 button, fp64 x, fp64 y) {
        clicks = clicks + 1
        lastButton = button
        lastX = x
        lastY = y
    }
    void dragged(int64 phase, fp64 startX, fp64 startY, fp64 offsetX, fp64 offsetY) {
        drags = drags + 1
        lastPhase = phase
        lastX = startX
        lastY = startY
        lastDx = offsetX
        lastDy = offsetY
    }
    void scrolled(fp64 x, fp64 y, fp64 dx, fp64 dy) {
        scrolls = scrolls + 1
        lastX = x
        lastY = y
        lastDx = dx
        lastDy = dy
    }
    void prepareMenu(fp64 x, fp64 y) {
        popups = popups + 1
        lastX = x
        lastY = y
        menu.clear()
        menu.addItem("Status", noopAction)
        menu.addSeparator()
        int64 places = menu.addSubmenu("Places")
        menu.addItem(places, "Home", noopAction)
        menuItems = menuItems + 1
    }
    void barMoved(fp64 value) {
        barChanges = barChanges + 1
        lastBar = value
    }
    void noop() {}
    void check() {
        require(paints >= 3, "expected DrawingArea paints")
        F().click(area._widgetToken(), Gtk.DrawingArea.BUTTON_PRIMARY, 12.5f64, 34.0f64)
        require(clicks == 1 && lastButton == Gtk.DrawingArea.BUTTON_PRIMARY, "click button")
        require(lastX == 12.5f64 && lastY == 34.0f64, "click coords")
        F().drag(area._widgetToken(), Gtk.DrawingArea.DRAG_BEGIN, 10.0f64, 20.0f64, 0.0f64, 0.0f64)
        F().drag(area._widgetToken(), Gtk.DrawingArea.DRAG_UPDATE, 10.0f64, 20.0f64, 5.0f64, -3.0f64)
        F().drag(area._widgetToken(), Gtk.DrawingArea.DRAG_END, 10.0f64, 20.0f64, 8.0f64, -4.0f64)
        require(drags == 3 && lastPhase == Gtk.DrawingArea.DRAG_END, "drag phases")
        require(lastX == 10.0f64 && lastY == 20.0f64, "drag start")
        require(lastDx == 8.0f64 && lastDy == -4.0f64, "drag offset")
        F().scroll(area._widgetToken(), 40.0f64, 50.0f64, 0.0f64, -1.0f64)
        require(scrolls == 1, "scroll count")
        require(lastX == 40.0f64 && lastY == 50.0f64, "scroll focus")
        require(lastDx == 0.0f64 && lastDy == -1.0f64, "scroll delta")
        F().popup(menu._widgetToken(), 64.0f64, 80.0f64)
        require(popups == 1 && menuItems == 1, "context popup rebuild")
        require(lastX == 64.0f64 && lastY == 80.0f64, "popup coords")
        bar.configure(10.0f64, 0.0f64, 100.0f64, 1.0f64, 10.0f64, 20.0f64)
        require(bar.lower() == 0.0f64 && bar.upper() == 100.0f64, "bar range")
        require(bar.pageSize() == 20.0f64, "bar page")
        F().setBar(bar._widgetToken(), 33.0f64)
        require(barChanges >= 1 && lastBar == 33.0f64, "bar value changed")
        require(bar.value() == 33.0f64, "bar getter")
        print("PASS drawing")
        Gtk.Application().quit()
    }
    void activate() {
        window = Gtk.Window("Drawing bindings")
        window.setDefaultSize(420, 280)
        Gtk.Paned split = Gtk.Paned(Gtk.Paned.HORIZONTAL)
        Gtk.Box left = Gtk.Box(Gtk.Box.VERTICAL, 0)
        area = Gtk.DrawingArea()
        area.setContentSize(200, 200)
        area.setHExpand(true)
        area.setVExpand(true)
        area.onDraw(paintAction)
        area.onClick(clickAction)
        area.onDrag(dragAction)
        area.onScroll(scrollAction)
        menu = Gtk.ContextMenu(area)
        menu.onPopup(popupAction)
        bar = Gtk.Scrollbar(Gtk.Scrollbar.HORIZONTAL)
        bar.onValueChanged(barAction)
        left.append(area)
        left.append(bar)
        Gtk.ScrolledWindow scroll = Gtk.ScrolledWindow()
        scroll.setPolicy(Gtk.ScrolledWindow.POLICY_AUTOMATIC, Gtk.ScrolledWindow.POLICY_AUTOMATIC)
        scrollChild = Gtk.DrawingArea()
        scrollChild.setContentSize(400, 400)
        scrollChild.onDraw(scrollPaintAction)
        scroll.setChild(scrollChild)
        left.append(scroll)
        paneArea = Gtk.DrawingArea()
        paneArea.setHExpand(true)
        paneArea.setVExpand(true)
        paneArea.onDraw(panePaintAction)
        split.append(left)
        split.append(paneArea)
        window.setChild(split)
        window.present()
        area.queueDraw()
        paneArea.queueDraw()
        scrollChild.queueDraw()
        Gtk.Application().schedule(250, checkAction)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingDrawing")
    UI ui = UI()
    ui.paintAction = ui.paint
    ui.panePaintAction = ui.panePaint
    ui.scrollPaintAction = ui.scrollPaint
    ui.clickAction = ui.clicked
    ui.dragAction = ui.dragged
    ui.scrollAction = ui.scrolled
    ui.popupAction = ui.prepareMenu
    ui.barAction = ui.barMoved
    ui.noopAction = ui.noop
    ui.checkAction = ui.check
    app.onActivate(ui.activate)
    app.run()
}
"""

SCALE = """
import system
class UI {
    Gtk.Window window
    Gtk.Scale horizontal
    Gtk.Scale vertical
    int64 hChanges
    int64 vChanges
    fp64 lastH
    fp64 lastV
    void<fp64> hAction
    void<fp64> vAction
    void<> checkAction
    void require(bool condition, String label) {
        if (!condition) {
            System.StandardIO().writeErrorLine(label)
            System.Process().exit(1)
        }
    }
    void hMoved(fp64 value) {
        hChanges = hChanges + 1
        lastH = value
    }
    void vMoved(fp64 value) {
        vChanges = vChanges + 1
        lastV = value
    }
    void check() {
        require(horizontal.lower() == 0.0f64 && horizontal.upper() == 100.0f64, "h range")
        require(horizontal.step() == 0.5f64, "h step")
        require(horizontal.value() == 50.0f64, "h initial")
        require(vertical.lower() == 1.0f64 && vertical.upper() == 10.0f64, "v range")
        require(vertical.step() == 1.0f64, "v step")
        require(vertical.value() == 5.0f64, "v initial")
        F().setScale(horizontal._widgetToken(), 25.5f64)
        require(hChanges >= 1 && lastH == 25.5f64, "h value changed")
        require(horizontal.value() == 25.5f64, "h getter")
        vertical.setValue(8.0f64)
        require(vChanges >= 1 && lastV == 8.0f64, "v setValue callback")
        require(vertical.value() == 8.0f64, "v getter")
        horizontal.configure(3.0f64, -5.0f64, 5.0f64, 0.25f64)
        require(horizontal.lower() == -5.0f64 && horizontal.upper() == 5.0f64, "reconfigure range")
        require(horizontal.step() == 0.25f64, "reconfigure step")
        require(horizontal.value() == 3.0f64, "reconfigure value")
        print("PASS scale")
        Gtk.Application().quit()
    }
    void activate() {
        window = Gtk.Window("Scale bindings")
        window.setDefaultSize(360, 200)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        horizontal = Gtk.Scale(Gtk.Scale.HORIZONTAL)
        horizontal.configure(50.0f64, 0.0f64, 100.0f64, 0.5f64)
        horizontal.onValueChanged(hAction)
        vertical = Gtk.Scale(Gtk.Scale.VERTICAL)
        vertical.configure(5.0f64, 1.0f64, 10.0f64, 1.0f64)
        vertical.onValueChanged(vAction)
        root.append(horizontal)
        root.append(vertical)
        window.setChild(root)
        window.present()
        Gtk.Application().schedule(100, checkAction)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingScale")
    UI ui = UI()
    ui.hAction = ui.hMoved
    ui.vAction = ui.vMoved
    ui.checkAction = ui.check
    app.onActivate(ui.activate)
    app.run()
}
"""

PROGRESS = """
import system
class UI {
    Gtk.Window window
    Gtk.ProgressBar bar
    Gtk.ProgressBar vertical
    void<> checkAction
    void require(bool condition, String label) {
        if (!condition) {
            System.StandardIO().writeErrorLine(label)
            System.Process().exit(1)
        }
    }
    void check() {
        require(bar.fraction() == 0.0f64, "default fraction")
        require(!bar.showText(), "default showText")
        require(bar.text().equals(""), "default text")
        require(bar.pulseStep() == 0.1f64, "default pulse step")
        bar.setShowText(true)
        bar.setText("working")
        bar.setFraction(0.4f64)
        require(bar.showText(), "showText on")
        require(bar.text().equals("working"), "custom text")
        require(bar.fraction() == 0.4f64, "fraction set")
        bar.setText("")
        require(bar.text().equals(""), "cleared text")
        bar.setPulseStep(0.25f64)
        require(bar.pulseStep() == 0.25f64, "pulse step")
        bar.pulse()
        vertical.setFraction(1.0f64)
        require(vertical.fraction() == 1.0f64, "vertical fraction")
        print("PASS progress")
        Gtk.Application().quit()
    }
    void activate() {
        window = Gtk.Window("ProgressBar bindings")
        window.setDefaultSize(360, 160)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        bar = Gtk.ProgressBar(Gtk.ProgressBar.HORIZONTAL)
        vertical = Gtk.ProgressBar(Gtk.ProgressBar.VERTICAL)
        root.append(bar)
        root.append(vertical)
        window.setChild(root)
        window.present()
        Gtk.Application().schedule(100, checkAction)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingProgress")
    UI ui = UI()
    ui.checkAction = ui.check
    app.onActivate(ui.activate)
    app.run()
}
"""

SPIN = """
import system
class UI {
    Gtk.Window window
    Gtk.SpinButton spin
    int64 changes
    fp64 last
    void<fp64> changedAction
    void<> checkAction
    void require(bool condition, String label) {
        if (!condition) {
            System.StandardIO().writeErrorLine(label)
            System.Process().exit(1)
        }
    }
    void moved(fp64 value) {
        changes = changes + 1
        last = value
    }
    void check() {
        require(spin.lower() == 0.0f64 && spin.upper() == 100.0f64, "range")
        require(spin.step() == 1.0f64, "step")
        require(spin.value() == 10.0f64, "initial")
        spin.setValue(42.0f64)
        require(changes >= 1 && last == 42.0f64, "setValue callback")
        require(spin.value() == 42.0f64, "getter")
        spin.configure(3.0f64, -5.0f64, 5.0f64, 0.25f64)
        require(spin.lower() == -5.0f64 && spin.upper() == 5.0f64, "reconfigure range")
        require(spin.step() == 0.25f64, "reconfigure step")
        require(spin.value() == 3.0f64, "reconfigure value")
        print("PASS spin")
        Gtk.Application().quit()
    }
    void activate() {
        window = Gtk.Window("SpinButton bindings")
        window.setDefaultSize(320, 120)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        spin = Gtk.SpinButton()
        spin.configure(10.0f64, 0.0f64, 100.0f64, 1.0f64)
        spin.onValueChanged(changedAction)
        root.append(spin)
        window.setChild(root)
        window.present()
        Gtk.Application().schedule(100, checkAction)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingSpin")
    UI ui = UI()
    ui.changedAction = ui.moved
    ui.checkAction = ui.check
    app.onActivate(ui.activate)
    app.run()
}
"""

DROPDOWN = """
import system
class UI {
    Gtk.Window window
    Gtk.DropDown drop
    int64 changes
    int64 last
    void<int64> selectedAction
    void<> checkAction
    void require(bool condition, String label) {
        if (!condition) {
            System.StandardIO().writeErrorLine(label)
            System.Process().exit(1)
        }
    }
    void picked(int64 index) {
        changes = changes + 1
        last = index
    }
    void check() {
        require(drop.size() == 3, "size")
        require(drop.selected() == 0, "initial selected")
        require(drop.selectedText().equals("alpha"), "initial text")
        require(drop.item(1).equals("beta"), "item")
        drop.setSelected(2)
        require(changes >= 1 && last == 2, "setSelected callback")
        require(drop.selectedText().equals("gamma"), "selected text")
        drop.clear()
        require(drop.size() == 0, "cleared size")
        require(drop.selected() == -1, "cleared selected")
        drop.append("one")
        drop.append("two")
        drop.setSelected(1)
        require(drop.selectedText().equals("two"), "append select")
        drop.setChoices(["x", "y"])
        require(drop.size() == 2 && drop.selected() == 0, "setChoices")
        require(drop.selectedText().equals("x"), "setChoices text")
        drop.setSelected(1)
        drop.setChoices(["x", "y", "z"])
        require(drop.selected() == 1 && drop.selectedText().equals("y"),
            "setChoices keeps prior")
        print("PASS dropdown")
        Gtk.Application().quit()
    }
    void activate() {
        window = Gtk.Window("DropDown bindings")
        window.setDefaultSize(320, 120)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        drop = Gtk.DropDown()
        drop.setChoices(["alpha", "beta", "gamma"])
        drop.onSelected(selectedAction)
        root.append(drop)
        window.setChild(root)
        window.present()
        Gtk.Application().schedule(100, checkAction)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingDropDown")
    UI ui = UI()
    ui.selectedAction = ui.picked
    ui.checkAction = ui.check
    app.onActivate(ui.activate)
    app.run()
}
"""

TEXTVIEW = """
import system
class UI {
    Gtk.Window window
    Gtk.TextView view
    Gtk.Frame frame
    Gtk.Expander expander
    Gtk.Separator separator
    int64 changes
    String last
    void<String> changedAction
    void<> checkAction
    void require(bool condition, String label) {
        if (!condition) {
            System.StandardIO().writeErrorLine(label)
            System.Process().exit(1)
        }
    }
    void edited(String text) {
        changes = changes + 1
        last = text
    }
    void check() {
        require(view.editable(), "default editable")
        require(view.wrap(), "default wrap")
        require(view.text().equals("hello"), "initial text")
        view.setText("line one\\nline two")
        require(changes >= 1 && last.equals("line one\\nline two"), "setText callback")
        require(view.text().equals("line one\\nline two"), "getter")
        view.setEditable(false)
        require(!view.editable(), "editable off")
        view.setWrap(false)
        require(!view.wrap(), "wrap off")
        require(frame.label().equals("Section"), "frame label")
        frame.setLabel("Updated")
        require(frame.label().equals("Updated"), "frame relabel")
        require(!expander.expanded(), "expander default")
        expander.setExpanded(true)
        require(expander.expanded(), "expander open")
        require(expander.label().equals("More"), "expander label")
        print("PASS textview")
        Gtk.Application().quit()
    }
    void activate() {
        window = Gtk.Window("TextView bindings")
        window.setDefaultSize(360, 220)
        Gtk.Box root = Gtk.Box(Gtk.Box.VERTICAL, 8)
        view = Gtk.TextView()
        view.setText("hello")
        view.onChanged(changedAction)
        frame = Gtk.Frame("Section")
        expander = Gtk.Expander("More")
        expander.setChild(Gtk.Label("inside"))
        frame.setChild(expander)
        separator = Gtk.Separator(Gtk.Separator.HORIZONTAL)
        root.append(view)
        root.append(frame)
        root.append(separator)
        window.setChild(root)
        window.present()
        Gtk.Application().schedule(100, checkAction)
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingTextView")
    UI ui = UI()
    ui.changedAction = ui.edited
    ui.checkAction = ui.check
    app.onActivate(ui.activate)
    app.run()
}
"""

LIFETIME = """
import system
class Relay {
    void received(String path) { System.Process().exit(1) }
    void receivedMany(list paths) { System.Process().exit(1) }
    void note()
    destroy { note() }
}
void Relay.note() from "binding_released"
class UI {
    Gtk.Window window
    Gtk.FileDialog dialog
    void show() {
        String operation = System.Process().getEnv("BINDING_OPERATION")
        if (operation.equals("open")) {
            dialog = Gtk.FileDialog(window, false, "", Relay().received)
        }
        if (operation.equals("save")) {
            dialog = Gtk.FileDialog(window, true, "", Relay().received)
        }
        if (operation.equals("multiple")) {
            dialog = Gtk.FileDialog(window, "", Relay().receivedMany)
        }
        if (operation.equals("folder")) {
            dialog = Gtk.FileDialog(window, "", Relay().received)
        }
        F().track()
    }
    void teardown() {
        String teardown = System.Process().getEnv("BINDING_TEARDOWN")
        if (teardown.equals("cancel")) {
            dialog.cancel()
            dialog.cancel()
        }
        if (teardown.equals("parent")) { window.dispose() }
        if (teardown.equals("shutdown")) { Gtk.Application().shutdown() }
        if (dialog.pending() || F().dialogs() != 0) { System.Process().exit(1) }
        dialog = null
    }
    void activate() {
        window = Gtk.Window("Dialog lifetime")
        window.present()
        show()
        teardown()
        F().collect()
        if (F().receivers() != 1) { System.Process().exit(1) }
        if (!window.disposed()) { window.dispose() }
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingLifetime")
    UI ui = UI()
    app.onActivate(ui.activate)
    app.run()
    F().drain(1)
    print("PASS lifetime")
}
"""

# SourceView cases live under tests/repro/gtk/ for hand editing and repro.
_REPRO_GTK = Path(__file__).resolve().parent / "repro" / "gtk"
SOURCEVIEW = (_REPRO_GTK / "sourceview_allocation.cw").read_text()
SOURCEVIEW_EDITING = (_REPRO_GTK / "sourceview_editing.cw").read_text()
# Shortcut callbacks that dispose their own view (closing a tab) or the whole
# window (quitting) must not release their in-flight callback registration.
SHORTCUTS = (_REPRO_GTK / "shortcuts_dispose.cw").read_text()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--clang", default="clang")
    parser.add_argument("--work", type=Path, required=True)
    parser.add_argument("--xvfb", required=True)
    parser.add_argument("--sourceview", action="store_true")
    parser.add_argument("--sanitize", default="")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    work = args.work.resolve()
    work.mkdir(parents=True, exist_ok=True)
    env = environment(work)
    flags = shlex.split(subprocess.check_output(
        ["pkg-config", "--cflags", "gtksourceview-5" if args.sourceview else "gtk4"],
        text=True))
    if args.sourceview:
        languages = root / "stdlib/sourceview/0.1.0/language-specs"
        flags += ["-DCWHIP_GTK_SOURCEVIEW=1",
                  f'-DCWHIP_GTK_SOURCEVIEW_SOURCE_LANG_DIR="{languages}"',
                  f'-DCWHIP_GTK_SOURCEVIEW_INSTALL_LANG_DIR="{languages}"']
    if args.sanitize:
        flags.append(f"-fsanitize={args.sanitize}")
    native = work / "fixture.o"
    result = invoke([args.clang, "-std=c11", "-Wall", "-Wextra", "-Werror",
                     "-Wno-deprecated-declarations", "-I", str(root / "include"),
                     "-c", str(root / "tests/gtk_bindings_fixture.c"), "-o",
                     str(native), *flags], work, env)
    assert result.returncode == 0, result.stderr
    existing = work / "existing.cw"
    existing.write_text("unchanged")
    fresh = work / "fresh.cw"
    fresh.unlink(missing_ok=True)
    for name in ("config-roundtrip.toml", "config-drain.toml"):
        (work / name).unlink(missing_ok=True)
    dialog = DIALOG.replace('"existing.cw"', f'"{existing}"').replace(
        '"fresh.cw"', f'"{fresh}"')
    expected_dialog = (f"true{existing};false0true;false0true{fresh};false0"
                       f"true;false0true{existing};false0truetrue"
                       "truefalse0truetruefalse0truetruefalse0true88")
    cases = [("config", CONFIG, "PASS config"),
             ("menus", MENU, "action;action;check true;check true;stopped;true"),
             ("dialogs", dialog, expected_dialog),
             ("drawing", DRAWING, "PASS drawing"),
             ("scale", SCALE, "PASS scale"),
             ("progress", PROGRESS, "PASS progress"),
             ("spin", SPIN, "PASS spin"),
             ("dropdown", DROPDOWN, "PASS dropdown"),
             ("textview", TEXTVIEW, "PASS textview"),
             ("lifetime", LIFETIME, "PASS lifetime")]
    if args.sourceview:
        cases.append(("sourceview-editing", SHORTCUT_NATIVE + SOURCEVIEW_EDITING,
                      "PASS sourceview editing"))
        cases.append(("allocation", SOURCEVIEW, "falsetruetruetruetruetruetruetruemultiline;grew;"))
        cases.append(("shortcuts", SHORTCUT_NATIVE + SHORTCUTS,
                      "truetrueclosed;truequit;true2"))
    with headless(args.xvfb, work, env) as env:
        for name, program, expected in cases:
            source = work / f"{name}.cw"
            source.write_text(NATIVE + program)
            output = work / name
            result = invoke([str(args.compiler.resolve()), str(source), str(native),
                             "-o", str(output)], work, env)
            assert result.returncode == 0, f"{name}: {result.stderr}"
            runs = [(name, env)]
            if name == "lifetime":
                runs = [(f"{operation}-{teardown}",
                         dict(env, BINDING_OPERATION=operation, BINDING_TEARDOWN=teardown))
                        for operation in ("open", "save", "multiple", "folder")
                        for teardown in ("cancel", "parent", "shutdown")]
            for case, case_env in runs:
                result = invoke([str(output)], work, case_env)
                assert result.returncode == 0, f"{case}: {result.stderr}\n{result.stdout}"
                assert result.stdout == expected, (case, result.stdout, expected, result.stderr)
                assert "CRITICAL" not in result.stderr and "ERROR" not in result.stderr, result.stderr
                assert existing.read_text() == "unchanged" and not fresh.exists()
                print(f"PASS {case}")


if __name__ == "__main__":
    main()
