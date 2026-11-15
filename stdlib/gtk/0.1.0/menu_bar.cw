/*
 * stdlib/gtk/0.1.0/menu_bar.cw — Gtk.MenuBar from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * MenuBar is a class derived from Widget in this standard-library package.
     *
     * Its methods include _addMenu, _addItem, _enabled, _activate, _separator,
     * _addCheck, and 15 more.
     */
    class MenuBar : Widget {
        private:
        /*
         * Handles add menu for this MenuBar by calling the native function
         * cwhip_gtk_menu_add.
         *
         * Parameters:
         *   token — int64 token.
         *   label — String label.
         *
         * Returns int64.
         */
        int64 _addMenu(int64 token, String label)

        /*
         * Handles add item for this MenuBar by calling the native function
         * cwhip_gtk_menu_item_add.
         *
         * Parameters:
         *   token — int64 token.
         *   menu — int64 menu.
         *   label — String label.
         *   action — void<> action.
         *
         * Returns int64.
         */
        int64 _addItem(int64 token, int64 menu, String label, void<> action)

        /*
         * Handles enabled for this MenuBar by calling the native function
         * cwhip_gtk_menu_item_enabled.
         *
         * Parameters:
         *   token — int64 token.
         *   item — int64 item.
         *   value — bool value.
         *
         * Does not return a value.
         */
        void _enabled(int64 token, int64 item, bool value)

        /*
         * Handles activate for this MenuBar by calling the native function
         * cwhip_gtk_menu_item_activate.
         *
         * Parameters:
         *   token — int64 token.
         *   item — int64 item.
         *
         * Does not return a value.
         */
        void _activate(int64 token, int64 item)

        /*
         * Handles separator for this MenuBar by calling the native function
         * cwhip_gtk_menu_separator_add.
         *
         * Parameters:
         *   token — int64 token.
         *   menu — int64 menu.
         *
         * Does not return a value.
         */
        void _separator(int64 token, int64 menu)

        /*
         * Handles add check for this MenuBar by calling the native function
         * cwhip_gtk_menu_check_add.
         *
         * Parameters:
         *   token — int64 token.
         *   menu — int64 menu.
         *   label — String label.
         *   initial — bool initial.
         *   action — void<bool> action.
         *
         * Returns int64.
         */
        int64 _addCheck(
                int64 token,
                int64 menu,
                String label,
                bool initial,
                void<bool> action)

        /*
         * Handles add submenu for this MenuBar by calling the native function
         * cwhip_gtk_menu_submenu_add.
         *
         * Parameters:
         *   token — int64 token.
         *   menu — int64 menu.
         *   label — String label.
         *
         * Returns int64.
         */
        int64 _addSubmenu(int64 token, int64 menu, String label)

        /*
         * Handles clear menu for this MenuBar by calling the native function
         * cwhip_gtk_menu_clear.
         *
         * Parameters:
         *   token — int64 token.
         *   menu — int64 menu.
         *
         * Does not return a value.
         */
        void _clearMenu(int64 token, int64 menu)

        /*
         * Handles checked for this MenuBar by calling the native function
         * cwhip_gtk_menu_item_set_checked.
         *
         * Parameters:
         *   token — int64 token.
         *   item — int64 item.
         *   value — bool value.
         *
         * Does not return a value.
         */
        void _checked(int64 token, int64 item, bool value)

        /*
         * Handles is checked for this MenuBar by calling the native function
         * cwhip_gtk_menu_item_checked.
         *
         * Parameters:
         *   token — int64 token.
         *   item — int64 item.
         *
         * Returns bool.
         */
        bool _isChecked(int64 token, int64 item)
        public:
        /*
         * Constructs a MenuBar.
         *
         * Takes no parameters.
         *
         * Returns the constructed MenuBar.
         */
        MenuBar() {
            super Widget(10, "", 0, 0)
        }

        /*
         * Returns _addMenu(_widgetToken(), label).
         *
         * Parameters:
         *   label — String label.
         *
         * Returns int64.
         */
        int64 addMenu(String label) {
            return(_addMenu(_widgetToken(), label))
        }

        /*
         * Returns _addItem(_widgetToken(), menu, label, action).
         *
         * Parameters:
         *   menu — int64 menu.
         *   label — String label.
         *   action — void<> action.
         *
         * Returns int64.
         */
        int64 addItem(int64 menu, String label, void<> action) {
            return(_addItem(_widgetToken(), menu, label, action))
        }

        /*
         * Draws a divider before the next item added to menu.
         *
         * Parameters:
         *   menu — int64 menu.
         *
         * Does not return a value.
         */
        void addSeparator(int64 menu) {
            _separator(_widgetToken(), menu)
        }

        /*
         * Adds check item for this MenuBar.
         *
         * Parameters:
         *   menu — int64 menu.
         *   label — String label.
         *   initial — bool initial.
         *   action — void<bool> action.
         *
         * Returns int64.
         */
        int64 addCheckItem(
                int64 menu,
                String label,
                bool initial,
                void<bool> action) {
            return(_addCheck(_widgetToken(), menu, label, initial, action))
        }

        /*
         * Returns _addSubmenu(_widgetToken(), menu, label).
         *
         * Parameters:
         *   menu — int64 menu.
         *   label — String label.
         *
         * Returns int64.
         */
        int64 addSubmenu(int64 menu, String label) {
            return(_addSubmenu(_widgetToken(), menu, label))
        }

        /*
         * Clears menu for this MenuBar.
         *
         * Parameters:
         *   menu — int64 menu.
         *
         * Does not return a value.
         */
        void clearMenu(int64 menu) {
            _clearMenu(_widgetToken(), menu)
        }

        /*
         * Sets item enabled for this MenuBar.
         *
         * Parameters:
         *   item — int64 item.
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void setItemEnabled(int64 item, bool enabled) {
            _enabled(_widgetToken(), item, enabled)
        }

        /*
         * Handles activate item for this MenuBar.
         *
         * Parameters:
         *   item — int64 item.
         *
         * Does not return a value.
         */
        void activateItem(int64 item) {
            _activate(_widgetToken(), item)
        }

        /*
         * Sets item checked for this MenuBar.
         *
         * Parameters:
         *   item — int64 item.
         *   checked — bool checked.
         *
         * Does not return a value.
         */
        void setItemChecked(int64 item, bool checked) {
            _checked(_widgetToken(), item, checked)
        }

        /*
         * Returns _isChecked(_widgetToken(), item).
         *
         * Parameters:
         *   item — int64 item.
         *
         * Returns bool.
         */
        bool itemChecked(int64 item) {
            return(_isChecked(_widgetToken(), item))
        }
    }
}
