/*
 * stdlib/gtk/0.1.0/signal_connection.cw
 *
 * Gtk.SignalConnection from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * SignalConnection is a class in this standard-library package.
     *
     * Its methods include _activate, _click, _changed, _close, _toggled,
     * _pageChanged, and 12 more.
     */
    class SignalConnection {
        private:
        int64 _token

        /*
         * Handles activate for this SignalConnection by calling the native
         * function cwhip_gtk_activation_signal.
         *
         * Parameters:
         *   source — Application source.
         *   action — void<> action.
         *
         * Returns int64.
         */
        int64 _activate(Application source, void<> action)

        /*
         * Handles click for this SignalConnection by calling the native
         * function cwhip_gtk_button_signal.
         *
         * Parameters:
         *   source — Button source.
         *   action — void<> action.
         *
         * Returns int64.
         */
        int64 _click(Button source, void<> action)

        /*
         * Handles changed for this SignalConnection by calling the native
         * function cwhip_gtk_entry_signal.
         *
         * Parameters:
         *   source — Entry source.
         *   action — void<String> action.
         *
         * Returns int64.
         */
        int64 _changed(Entry source, void<String> action)

        /*
         * Handles close for this SignalConnection by calling the native
         * function cwhip_gtk_window_signal.
         *
         * Parameters:
         *   source — Window source.
         *   action — bool<> action.
         *
         * Returns int64.
         */
        int64 _close(Window source, bool<> action)

        /*
         * Handles close for this SignalConnection by calling the native
         * function cwhip_gtk_window_signal.
         *
         * Parameters:
         *   source — TransientWindow source.
         *   action — bool<> action.
         *
         * Returns int64.
         */
        int64 _close(TransientWindow source, bool<> action)

        /*
         * Handles toggled for this SignalConnection by calling the native
         * function cwhip_gtk_checkbox_signal.
         *
         * Parameters:
         *   source — CheckButton source.
         *   action — void<bool> action.
         *
         * Returns int64.
         */
        int64 _toggled(CheckButton source, void<bool> action)

        /*
         * Handles page changed for this SignalConnection by calling the native
         * function cwhip_gtk_notebook_signal.
         *
         * Parameters:
         *   source — Notebook source.
         *   action — void<> action.
         *
         * Returns int64.
         */
        int64 _pageChanged(Notebook source, void<> action)

        /*
         * Handles focus changed for this SignalConnection by calling the
         * native function cwhip_gtk_window_focus_signal.
         *
         * Parameters:
         *   source — Window source.
         *   action — void<bool> action.
         *
         * Returns int64.
         */
        int64 _focusChanged(Window source, void<bool> action)

        /*
         * Handles draw for this SignalConnection by calling the native
         * function cwhip_gtk_drawing_area_signal.
         *
         * Parameters:
         *   source — DrawingArea source.
         *   action — void<int64,int64> action.
         *
         * Returns int64.
         */
        int64 _draw(DrawingArea source, void<int64, int64> action)

        /*
         * Handles click for this SignalConnection by calling the native
         * function cwhip_gtk_drawing_area_click_signal.
         *
         * Parameters:
         *   source — DrawingArea source.
         *   action — void<int64,fp64,fp64> action.
         *
         * Returns int64.
         */
        int64 _click(DrawingArea source, void<int64, fp64, fp64> action)

        /*
         * Handles drag for this SignalConnection by calling the native
         * function cwhip_gtk_drawing_area_drag_signal.
         *
         * Parameters:
         *   source — DrawingArea source.
         *   action — void<int64,fp64,fp64,fp64,fp64> action.
         *
         * Returns int64.
         */
        int64 _drag(
                DrawingArea source,
                void<int64,
                fp64,
                fp64,
                fp64,
                fp64> action)

        /*
         * Handles scroll for this SignalConnection by calling the native
         * function cwhip_gtk_drawing_area_scroll_signal.
         *
         * Parameters:
         *   source — DrawingArea source.
         *   action — void<fp64,fp64,fp64,fp64> action.
         *
         * Returns int64.
         */
        int64 _scroll(DrawingArea source, void<fp64, fp64, fp64, fp64> action)

        /*
         * Handles popup for this SignalConnection by calling the native
         * function cwhip_gtk_context_menu_popup_signal.
         *
         * Parameters:
         *   source — ContextMenu source.
         *   action — void<fp64,fp64> action.
         *
         * Returns int64.
         */
        int64 _popup(ContextMenu source, void<fp64, fp64> action)

        /*
         * Handles value changed for this SignalConnection by calling the
         * native function cwhip_gtk_scrollbar_signal.
         *
         * Parameters:
         *   source — Scrollbar source.
         *   action — void<fp64> action.
         *
         * Returns int64.
         */
        int64 _valueChanged(Scrollbar source, void<fp64> action)

        /*
         * Handles value changed for this SignalConnection by calling the
         * native function cwhip_gtk_scale_signal.
         *
         * Parameters:
         *   source — Scale source.
         *   action — void<fp64> action.
         *
         * Returns int64.
         */
        int64 _valueChanged(Scale source, void<fp64> action)

        /*
         * Handles value changed for this SignalConnection by calling the
         * native function cwhip_gtk_spin_button_signal.
         *
         * Parameters:
         *   source — SpinButton source.
         *   action — void<fp64> action.
         *
         * Returns int64.
         */
        int64 _valueChanged(SpinButton source, void<fp64> action)

        /*
         * Handles selected for this SignalConnection by calling the native
         * function cwhip_gtk_drop_down_signal.
         *
         * Parameters:
         *   source — DropDown source.
         *   action — void<int64> action.
         *
         * Returns int64.
         */
        int64 _selected(DropDown source, void<int64> action)

        /*
         * Handles changed for this SignalConnection by calling the native
         * function cwhip_gtk_text_view_signal.
         *
         * Parameters:
         *   source — TextView source.
         *   action — void<String> action.
         *
         * Returns int64.
         */
        int64 _changed(TextView source, void<String> action)

        /*
         * Handles disconnect for this SignalConnection by calling the native
         * function cwhip_gtk_connection_disconnect.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _disconnect(int64 token)

        /*
         * Handles connected for this SignalConnection by calling the native
         * function cwhip_gtk_connected.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _connected(int64 token)
        public:
        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — Application source.
         *   action — void<> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(Application source, void<> action) {
            _token = _activate(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — Button source.
         *   action — void<> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(Button source, void<> action) {
            _token = _click(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — Entry source.
         *   action — void<String> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(Entry source, void<String> action) {
            _token = _changed(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — Window source.
         *   action — bool<> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(Window source, bool<> action) {
            _token = _close(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — TransientWindow source.
         *   action — bool<> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(TransientWindow source, bool<> action) {
            _token = _close(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — CheckButton source.
         *   action — void<bool> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(CheckButton source, void<bool> action) {
            _token = _toggled(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — Notebook source.
         *   action — void<> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(Notebook source, void<> action) {
            _token = _pageChanged(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — Window source.
         *   action — void<bool> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(Window source, void<bool> action) {
            _token = _focusChanged(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — DrawingArea source.
         *   action — void<int64,int64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(DrawingArea source, void<int64, int64> action) {
            _token = _draw(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — DrawingArea source.
         *   action — void<int64,fp64,fp64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(DrawingArea source, void<int64, fp64, fp64> action) {
            _token = _click(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — DrawingArea source.
         *   action — void<int64,fp64,fp64,fp64,fp64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(
                DrawingArea source,
                void<int64,
                fp64,
                fp64,
                fp64,
                fp64> action) {
            _token = _drag(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — DrawingArea source.
         *   action — void<fp64,fp64,fp64,fp64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(
                DrawingArea source,
                void<fp64,
                fp64,
                fp64,
                fp64> action) {
            _token = _scroll(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — ContextMenu source.
         *   action — void<fp64,fp64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(ContextMenu source, void<fp64, fp64> action) {
            _token = _popup(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — Scrollbar source.
         *   action — void<fp64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(Scrollbar source, void<fp64> action) {
            _token = _valueChanged(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — Scale source.
         *   action — void<fp64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(Scale source, void<fp64> action) {
            _token = _valueChanged(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — SpinButton source.
         *   action — void<fp64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(SpinButton source, void<fp64> action) {
            _token = _valueChanged(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — DropDown source.
         *   action — void<int64> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(DropDown source, void<int64> action) {
            _token = _selected(source, action)
        }

        /*
         * Constructs a SignalConnection and stores _token.
         *
         * Parameters:
         *   source — TextView source.
         *   action — void<String> action.
         *
         * Returns the constructed SignalConnection.
         */
        SignalConnection(TextView source, void<String> action) {
            _token = _changed(source, action)
        }

        /*
         * Returns _disconnect(_token).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool disconnect() {
            return(_disconnect(_token))
        }

        /*
         * Returns _connected(_token).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool connected() {
            return(_connected(_token))
        }
    }
}
