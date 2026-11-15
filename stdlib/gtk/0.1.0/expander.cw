/*
 * stdlib/gtk/0.1.0/expander.cw — Gtk.Expander from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Expander is a class derived from Widget in this standard-library
     * package.
     *
     * Collapsible section with a clickable header (GtkExpander). Child is
     * shown only while expanded.
     */
    class Expander : Widget {
        private:
        /*
         * Handles set label for this Expander by calling the native function
         * cwhip_gtk_expander_set_label.
         *
         * Parameters:
         *   token — int64 token.
         *   label — String label.
         *
         * Does not return a value.
         */
        void _setLabel(int64 token, String label)

        /*
         * Handles get label for this Expander by calling the native function
         * cwhip_gtk_expander_get_label.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns String.
         */
        String _getLabel(int64 token)

        /*
         * Handles set expanded for this Expander by calling the native
         * function cwhip_gtk_expander_set_expanded.
         *
         * Parameters:
         *   token — int64 token.
         *   expanded — bool expanded.
         *
         * Does not return a value.
         */
        void _setExpanded(int64 token, bool expanded)

        /*
         * Handles get expanded for this Expander by calling the native
         * function cwhip_gtk_expander_get_expanded.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _getExpanded(int64 token)
        public:
        /*
         * Creates a GtkExpander; starts collapsed. Label is the header text.
         *
         * Parameters:
         *   label — String label.
         *
         * Returns the constructed Expander.
         */
        Expander(String label) {
            super Widget(23, label, 0, 0)
        }

        /*
         * Sets the expander header label.
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
         * Current header label.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String label() {
            return(_getLabel(_widgetToken()))
        }

        /*
         * Expands or collapses the child area.
         *
         * Parameters:
         *   expanded — bool expanded.
         *
         * Does not return a value.
         */
        void setExpanded(bool expanded) {
            _setExpanded(_widgetToken(), expanded)
        }

        /*
         * True when the child is visible.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool expanded() {
            return(_getExpanded(_widgetToken()))
        }

        /*
         * Sets the single collapsible child widget.
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
         * Detaches child if it is the current expander child.
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
