/*
 * stdlib/gtk/0.1.0/label.cw — Gtk.Label from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Label is a class derived from Widget in this standard-library package.
     *
     * Its methods include constructor, setText, text.
     */
    class Label : Widget {
        public:
        /*
         * Constructs a Label.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns the constructed Label.
         */
        Label(String text) {
            super Widget(3, text, 0, 0)
        }

        /*
         * Sets text for this Label.
         *
         * Parameters:
         *   text — String text.
         *
         * Does not return a value.
         */
        void setText(String text) {
            _setText(text)
        }

        /*
         * Returns _getText().
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String text() {
            return(_getText())
        }
    }
}
