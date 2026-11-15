/*
 * stdlib/gtk/0.1.0/entry.cw — Gtk.Entry from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Entry is a class derived from Widget in this standard-library package.
     *
     * Its methods include _entrySelf, _editable, constructor, setText, text,
     * onChanged, and 2 more.
     */
    class Entry : Widget {
        private:
        /*
         * Handles entry self for this Entry by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns Entry.
         */
        Entry _entrySelf()

        /*
         * Handles editable for this Entry by calling the native function
         * cwhip_gtk_entry_editable.
         *
         * Parameters:
         *   token — int64 token.
         *   editable — bool editable.
         *
         * Does not return a value.
         */
        void _editable(int64 token, bool editable)
        public:
        /*
         * Constructs a Entry.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns the constructed Entry.
         */
        Entry(String text) {
            super Widget(5, text, 0, 0)
        }

        /*
         * Sets text for this Entry.
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

        /*
         * Returns SignalConnection(_entrySelf(), action).
         *
         * Parameters:
         *   action — void<String> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onChanged(void<String> action) {
            return(SignalConnection(_entrySelf(), action))
        }

        /*
         * Handles focus for this Entry.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void focus() {
            _grabFocus()
        }

        /*
         * Sets editable for this Entry.
         *
         * Parameters:
         *   editable — bool editable.
         *
         * Does not return a value.
         */
        void setEditable(bool editable) {
            _editable(_widgetToken(), editable)
        }
    }
}
