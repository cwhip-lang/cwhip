/*
 * stdlib/gtk/0.1.0/alert_dialog.cw — Gtk.AlertDialog from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * AlertDialog is a class in this standard-library package.
     *
     * Its methods include _show, show.
     */
    class AlertDialog {
        private:
        /*
         * Handles show for this AlertDialog by calling the native function
         * cwhip_gtk_alert_show.
         *
         * Parameters:
         *   parent — int64 parent.
         *   message — String message.
         *   detail — String detail.
         *
         * Does not return a value.
         */
        void _show(int64 parent, String message, String detail)
        public:
        /*
         * Shows a modal error/information alert over parent; it closes itself.
         *
         * Parameters:
         *   parent — Window parent.
         *   message — String message.
         *   detail — String detail.
         *
         * Does not return a value.
         */
        void show(Window parent, String message, String detail) {
            _show(parent._widgetToken(), message, detail)
        }
    }
}
