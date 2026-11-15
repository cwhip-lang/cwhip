/*
 * stdlib/gtk/0.1.0/button.cw — Gtk.Button from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Button is a class derived from Widget in this standard-library package.
     *
     * Its methods include _buttonSelf, _icon, constructor, setLabel, label,
     * setIconName, and 1 more.
     */
    class Button : Widget {
        private:
        /*
         * Handles button self for this Button by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns Button.
         */
        Button _buttonSelf()

        /*
         * Handles icon for this Button by calling the native function
         * cwhip_gtk_button_icon.
         *
         * Parameters:
         *   token — int64 token.
         *   name — String name.
         *
         * Does not return a value.
         */
        void _icon(int64 token, String name)
        public:
        /*
         * Constructs a Button.
         *
         * Parameters:
         *   label — String label.
         *
         * Returns the constructed Button.
         */
        Button(String label) {
            super Widget(4, label, 0, 0)
        }

        /*
         * Sets label for this Button.
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
         * Sets icon name for this Button.
         *
         * Parameters:
         *   name — String name.
         *
         * Does not return a value.
         */
        void setIconName(String name) {
            _icon(_widgetToken(), name)
        }

        /*
         * Returns SignalConnection(_buttonSelf(), action).
         *
         * Parameters:
         *   action — void<> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onClicked(void<> action) {
            return(SignalConnection(_buttonSelf(), action))
        }
    }
}
