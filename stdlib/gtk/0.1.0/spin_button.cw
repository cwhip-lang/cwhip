/*
 * stdlib/gtk/0.1.0/spin_button.cw — Gtk.SpinButton from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * SpinButton is a class derived from Widget in this standard-library
     * package.
     *
     * Integer or stepped numeric entry with +/- buttons (GtkSpinButton).
     * Prefer SpinButton for discrete counts and bounded integers; use Scale
     * for continuous sliders and Scrollbar for pan/zoom extents.
     */
    class SpinButton : Widget {
        private:
        /*
         * Handles spin self for this SpinButton by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns SpinButton.
         */
        SpinButton _spinSelf()

        /*
         * Handles configure for this SpinButton by calling the native function
         * cwhip_gtk_spin_button_configure.
         *
         * Parameters:
         *   token — int64 token.
         *   value — fp64 value.
         *   lower — fp64 lower.
         *   upper — fp64 upper.
         *   step — fp64 step.
         *
         * Does not return a value.
         */
        void _configure(
                int64 token,
                fp64 value,
                fp64 lower,
                fp64 upper,
                fp64 step)

        /*
         * Handles set value for this SpinButton by calling the native function
         * cwhip_gtk_spin_button_set_value.
         *
         * Parameters:
         *   token — int64 token.
         *   value — fp64 value.
         *
         * Does not return a value.
         */
        void _setValue(int64 token, fp64 value)

        /*
         * Handles get value for this SpinButton by calling the native function
         * cwhip_gtk_spin_button_get_value.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getValue(int64 token)

        /*
         * Handles get lower for this SpinButton by calling the native function
         * cwhip_gtk_spin_button_get_lower.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getLower(int64 token)

        /*
         * Handles get upper for this SpinButton by calling the native function
         * cwhip_gtk_spin_button_get_upper.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getUpper(int64 token)

        /*
         * Handles get step for this SpinButton by calling the native function
         * cwhip_gtk_spin_button_get_step.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getStep(int64 token)
        public:
        /*
         * Creates a GtkSpinButton. Default range is 0..100 with step 1 until
         * configure() is called. Digits track the step size (same heuristic as
         * Scale).
         *
         * Takes no parameters.
         *
         * Returns the constructed SpinButton.
         */
        SpinButton() {
            super Widget(20, "", 0, 0)
        }

        /*
         * Sets value, inclusive lower/upper bounds, and step increment. Page
         * increment is step*10 (matches Scale /
         * gtk_spin_button_new_with_range).
         *
         * Parameters:
         *   value — fp64 value.
         *   lower — fp64 lower.
         *   upper — fp64 upper.
         *   step — fp64 step.
         *
         * Does not return a value.
         */
        void configure(fp64 value, fp64 lower, fp64 upper, fp64 step) {
            _configure(_widgetToken(), value, lower, upper, step)
        }

        /*
         * Writes the spin value; GTK clamps to the configured range.
         *
         * Parameters:
         *   value — fp64 value.
         *
         * Does not return a value.
         */
        void setValue(fp64 value) {
            _setValue(_widgetToken(), value)
        }

        /*
         * Current spin value (may be fractional when step < 1).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 value() {
            return(_getValue(_widgetToken()))
        }

        /*
         * Inclusive lower bound from the last configure().
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 lower() {
            return(_getLower(_widgetToken()))
        }

        /*
         * Inclusive upper bound from the last configure().
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 upper() {
            return(_getUpper(_widgetToken()))
        }

        /*
         * Step increment from the last configure().
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 step() {
            return(_getStep(_widgetToken()))
        }

        /*
         * Invoked when the user (or setValue) changes the value; arg is the
         * new value.
         *
         * Parameters:
         *   action — void<fp64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onValueChanged(void<fp64> action) {
            return(SignalConnection(_spinSelf(), action))
        }
    }
}
