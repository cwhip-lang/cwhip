/*
 * stdlib/gtk/0.1.0/paned.cw — Gtk.Paned from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Paned is a class derived from Widget in this standard-library package.
     *
     * Its methods include _position, _getPosition, constructor, append,
     * setPosition, position.
     */
    class Paned : Widget {
        private:
        /*
         * Handles position for this Paned by calling the native function
         * cwhip_gtk_paned_position.
         *
         * Parameters:
         *   token — int64 token.
         *   position — int64 position.
         *
         * Does not return a value.
         */
        void _position(int64 token, int64 position)

        /*
         * Handles get position for this Paned by calling the native function
         * cwhip_gtk_paned_get_position.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns int64.
         */
        int64 _getPosition(int64 token)
        public:
        enum {
            HORIZONTAL = 0, VERTICAL = 1
        }

        /*
         * Default remains a horizontal split for existing call sites.
         *
         * Takes no parameters.
         *
         * Returns the constructed Paned.
         */
        Paned() {
            super Widget(12, "", HORIZONTAL, 0)
        }

        /*
         * Constructs a Paned.
         *
         * Parameters:
         *   orientation — int64 orientation.
         *
         * Returns the constructed Paned.
         */
        Paned(int64 orientation) {
            super Widget(12, "", orientation, 0)
        }

        /*
         * Appends the Paned state.
         *
         * Parameters:
         *   child — Widget child.
         *
         * Does not return a value.
         */
        void append(Widget child) {
            _attachChild(child)
        }

        /*
         * Sets position for this Paned.
         *
         * Parameters:
         *   position — int64 position.
         *
         * Does not return a value.
         */
        void setPosition(int64 position) {
            _position(_widgetToken(), position)
        }

        /*
         * Returns _getPosition(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 position() {
            return(_getPosition(_widgetToken()))
        }
    }
}
