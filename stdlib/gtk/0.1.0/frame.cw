/*
 * stdlib/gtk/0.1.0/frame.cw — Gtk.Frame from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Frame is a class derived from Widget in this standard-library package.
     *
     * Labeled decorative frame around a single child (GtkFrame). Use for
     * grouped dialog sections; empty label hides the frame title.
     */
    class Frame : Widget {
        private:
        /*
         * Handles set label for this Frame by calling the native function
         * cwhip_gtk_frame_set_label.
         *
         * Parameters:
         *   token — int64 token.
         *   label — String label.
         *
         * Does not return a value.
         */
        void _setLabel(int64 token, String label)

        /*
         * Handles get label for this Frame by calling the native function
         * cwhip_gtk_frame_get_label.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns String.
         */
        String _getLabel(int64 token)
        public:
        /*
         * Creates a GtkFrame; label may be empty (no title).
         *
         * Parameters:
         *   label — String label.
         *
         * Returns the constructed Frame.
         */
        Frame(String label) {
            super Widget(22, label, 0, 0)
        }

        /*
         * Sets the frame title; empty string clears it.
         *
         * Parameters:
         *   label — String label.
         *
         * Does not return a value.
         */
        void setLabel(String label) {
            _setLabel(_widgetToken(), label)
        }

        /*
         * Current frame title, or "" when unset.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String label() {
            return(_getLabel(_widgetToken()))
        }

        /*
         * Sets the single child widget (replacing any previous child).
         *
         * Parameters:
         *   child — Widget child.
         *
         * Does not return a value.
         */
        void setChild(Widget child) {
            _attachChild(child)
        }

        /*
         * Detaches child if it is the current frame child.
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
