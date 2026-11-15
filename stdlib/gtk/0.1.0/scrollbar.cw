/*
 * stdlib/gtk/0.1.0/scrollbar.cw — Gtk.Scrollbar from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Scrollbar is a class derived from Widget in this standard-library
     * package.
     *
     * Standalone scrollbar for client-driven pan/zoom extents. Prefer
     * ScrolledWindow around a sized DrawingArea when stock bars suffice; use
     * Scrollbar when zoom is a draw-time transform and content size stays
     * fixed (configure lower/upper/page from current extents).
     */
    class Scrollbar : Widget {
        private:
        /*
         * Handles bar self for this Scrollbar by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns Scrollbar.
         */
        Scrollbar _barSelf()

        /*
         * Handles configure for this Scrollbar by calling the native function
         * cwhip_gtk_scrollbar_configure.
         *
         * Parameters:
         *   token — int64 token.
         *   value — fp64 value.
         *   lower — fp64 lower.
         *   upper — fp64 upper.
         *   step — fp64 step.
         *   page — fp64 page.
         *   pageSize — fp64 page size.
         *
         * Does not return a value.
         */
        void _configure(
                int64 token,
                fp64 value,
                fp64 lower,
                fp64 upper,
                fp64 step,
                fp64 page,
            fp64 pageSize)

        /*
         * Handles set value for this Scrollbar by calling the native function
         * cwhip_gtk_scrollbar_set_value.
         *
         * Parameters:
         *   token — int64 token.
         *   value — fp64 value.
         *
         * Does not return a value.
         */
        void _setValue(int64 token, fp64 value)

        /*
         * Handles get value for this Scrollbar by calling the native function
         * cwhip_gtk_scrollbar_get_value.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getValue(int64 token)

        /*
         * Handles get lower for this Scrollbar by calling the native function
         * cwhip_gtk_scrollbar_get_lower.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getLower(int64 token)

        /*
         * Handles get upper for this Scrollbar by calling the native function
         * cwhip_gtk_scrollbar_get_upper.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getUpper(int64 token)

        /*
         * Handles get page size for this Scrollbar by calling the native
         * function cwhip_gtk_scrollbar_get_page_size.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns fp64.
         */
        fp64 _getPageSize(int64 token)
        public:
        enum {
            HORIZONTAL = 0, VERTICAL = 1
        }

        /*
         * Creates a GtkScrollbar; orientation matches Box/Paned (0/1).
         *
         * Parameters:
         *   orientation — int64 orientation.
         *
         * Returns the constructed Scrollbar.
         */
        Scrollbar(int64 orientation) {
            super Widget(17, "", orientation, 0)
        }

        /*
         * Sets adjustment range and page size in one call (GTK clamps value).
         *
         * Parameters:
         *   value — fp64 value.
         *   lower — fp64 lower.
         *   upper — fp64 upper.
         *   step — fp64 step.
         *   page — fp64 page.
         *   pageSize — fp64 page size.
         *
         * Does not return a value.
         */
        void configure(
                fp64 value,
                fp64 lower,
                fp64 upper,
                fp64 step,
                fp64 page,
                fp64 pageSize) {
            _configure(
                    _widgetToken(),
                    value,
                    lower,
                    upper,
                    step,
                    page,
                    pageSize)
        }

        /*
         * Sets value for this Scrollbar.
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
         * Returns _getPageSize(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns fp64.
         */
        fp64 pageSize() {
            return(_getPageSize(_widgetToken()))
        }

        /*
         * Invoked when the user (or setValue) moves the thumb; arg is the new
         * value.
         *
         * Parameters:
         *   action — void<fp64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onValueChanged(void<fp64> action) {
            return(SignalConnection(_barSelf(), action))
        }
    }
}
