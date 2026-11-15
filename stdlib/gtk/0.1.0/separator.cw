/*
 * stdlib/gtk/0.1.0/separator.cw — Gtk.Separator from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Separator is a class derived from Widget in this standard-library
     * package.
     *
     * Horizontal or vertical dividing line (GtkSeparator) for dialog layout.
     */
    class Separator : Widget {
        public:
        enum {
            HORIZONTAL = 0, VERTICAL = 1
        }

        /*
         * Creates a GtkSeparator; orientation matches Box/Paned/Scale (0/1).
         *
         * Parameters:
         *   orientation — int64 orientation.
         *
         * Returns the constructed Separator.
         */
        Separator(int64 orientation) {
            super Widget(24, "", orientation, 0)
        }
    }
}
