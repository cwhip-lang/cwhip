/*
 * stdlib/gtk/0.1.0/check_button.cw — Gtk.CheckButton from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * CheckButton is a class derived from Widget in this standard-library
     * package.
     *
     * Its methods include _checkSelf, constructor, setLabel, label, setActive,
     * active, and 1 more.
     */
    class CheckButton : Widget {
        private:
        /*
         * Handles check self for this CheckButton by calling the native
         * function cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns CheckButton.
         */
        CheckButton _checkSelf()
        public:
        /*
         * Constructs a CheckButton.
         *
         * Parameters:
         *   label — String label.
         *
         * Returns the constructed CheckButton.
         */
        CheckButton(String label) {
            super Widget(6, label, 0, 0)
        }

        /*
         * Sets label for this CheckButton.
         *
         * Parameters:
         *   label — String label.
         *
         * Does not return a value.
         */
        void setLabel(String label) {
            _setText(label)
        }

        /*
         * Returns _getText().
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String label() {
            return(_getText())
        }

        /*
         * Sets active for this CheckButton.
         *
         * Parameters:
         *   value — bool value.
         *
         * Does not return a value.
         */
        void setActive(bool value) {
            _setActive(value)
        }

        /*
         * Returns _getActive().
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool active() {
            return(_getActive())
        }

        /*
         * Returns SignalConnection(_checkSelf(), action).
         *
         * Parameters:
         *   action — void<bool> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onToggled(void<bool> action) {
            return(SignalConnection(_checkSelf(), action))
        }
    }
}
