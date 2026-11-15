/*
 * stdlib/gtk/0.1.0/keyboard.cw — Gtk.Keyboard from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Keyboard is a class in this standard-library package.
     *
     * Its methods include normalize, record, cancel.
     */
    class Keyboard {
        public:
        /*
         * Handles normalize for this Keyboard by calling the native function
         * cwhip_gtk_keyboard_normalize.
         *
         * Parameters:
         *   trigger — String trigger.
         *
         * Returns String.
         */
        String normalize(String trigger)

        /*
         * Handles record for this Keyboard by calling the native function
         * cwhip_gtk_keyboard_record.
         *
         * Parameters:
         *   entry — Entry entry.
         *   result — void<String> result.
         *
         * Returns int64.
         */
        int64 record(Entry entry, void<String> result)

        /*
         * Cancels the Keyboard state by calling the native function
         * cwhip_gtk_keyboard_cancel.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool cancel(int64 token)
    }

    String Keyboard.normalize(String trigger) from "cwhip_gtk_keyboard_normalize"

    int64 Keyboard.record(Entry entry, void<String> result) from "cwhip_gtk_keyboard_record"

    bool Keyboard.cancel(int64 token) from "cwhip_gtk_keyboard_cancel"

}
