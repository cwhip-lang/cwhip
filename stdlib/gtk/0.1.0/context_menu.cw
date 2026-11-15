/*
 * stdlib/gtk/0.1.0/context_menu.cw — Gtk.ContextMenu from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * ContextMenu is a class derived from Widget in this standard-library
     * package.
     *
     * Its methods include _menuSelf, _bind, _addItem, _addCheck, _addSubmenu,
     * _separator, and 18 more.
     */
    class ContextMenu : Widget {
        private:
        /*
         * Handles menu self for this ContextMenu by calling the native
         * function cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns ContextMenu.
         */
        ContextMenu _menuSelf()

        /*
         * Handles bind for this ContextMenu by calling the native function
         * cwhip_gtk_context_menu_bind.
         *
         * Parameters:
         *   token — int64 token.
         *   owner — int64 owner.
         *
         * Does not return a value.
         */
        void _bind(int64 token, int64 owner)

        /*
         * Handles add item for this ContextMenu by calling the native function
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
         * Handles add check for this ContextMenu by calling the native
         * function cwhip_gtk_menu_check_add.
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
         * Handles add submenu for this ContextMenu by calling the native
         * function cwhip_gtk_menu_submenu_add.
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
         * Handles separator for this ContextMenu by calling the native
         * function cwhip_gtk_menu_separator_add.
         *
         * Parameters:
         *   token — int64 token.
         *   menu — int64 menu.
         *
         * Does not return a value.
         */
        void _separator(int64 token, int64 menu)

        /*
         * Handles clear menu for this ContextMenu by calling the native
         * function cwhip_gtk_menu_clear.
         *
         * Parameters:
         *   token — int64 token.
         *   menu — int64 menu.
         *
         * Does not return a value.
         */
        void _clearMenu(int64 token, int64 menu)

        /*
         * Handles popup at for this ContextMenu by calling the native function
         * cwhip_gtk_context_menu_popup_at.
         *
         * Parameters:
         *   token — int64 token.
         *   x — fp64 input value.
         *   y — fp64 input value.
         *
         * Does not return a value.
         */
        void _popupAt(int64 token, fp64 x, fp64 y)

        /*
         * Handles enabled for this ContextMenu by calling the native function
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
         * Handles checked for this ContextMenu by calling the native function
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
         * Handles is checked for this ContextMenu by calling the native
         * function cwhip_gtk_menu_item_checked.
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
         * Attaches a secondary-button PopoverMenu to owner (any Widget,
         * including DrawingArea). Right-click coords are delivered via onPopup
         * before the menu opens so the app can clear/rebuild items.
         *
         * Parameters:
         *   owner — Widget owner.
         *
         * Returns the constructed ContextMenu.
         */
        ContextMenu(Widget owner) {
            super Widget(15, "", 0, 0)
            _bind(_widgetToken(), owner._widgetToken())
        }

        /*
         * Prefer addItem/addCheckItem so the menu looks like a native popup.
         * setChild still accepts a custom widget for callers that need one.
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
         * Appends a row to the root menu; returns an item token for
         * enable/check.
         *
         * Parameters:
         *   label — String label.
         *   action — void<> action.
         *
         * Returns int64.
         */
        int64 addItem(String label, void<> action) {
            return(_addItem(_widgetToken(), 0, label, action))
        }

        /*
         * Appends a row to submenu index from addSubmenu.
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
         * Returns _addCheck(_widgetToken(), 0, label, initial, action).
         *
         * Parameters:
         *   label — String label.
         *   initial — bool initial.
         *   action — void<bool> action.
         *
         * Returns int64.
         */
        int64 addCheckItem(String label, bool initial, void<bool> action) {
            return(_addCheck(_widgetToken(), 0, label, initial, action))
        }

        /*
         * Adds check item for this ContextMenu.
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
         * Starts a new section on the root menu (native divider).
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void addSeparator() {
            _separator(_widgetToken(), 0)
        }

        /*
         * Adds separator for this ContextMenu.
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
         * Nested submenu under the root; returns a menu index for
         * addItem(menu, ...).
         *
         * Parameters:
         *   label — String label.
         *
         * Returns int64.
         */
        int64 addSubmenu(String label) {
            return(_addSubmenu(_widgetToken(), 0, label))
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
         * Removes all rows from the root menu so the app can rebuild on each
         * popup.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void clear() {
            _clearMenu(_widgetToken(), 0)
        }

        /*
         * Clears menu for this ContextMenu.
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
         * Sets item enabled for this ContextMenu.
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
         * Sets item checked for this ContextMenu.
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

        /*
         * Fires just before the menu opens with owner-local click coordinates.
         * A later onPopup replaces the previous callback.
         *
         * Parameters:
         *   action — void<fp64,fp64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onPopup(void<fp64, fp64> action) {
            return(SignalConnection(_menuSelf(), action))
        }

        /*
         * Programmatic popup at owner-local coordinates (after building
         * items).
         *
         * Parameters:
         *   x — fp64 input value.
         *   y — fp64 input value.
         *
         * Does not return a value.
         */
        void popupAt(fp64 x, fp64 y) {
            _popupAt(_widgetToken(), x, y)
        }
    }
}
