/*
 * stdlib/gtk/0.1.0/grid.cw — Gtk.Grid from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Grid is a class derived from Widget in this standard-library package.
     *
     * Its methods include _attachAt, constructor, attach.
     */
    class Grid : Widget {
        private:
        /*
         * Handles attach at for this Grid by calling the native function
         * cwhip_gtk_grid_attach.
         *
         * Parameters:
         *   token — int64 token.
         *   child — int64 child.
         *   column — int64 column.
         *   row — int64 row.
         *   width — int64 width.
         *   height — int64 height.
         *
         * Does not return a value.
         */
        void _attachAt(
                int64 token,
                int64 child,
                int64 column,
                int64 row,
                int64 width,
                int64 height)
        public:
        /*
         * Constructs a Grid.
         *
         * Parameters:
         *   spacing — int64 spacing.
         *
         * Returns the constructed Grid.
         */
        Grid(int64 spacing) {
            super Widget(14, "", 0, spacing)
        }

        /*
         * Handles attach for this Grid.
         *
         * Parameters:
         *   child — Widget child.
         *   column — int64 column.
         *   row — int64 row.
         *   width — int64 width.
         *   height — int64 height.
         *
         * Does not return a value.
         */
        void attach(
                Widget child,
                int64 column,
                int64 row,
                int64 width,
                int64 height) {
            _attachAt(
                    _widgetToken(),
                    child._widgetToken(),
                    column,
                    row,
                    width,
                    height)
        }
    }
}
