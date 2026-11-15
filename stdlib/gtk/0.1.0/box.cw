/*
 * stdlib/gtk/0.1.0/box.cw — Gtk.Box from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Box is a class derived from Widget in this standard-library package.
     *
     * Its methods include constructor, setLayout, append, remove.
     */
    class Box : Widget {
        public:
        enum {
            HORIZONTAL = 0, VERTICAL = 1
        }

        /*
         * Constructs a Box.
         *
         * Parameters:
         *   orientation — int64 orientation.
         *   spacing — int64 spacing.
         *
         * Returns the constructed Box.
         */
        Box(int64 orientation, int64 spacing) {
            super Widget(2, "", orientation, spacing)
        }

        /*
         * Sets layout for this Box.
         *
         * Parameters:
         *   orientation — int64 orientation.
         *   spacing — int64 spacing.
         *
         * Does not return a value.
         */
        void setLayout(int64 orientation, int64 spacing) {
            _boxLayout(orientation, spacing)
        }

        /*
         * Appends the Box state.
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
         * Removes the Box state.
         *
         * Parameters:
         *   child — Widget child.
         *
         * Does not return a value.
         */
        void remove(Widget child) {
            _removeChild(child)
        }
    }
}
