/*
 * stdlib/gtk/0.1.0/transient_window.cw
 *
 * Gtk.TransientWindow from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * TransientWindow is a class derived from Widget in this standard-library
     * package.
     *
     * Its methods include _transientSelf, constructor, setTitle, title,
     * setDefaultSize, setTransientFor, and 5 more.
     */
    class TransientWindow : Widget {
        private:
        /*
         * Handles transient self for this TransientWindow by calling the
         * native function cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns TransientWindow.
         */
        TransientWindow _transientSelf()
        public:
        /*
         * Constructs a TransientWindow.
         *
         * Parameters:
         *   title — String title.
         *
         * Returns the constructed TransientWindow.
         */
        TransientWindow(String title) {
            super Widget(11, title, 0, 0)
        }

        /*
         * Sets title for this TransientWindow.
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
         * Sets default size for this TransientWindow.
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
         * Sets transient for this TransientWindow.
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
         * Sets child for this TransientWindow.
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
         * Removes the TransientWindow state.
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
         * Handles present for this TransientWindow.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void present() {
            _presentWindow()
        }

        /*
         * Closes the TransientWindow state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void close() {
            _closeWindow()
        }

        /*
         * Returns SignalConnection(_transientSelf(), action).
         *
         * Parameters:
         *   action — bool<> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onCloseRequest(bool<> action) {
            return(SignalConnection(_transientSelf(), action))
        }
    }
}
