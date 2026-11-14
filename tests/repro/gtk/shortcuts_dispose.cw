class Action {
    public:
    Gtk.Window window
    Gtk.Notebook notebook
    Gtk.ScrolledWindow page
    Action(Gtk.Window owner, Gtk.Notebook pages, Gtk.ScrolledWindow closing) {
        window = owner
        notebook = pages
        page = closing
    }
    void run() {
        if (page != null) {
            notebook.remove(page)
            page.dispose()
            F().collect()
            print("closed;")
        } else {
            window.dispose()
            F().collect()
            print("quit;")
            Gtk.Application().quit()
        }
    }
    void note()
    destroy { note() }
}
void Action.note() from "binding_released"
class UI {
    public:
    Gtk.Window window
    Gtk.Notebook notebook
    Gtk.ScrolledWindow first
    GtkSource.View firstView
    GtkSource.View secondView
    void activate() {
        window = Gtk.Window("Shortcut bindings")
        notebook = Gtk.Notebook()
        window.setChild(notebook)
        first = Gtk.ScrolledWindow()
        firstView = GtkSource.View()
        first.setChild(firstView.widget())
        notebook.appendPage(first, "one")
        Gtk.ScrolledWindow second = Gtk.ScrolledWindow()
        secondView = GtkSource.View()
        second.setChild(secondView.widget())
        notebook.appendPage(second, "two")
        print(firstView.bindShortcut("<Control>w", Action(window, notebook, first).run))
        print(secondView.bindShortcut("<Control>q", Action(window, notebook, null).run))
        window.present()
        int64 closing = firstView._widgetToken()
        print(Keys().press(closing, "<Control>w"))
        print(Keys().press(secondView._widgetToken(), "<Control>q"))
    }
}
start {
    Gtk.Application app = Gtk.Application("org.cwhip.BindingShortcuts")
    app.onActivate(UI().activate)
    app.run()
    F().collect()
    print(F().receivers())
}
