/*
 * stdlib/gtk/0.1.0/drop_down.cw — Gtk.DropDown from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * DropDown is a class derived from Widget in this standard-library
     * package.
     *
     * Selectable string list (GtkDropDown) for enums and id pickers. Build the
     * model with clear()/append() or setChoices(list); read
     * selected()/selectedText().
     */
    class DropDown : Widget {
        private:
        /*
         * Handles drop self for this DropDown by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns DropDown.
         */
        DropDown _dropSelf()

        /*
         * Handles clear for this DropDown by calling the native function
         * cwhip_gtk_drop_down_clear.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _clear(int64 token)

        /*
         * Handles append for this DropDown by calling the native function
         * cwhip_gtk_drop_down_append.
         *
         * Parameters:
         *   token — int64 token.
         *   label — String label.
         *
         * Does not return a value.
         */
        void _append(int64 token, String label)

        /*
         * Handles set selected for this DropDown by calling the native
         * function cwhip_gtk_drop_down_set_selected.
         *
         * Parameters:
         *   token — int64 token.
         *   index — int64 index.
         *
         * Does not return a value.
         */
        void _setSelected(int64 token, int64 index)

        /*
         * Handles get selected for this DropDown by calling the native
         * function cwhip_gtk_drop_down_get_selected.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns int64.
         */
        int64 _getSelected(int64 token)

        /*
         * Handles get selected text for this DropDown by calling the native
         * function cwhip_gtk_drop_down_get_selected_text.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns String.
         */
        String _getSelectedText(int64 token)

        /*
         * Handles get size for this DropDown by calling the native function
         * cwhip_gtk_drop_down_get_size.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns int64.
         */
        int64 _getSize(int64 token)

        /*
         * Handles get item for this DropDown by calling the native function
         * cwhip_gtk_drop_down_get_item.
         *
         * Parameters:
         *   token — int64 token.
         *   index — int64 index.
         *
         * Returns String.
         */
        String _getItem(int64 token, int64 index)
        public:
        /*
         * Creates an empty GtkDropDown backed by a GtkStringList model.
         *
         * Takes no parameters.
         *
         * Returns the constructed DropDown.
         */
        DropDown() {
            super Widget(21, "", 0, 0)
        }

        /*
         * Removes every choice; selected() becomes -1 until
         * append/setSelected.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void clear() {
            _clear(_widgetToken())
        }

        /*
         * Appends one visible choice string at the end of the model.
         *
         * Parameters:
         *   label — String label.
         *
         * Does not return a value.
         */
        void append(String label) {
            _append(_widgetToken(), label)
        }

        /*
         * Replaces all choices with the given list of String labels (may be
         * empty). Keeps the prior selectedText when it still appears in the
         * new list; otherwise selects index 0 when nonempty, or -1 when empty.
         *
         * Parameters:
         *   labels — list labels.
         *
         * Does not return a value.
         */
        void setChoices(list labels) {
            String prior = selectedText()
            clear()
            int64 i = 0
            while (i < labels.length) {
                append(labels[i])
                i = i + 1
            }
            if (labels.length < 1) {
                return()
            }

            if (prior.length > 0) {
                int64 found = 0
                while (found < labels.length) {
                    String item = labels[found]
                    if (item.equals(prior)) {
                        setSelected(found)
                        return()
                    }
                    found = found + 1
                }
            }

            setSelected(0)
        }

        /*
         * Selects choice at index (0-based). Pass -1 to clear the selection.
         * Out-of-range nonnegative indices abort.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Does not return a value.
         */
        void setSelected(int64 index) {
            _setSelected(_widgetToken(), index)
        }

        /*
         * Selected 0-based index, or -1 when nothing is selected / model
         * empty.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 selected() {
            return(_getSelected(_widgetToken()))
        }

        /*
         * Text of the selected choice, or "" when nothing is selected.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String selectedText() {
            return(_getSelectedText(_widgetToken()))
        }

        /*
         * Number of choices currently in the model.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 size() {
            return(_getSize(_widgetToken()))
        }

        /*
         * Choice text at index; out-of-range indices abort.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns String.
         */
        String item(int64 index) {
            return(_getItem(_widgetToken(), index))
        }

        /*
         * Invoked when the selection changes (user or setSelected); arg is the
         * new selected index, or -1 when cleared.
         *
         * Parameters:
         *   action — void<int64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onSelected(void<int64> action) {
            return(SignalConnection(_dropSelf(), action))
        }
    }
}
