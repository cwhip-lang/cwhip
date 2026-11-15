/*
 * tests/repro/gtk/sourceview_allocation.cw — sourceview allocation.
 *
 * Created: 2026-10-30
 * Author: chuck
 *
 * Changelog:
 *   2026-10-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import sourceview

/*
 * UI is a class, used as a fixture by this test.
 *
 * Its methods include changed, cursor, activate, allocated, resized.
 */
class UI {
    public:
    Gtk.Window window
    GtkSource.View view
    void<> allocatedAction
    void<> resizedAction
    void<> changedAction
    void<> cursorAction
    bool seenUndo
    bool seenRedo
    bool seenSelection

    /*
     * Handles changed for this UI.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void changed() {
        seenUndo = view.canUndo()
        seenRedo = view.canRedo() }

    /*
     * Stores view.hasSelection() in seenSelection.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void cursor() {
        seenSelection = view.hasSelection()
    }

    /*
     * Handles activate for this UI.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void activate() {
        window = Gtk.Window("Allocation bindings")
        window.setDefaultSize(640, 480)
        Gtk.Box box = Gtk.Box(Gtk.Box.VERTICAL, 0)
        window.setChild(box)
        Gtk.Notebook notebook = Gtk.Notebook()
        notebook.setHExpand(true)
        notebook.setVExpand(true)
        box.append(notebook)
        Gtk.ScrolledWindow scroll = Gtk.ScrolledWindow()
        scroll.setHExpand(true)
        scroll.setVExpand(true)
        notebook.appendPage(scroll, "Document")
        view = GtkSource.View()
        view.widget().setHExpand(true)
        view.widget().setVExpand(true)
        scroll.setChild(view.widget())
        view.setText("one\\ntwo\\nthree\\nfour\\nfive\\nsix\\nseven\\neight\\n")
        view.onChanged(changedAction)
        view.onCursorMoved(cursorAction)
        print(view.hasSelection())
        view.selectAll()
        print(view.hasSelection())
        print(seenSelection)
        view.copy()
        view.cut()
        print(view.text())
        print(view.canUndo())
        print(seenUndo == view.canUndo())
        view.undo()
        print(view.canRedo())
        print(seenRedo == view.canRedo())
        view.redo()
        view.paste()
        window.present()
        view.focus()
        F().waitSize(view._widgetToken(), 500, 300, allocatedAction)
    }

    /*
     * Handles allocated for this UI.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void allocated() {
        print(view.text().equals(
                "one\\ntwo\\nthree\\nfour\\nfive\\nsix\\nseven\\neight\\n"))
        print("multiline;")
        F().resize(window._widgetToken(), 900, 720)
        F().waitSize(view._widgetToken(), 760, 550, resizedAction)
    }

    /*
     * Handles resized for this UI.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void resized() {
        print("grew;")
        Gtk.Entry entry = Gtk.Entry("search")
        entry.focus()
        entry.dispose()
        window.dispose()
        Gtk.Application().quit()
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingAllocation")
    UI ui = UI()
    ui.allocatedAction = ui.allocated
    ui.resizedAction = ui.resized
    ui.changedAction = ui.changed
    ui.cursorAction = ui.cursor
    app.onActivate(ui.activate)
    app.run()
}
