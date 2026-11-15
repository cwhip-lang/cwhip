/*
 * stdlib/gtk/0.1.0/progress_bar.cw — Gtk.ProgressBar from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * ProgressBar is a class derived from Widget in this standard-library
     * package.
     *
     * Determinate or pulsing progress indicator (GtkProgressBar). Fraction is
     * 0..1; optional overlay text when showText is true; pulse() for unknown
     * ETA.
     */
    class ProgressBar : Widget {
        private:
        /*
         * Handles set fraction for this ProgressBar by calling the native
         * function cwhip_gtk_progress_bar_set_fraction.
         *
         * Parameters:
         *   token — int64 token.
         *   fraction — fp64 fraction.
         *
         * Does not return a value.
         */
        void _setFraction(int64 token, fp64 fraction)

        /*
         * Handles get fraction for this ProgressBar by calling the native
         * function cwhip_gtk_progress_bar_get_fraction.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getFraction(int64 token)

        /*
         * Handles set text for this ProgressBar by calling the native function
         * cwhip_gtk_progress_bar_set_text.
         *
         * Parameters:
         *   token — int64 token.
         *   text — String text.
         *
         * Does not return a value.
         */
        void _setText(int64 token, String text)

        /*
         * Handles get text for this ProgressBar by calling the native function
         * cwhip_gtk_progress_bar_get_text.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns String.
         */
        String _getText(int64 token)

        /*
         * Handles set show text for this ProgressBar by calling the native
         * function cwhip_gtk_progress_bar_set_show_text.
         *
         * Parameters:
         *   token — int64 token.
         *   show — bool show.
         *
         * Does not return a value.
         */
        void _setShowText(int64 token, bool show)

        /*
         * Handles get show text for this ProgressBar by calling the native
         * function cwhip_gtk_progress_bar_get_show_text.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _getShowText(int64 token)

        /*
         * Handles pulse for this ProgressBar by calling the native function
         * cwhip_gtk_progress_bar_pulse.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _pulse(int64 token)

        /*
         * Handles set pulse step for this ProgressBar by calling the native
         * function cwhip_gtk_progress_bar_set_pulse_step.
         *
         * Parameters:
         *   token — int64 token.
         *   step — fp64 step.
         *
         * Does not return a value.
         */
        void _setPulseStep(int64 token, fp64 step)

        /*
         * Handles get pulse step for this ProgressBar by calling the native
         * function cwhip_gtk_progress_bar_get_pulse_step.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getPulseStep(int64 token)
        public:
        enum {
            HORIZONTAL = 0, VERTICAL = 1
        }

        /*
         * Creates a GtkProgressBar; orientation matches Box/Paned/Scale (0/1).
         * Defaults: fraction 0, showText false, empty text, pulseStep 0.1.
         *
         * Parameters:
         *   orientation — int64 orientation.
         *
         * Returns the constructed ProgressBar.
         */
        ProgressBar(int64 orientation) {
            super Widget(19, "", orientation, 0)
        }

        /*
         * Sets filled fraction in [0.0, 1.0]; out-of-range values abort.
         *
         * Parameters:
         *   fraction — fp64 fraction.
         *
         * Does not return a value.
         */
        void setFraction(fp64 fraction) {
            _setFraction(_widgetToken(), fraction)
        }

        /*
         * Returns _getFraction(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 fraction() {
            return(_getFraction(_widgetToken()))
        }

        /*
         * Overlay label when showText is true; empty string clears custom text
         * so GTK may show a percentage when showText remains enabled.
         *
         * Parameters:
         *   text — String text.
         *
         * Does not return a value.
         */
        void setText(String text) {
            _setText(_widgetToken(), text)
        }

        /*
         * Returns _getText(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String text() {
            return(_getText(_widgetToken()))
        }

        /*
         * Sets show text for this ProgressBar.
         *
         * Parameters:
         *   show — bool show.
         *
         * Does not return a value.
         */
        void setShowText(bool show) {
            _setShowText(_widgetToken(), show)
        }

        /*
         * Returns _getShowText(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool showText() {
            return(_getShowText(_widgetToken()))
        }

        /*
         * Advances an indeterminate pulse animation by pulseStep.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void pulse() {
            _pulse(_widgetToken())
        }

        /*
         * Fraction advanced per pulse(); must be in (0.0, 1.0].
         *
         * Parameters:
         *   step — fp64 step.
         *
         * Does not return a value.
         */
        void setPulseStep(fp64 step) {
            _setPulseStep(_widgetToken(), step)
        }

        /*
         * Returns _getPulseStep(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 pulseStep() {
            return(_getPulseStep(_widgetToken()))
        }
    }
}
