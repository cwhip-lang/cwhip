/*
 * stdlib/gtk/0.1.0/text_view.cw — Gtk.TextView from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * TextView is a class derived from Widget in this standard-library
     * package.
     *
     * Plain multiline text editor (GtkTextView). Prefer TextView for compose /
     * digest panes; use the sourceview package for syntax-aware editors.
     */
    class TextView : Widget {
        private:
        /*
         * Handles text self for this TextView by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns TextView.
         */
        TextView _textSelf()

        /*
         * Handles set text for this TextView by calling the native function
         * cwhip_gtk_text_view_set_text.
         *
         * Parameters:
         *   token — int64 token.
         *   text — String text.
         *
         * Does not return a value.
         */
        void _setText(int64 token, String text)

        /*
         * Handles get text for this TextView by calling the native function
         * cwhip_gtk_text_view_get_text.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns String.
         */
        String _getText(int64 token)

        /*
         * Handles editable for this TextView by calling the native function
         * cwhip_gtk_text_view_set_editable.
         *
         * Parameters:
         *   token — int64 token.
         *   editable — bool editable.
         *
         * Does not return a value.
         */
        void _editable(int64 token, bool editable)

        /*
         * Handles get editable for this TextView by calling the native
         * function cwhip_gtk_text_view_get_editable.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _getEditable(int64 token)

        /*
         * Handles wrap for this TextView by calling the native function
         * cwhip_gtk_text_view_set_wrap.
         *
         * Parameters:
         *   token — int64 token.
         *   wrap — bool wrap.
         *
         * Does not return a value.
         */
        void _wrap(int64 token, bool wrap)

        /*
         * Handles get wrap for this TextView by calling the native function
         * cwhip_gtk_text_view_get_wrap.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _getWrap(int64 token)
        public:
        /*
         * Creates an empty editable GtkTextView with word wrap enabled.
         *
         * Takes no parameters.
         *
         * Returns the constructed TextView.
         */
        TextView() {
            super Widget(25, "", 0, 0)
        }

        /*
         * Replaces the entire buffer contents.
         *
         * Parameters:
         *   text — String text.
         *
         * Does not return a value.
         */
        void setText(String text) {
            _setText(_widgetToken(), text)
        }

        /*
         * Full buffer text (may contain newlines).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String text() {
            return(_getText(_widgetToken()))
        }

        /*
         * Enables or disables user editing; programmatic setText still works.
         *
         * Parameters:
         *   editable — bool editable.
         *
         * Does not return a value.
         */
        void setEditable(bool editable) {
            _editable(_widgetToken(), editable)
        }

        /*
         * True when the user can type into the view.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool editable() {
            return(_getEditable(_widgetToken()))
        }

        /*
         * Word-wraps long lines when true; otherwise scrolls horizontally.
         *
         * Parameters:
         *   wrap — bool wrap.
         *
         * Does not return a value.
         */
        void setWrap(bool wrap) {
            _wrap(_widgetToken(), wrap)
        }

        /*
         * True when word wrap is enabled.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool wrap() {
            return(_getWrap(_widgetToken()))
        }

        /*
         * Invoked when buffer text changes; arg is the full buffer contents.
         *
         * Parameters:
         *   action — void<String> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onChanged(void<String> action) {
            return(SignalConnection(_textSelf(), action))
        }
    }
}
