/*
 * stdlib/gtk/0.1.0/font.cw — Gtk.Font from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Font is a class in this standard-library package.
     *
     * Its methods include isMonospace.
     */
    class Font {
        public:
        /*
         * Reports whether monospace for this Font by calling the native
         * function cwhip_gtk_font_is_monospace.
         *
         * Parameters:
         *   family — String family.
         *
         * Returns bool.
         */
        bool isMonospace(String family)
    }

    bool Font.isMonospace(String family) from "cwhip_gtk_font_is_monospace"

}
