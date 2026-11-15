/*
 * stdlib/gtk/0.1.0/scale.cw — Gtk.Scale from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Scale is a class derived from Widget in this standard-library package.
     *
     * Continuous or stepped numeric slider (GtkScale). Prefer Scale for
     * settings knobs; use Scrollbar for pan/zoom view extents.
     */
    class Scale : Widget {
        private:
        /*
         * Handles scale self for this Scale by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns Scale.
         */
        Scale _scaleSelf()

        /*
         * Handles configure for this Scale by calling the native function
         * cwhip_gtk_scale_configure.
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
         * Handles set value for this Scale by calling the native function
         * cwhip_gtk_scale_set_value.
         *
         * Parameters:
         *   token — int64 token.
         *   value — fp64 value.
         *
         * Does not return a value.
         */
        void _setValue(int64 token, fp64 value)

        /*
         * Handles get value for this Scale by calling the native function
         * cwhip_gtk_scale_get_value.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getValue(int64 token)

        /*
         * Handles get lower for this Scale by calling the native function
         * cwhip_gtk_scale_get_lower.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getLower(int64 token)

        /*
         * Handles get upper for this Scale by calling the native function
         * cwhip_gtk_scale_get_upper.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getUpper(int64 token)

        /*
         * Handles get step for this Scale by calling the native function
         * cwhip_gtk_scale_get_step.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getStep(int64 token)
        public:
        enum {
            HORIZONTAL = 0, VERTICAL = 1
        }

        /*
         * Creates a GtkScale; orientation matches Box/Paned/Scrollbar (0/1).
         * Default range is 0..1 with step 0.1 until configure() is called.
         *
         * Parameters:
         *   orientation — int64 orientation.
         *
         * Returns the constructed Scale.
         */
        Scale(int64 orientation) {
            super Widget(18, "", orientation, 0)
        }

        /*
         * Sets value, inclusive lower/upper bounds, and step increment. Page
         * increment is step*10 (GTK Scale with-range convention).
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
         * Sets value for this Scale.
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
         * Returns _getValue(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 value() {
            return(_getValue(_widgetToken()))
        }

        /*
         * Returns _getLower(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 lower() {
            return(_getLower(_widgetToken()))
        }

        /*
         * Returns _getUpper(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 upper() {
            return(_getUpper(_widgetToken()))
        }

        /*
         * Returns _getStep(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 step() {
            return(_getStep(_widgetToken()))
        }

        /*
         * Invoked when the user (or setValue) moves the slider; arg is the new
         * value.
         *
         * Parameters:
         *   action — void<fp64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onValueChanged(void<fp64> action) {
            return(SignalConnection(_scaleSelf(), action))
        }
    }
}
