/*
 * stdlib/gtk/0.1.0/clipboard.cw — Gtk.Clipboard from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Clipboard is a class in this standard-library package.
     *
     * Display clipboard helpers. setText updates the system clipboard and a
     * same-process cache; text() returns that cache (GDK reads are async).
     */
    class Clipboard {
        public:
        /*
         * Sets text for this Clipboard by calling the native function
         * cwhip_gtk_clipboard_set_text.
         *
         * Parameters:
         *   text — String text.
         *
         * Does not return a value.
         */
        void setText(String text)

        /*
         * Handles text for this Clipboard by calling the native function
         * cwhip_gtk_clipboard_text.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String text()
    }

    void Clipboard.setText(String text) from "cwhip_gtk_clipboard_set_text"

    String Clipboard.text() from "cwhip_gtk_clipboard_text"

}
