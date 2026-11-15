/*
 * stdlib/gtk/0.1.0/tree.cw — Gtk.Tree from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Tree is a class derived from Widget in this standard-library package.
     *
     * Its methods include _singleClick, _setup, _add, _clear, _expandRow,
     * _isExpanded, and 14 more.
     */
    class Tree : Widget {
        private:
        /*
         * Handles single click for this Tree by calling the native function
         * cwhip_gtk_tree_single_click.
         *
         * Parameters:
         *   token — int64 token.
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void _singleClick(int64 token, bool enabled)

        /*
         * Handles setup for this Tree by calling the native function
         * cwhip_gtk_tree_setup.
         *
         * Parameters:
         *   token — int64 token.
         *   request — void<int64> request.
         *   activate — void<int64> activate.
         *
         * Does not return a value.
         */
        void _setup(int64 token, void<int64> request, void<int64> activate)

        /*
         * Handles add for this Tree by calling the native function
         * cwhip_gtk_tree_add.
         *
         * Parameters:
         *   token — int64 token.
         *   parent — int64 parent.
         *   id — int64 input value.
         *   label — String label.
         *   icon — String icon.
         *   expandable — bool expandable.
         *   value — String value.
         *   data — int64 data.
         *
         * Does not return a value.
         */
        void _add(
                int64 token,
                int64 parent,
                int64 id,
                String label,
                String icon,
                bool expandable,
                String value,
                int64 data)

        /*
         * Handles clear for this Tree by calling the native function
         * cwhip_gtk_tree_clear.
         *
         * Parameters:
         *   token — int64 token.
         *   parent — int64 parent.
         *
         * Does not return a value.
         */
        void _clear(int64 token, int64 parent)

        /*
         * Handles expand row for this Tree by calling the native function
         * cwhip_gtk_tree_expand.
         *
         * Parameters:
         *   token — int64 token.
         *   id — int64 input value.
         *   expanded — bool expanded.
         *
         * Does not return a value.
         */
        void _expandRow(int64 token, int64 id, bool expanded)

        /*
         * Handles is expanded for this Tree by calling the native function
         * cwhip_gtk_tree_is_expanded.
         *
         * Parameters:
         *   token — int64 token.
         *   id — int64 input value.
         *
         * Returns bool.
         */
        bool _isExpanded(int64 token, int64 id)

        /*
         * Handles value for this Tree by calling the native function
         * cwhip_gtk_tree_value.
         *
         * Parameters:
         *   token — int64 token.
         *   id — int64 input value.
         *
         * Returns String.
         */
        String _value(int64 token, int64 id)

        /*
         * Handles data for this Tree by calling the native function
         * cwhip_gtk_tree_data.
         *
         * Parameters:
         *   token — int64 token.
         *   id — int64 input value.
         *
         * Returns int64.
         */
        int64 _data(int64 token, int64 id)

        /*
         * Handles find for this Tree by calling the native function
         * cwhip_gtk_tree_find.
         *
         * Parameters:
         *   token — int64 token.
         *   value — String value.
         *
         * Returns int64.
         */
        int64 _find(int64 token, String value)

        /*
         * Handles count for this Tree by calling the native function
         * cwhip_gtk_tree_count.
         *
         * Parameters:
         *   token — int64 token.
         *   parent — int64 parent.
         *
         * Returns int64.
         */
        int64 _count(int64 token, int64 parent)
        public:
        /*
         * Constructs a Tree.
         *
         * Parameters:
         *   request — void<int64> request.
         *   activate — void<int64> activate.
         *
         * Returns the constructed Tree.
         */
        Tree(void<int64> request, void<int64> activate) {
            super Widget(13, "", 0, 0)
            _setup(_widgetToken(), request, activate)
        }

        /*
         * Sets single click activate for this Tree.
         *
         * Parameters:
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void setSingleClickActivate(bool enabled) {
            _singleClick(_widgetToken(), enabled)
        }

        /*
         * Adds the Tree state.
         *
         * Parameters:
         *   parent — int64 parent.
         *   id — int64 input value.
         *   label — String label.
         *   icon — String icon.
         *   expandable — bool expandable.
         *   value — String value.
         *   data — int64 data.
         *
         * Does not return a value.
         */
        void add(
                int64 parent,
                int64 id,
                String label,
                String icon,
                bool expandable,
                String value,
                int64 data) {
            _add(
                    _widgetToken(),
                    parent,
                    id,
                    label,
                    icon,
                    expandable,
                    value,
                    data)
        }

        /*
         * Clears the Tree state.
         *
         * Parameters:
         *   parent — int64 parent.
         *
         * Does not return a value.
         */
        void clear(int64 parent) {
            _clear(_widgetToken(), parent)
        }

        /*
         * Sets expanded for this Tree.
         *
         * Parameters:
         *   id — int64 input value.
         *   expanded — bool expanded.
         *
         * Does not return a value.
         */
        void setExpanded(int64 id, bool expanded) {
            _expandRow(_widgetToken(), id, expanded)
        }

        /*
         * Returns _isExpanded(_widgetToken(), id).
         *
         * Parameters:
         *   id — int64 input value.
         *
         * Returns bool.
         */
        bool expanded(int64 id) {
            return(_isExpanded(_widgetToken(), id))
        }

        /*
         * Returns _value(_widgetToken(), id).
         *
         * Parameters:
         *   id — int64 input value.
         *
         * Returns String.
         */
        String value(int64 id) {
            return(_value(_widgetToken(), id))
        }

        /*
         * Returns _data(_widgetToken(), id).
         *
         * Parameters:
         *   id — int64 input value.
         *
         * Returns int64.
         */
        int64 data(int64 id) {
            return(_data(_widgetToken(), id))
        }

        /*
         * Returns _find(_widgetToken(), value).
         *
         * Parameters:
         *   value — String value.
         *
         * Returns int64.
         */
        int64 findValue(String value) {
            return(_find(_widgetToken(), value))
        }

        /*
         * Returns _count(_widgetToken(), parent).
         *
         * Parameters:
         *   parent — int64 parent.
         *
         * Returns int64.
         */
        int64 childCount(int64 parent) {
            return(_count(_widgetToken(), parent))
        }
    }
}
