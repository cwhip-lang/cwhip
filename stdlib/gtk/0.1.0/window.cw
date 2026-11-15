/*
 * stdlib/gtk/0.1.0/window.cw — Gtk.Window from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Window is a class derived from Widget in this standard-library package.
     *
     * Its methods include _windowSelf, _bindShortcut, _hasShortcut,
     * _clearWindowShortcuts, _maximized, _maximize, and 22 more.
     */
    class Window : Widget {
        private:
        /*
         * Handles window self for this Window by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns Window.
         */
        Window _windowSelf()

        /*
         * Handles bind shortcut for this Window by calling the native function
         * cwhip_gtk_window_bind_shortcut.
         *
         * Parameters:
         *   token — int64 token.
         *   trigger — String trigger.
         *   action — void<> action.
         *
         * Returns bool.
         */
        bool _bindShortcut(int64 token, String trigger, void<> action)

        /*
         * Handles has shortcut for this Window by calling the native function
         * cwhip_gtk_window_has_shortcut.
         *
         * Parameters:
         *   token — int64 token.
         *   trigger — String trigger.
         *
         * Returns bool.
         */
        bool _hasShortcut(int64 token, String trigger)

        /*
         * Handles clear window shortcuts for this Window by calling the native
         * function cwhip_gtk_source_view_clear_shortcuts.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _clearWindowShortcuts(int64 token)

        /*
         * Handles maximized for this Window by calling the native function
         * cwhip_gtk_window_maximized.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _maximized(int64 token)

        /*
         * Handles maximize for this Window by calling the native function
         * cwhip_gtk_window_maximize.
         *
         * Parameters:
         *   token — int64 token.
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void _maximize(int64 token, bool enabled)

        /*
         * Handles set menubar accel for this Window by calling the native
         * function cwhip_gtk_window_handle_menubar_accel.
         *
         * Parameters:
         *   token — int64 token.
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void _setMenubarAccel(int64 token, bool enabled)

        /*
         * Handles menubar accel for this Window by calling the native function
         * cwhip_gtk_window_handles_menubar_accel.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _menubarAccel(int64 token)
        public:
        /*
         * Constructs a Window.
         *
         * Parameters:
         *   title — String title.
         *
         * Returns the constructed Window.
         */
        Window(String title) {
            super Widget(1, title, 0, 0)
        }

        /*
         * Sets title for this Window.
         *
         * Parameters:
         *   title — String title.
         *
         * Does not return a value.
         */
        void setTitle(String title) {
            _setText(title)
        }

        /*
         * Returns _getText().
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String title() {
            return(_getText())
        }

        /*
         * Sets default size for this Window.
         *
         * Parameters:
         *   width — int64 width.
         *   height — int64 height.
         *
         * Does not return a value.
         */
        void setDefaultSize(int64 width, int64 height) {
            _sizeWindow(width, height)
        }

        /*
         * Returns _defaultWidth().
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 defaultWidth() {
            return(_defaultWidth())
        }

        /*
         * Returns _defaultHeight().
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 defaultHeight() {
            return(_defaultHeight())
        }

        /*
         * Returns _maximized(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool maximized() {
            return(_maximized(_widgetToken()))
        }

        /*
         * Sets maximized for this Window.
         *
         * Parameters:
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void setMaximized(bool enabled) {
            _maximize(_widgetToken(), enabled)
        }

        /*
         * GTK defaults to consuming F10 for the menubar; set false when F10 is
         * an application shortcut (bindShortcut("F10", ...) also clears it).
         *
         * Parameters:
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void setMenubarAccel(bool enabled) {
            _setMenubarAccel(_widgetToken(), enabled)
        }

        /*
         * Returns _menubarAccel(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool menubarAccel() {
            return(_menubarAccel(_widgetToken()))
        }

        /*
         * Sets transient for this Window.
         *
         * Parameters:
         *   parent — Window parent.
         *
         * Does not return a value.
         */
        void setTransientFor(Window parent) {
            _setTransientFor(parent._widgetToken())
        }

        /*
         * Sets child for this Window.
         *
         * Parameters:
         *   child — Widget child.
         *
         * Does not return a value.
         */
        void setChild(Widget child) {
            _attachChild(child)
        }

        /*
         * Removes the Window state.
         *
         * Parameters:
         *   child — Widget child.
         *
         * Does not return a value.
         */
        void remove(Widget child) {
            _removeChild(child)
        }

        /*
         * Handles present for this Window.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void present() {
            _presentWindow()
        }

        /*
         * Closes the Window state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void close() {
            _closeWindow()
        }

        /*
         * Binds a GTK accelerator such as "<Control>q" for the whole window.
         *
         * Parameters:
         *   trigger — String trigger.
         *   action — void<> action.
         *
         * Returns bool.
         */
        bool bindShortcut(String trigger, void<> action) {
            return(_bindShortcut(_widgetToken(), trigger, action))
        }

        /*
         * Returns _hasShortcut(_widgetToken(), trigger).
         *
         * Parameters:
         *   trigger — String trigger.
         *
         * Returns bool.
         */
        bool hasShortcut(String trigger) {
            return(_hasShortcut(_widgetToken(), trigger))
        }

        /*
         * Same native helper as SourceView.clearShortcuts: drops every binding
         * installed through bindShortcut on this window.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void clearShortcuts() {
            _clearWindowShortcuts(_widgetToken())
        }

        /*
         * Returns SignalConnection(_windowSelf(), action).
         *
         * Parameters:
         *   action — bool<> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onCloseRequest(bool<> action) {
            return(SignalConnection(_windowSelf(), action))
        }

        /*
         * Returns SignalConnection(_windowSelf(), action).
         *
         * Parameters:
         *   action — void<bool> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onFocusChanged(void<bool> action) {
            return(SignalConnection(_windowSelf(), action))
        }
    }
}
