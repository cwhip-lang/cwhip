/*
 * stdlib/gtk/0.1.0/widget.cw — Gtk.Widget from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Widget is a class in this standard-library package.
     *
     * Its methods include _self, _keepAlive, _create, _dispose, _disposed,
     * _visible, and 55 more.
     */
    class Widget {
        private:
        int64 _id

        /*
         * Handles self for this Widget by calling the native function
         * cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns Widget.
         */
        Widget _self()

        /*
         * Handles keep alive for this Widget.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void _keepAlive() {
        }

        /*
         * Handles create for this Widget by calling the native function
         * cwhip_gtk_widget_create.
         *
         * Parameters:
         *   kind — int64 kind.
         *   text — String text.
         *   orientation — int64 orientation.
         *   spacing — int64 spacing.
         *   root — void<> root.
         *
         * Returns int64.
         */
        int64 _create(
                int64 kind,
                String text,
                int64 orientation,
                int64 spacing,
                void<> root)

        /*
         * Handles dispose for this Widget by calling the native function
         * cwhip_gtk_widget_dispose.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _dispose(int64 token)

        /*
         * Handles disposed for this Widget by calling the native function
         * cwhip_gtk_widget_disposed.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _disposed(int64 token)

        /*
         * Handles visible for this Widget by calling the native function
         * cwhip_gtk_widget_visible.
         *
         * Parameters:
         *   token — int64 token.
         *   value — bool value.
         *
         * Does not return a value.
         */
        void _visible(int64 token, bool value)

        /*
         * Handles is visible for this Widget by calling the native function
         * cwhip_gtk_widget_is_visible.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _isVisible(int64 token)

        /*
         * Handles sensitive for this Widget by calling the native function
         * cwhip_gtk_widget_sensitive.
         *
         * Parameters:
         *   token — int64 token.
         *   value — bool value.
         *
         * Does not return a value.
         */
        void _sensitive(int64 token, bool value)

        /*
         * Handles expand for this Widget by calling the native function
         * cwhip_gtk_widget_expand.
         *
         * Parameters:
         *   token — int64 token.
         *   horizontal — bool horizontal.
         *   value — bool value.
         *
         * Does not return a value.
         */
        void _expand(int64 token, bool horizontal, bool value)

        /*
         * Handles width request for this Widget by calling the native function
         * cwhip_gtk_widget_width_request.
         *
         * Parameters:
         *   token — int64 token.
         *   width — int64 width.
         *
         * Does not return a value.
         */
        void _widthRequest(int64 token, int64 width)

        /*
         * Handles css class for this Widget by calling the native function
         * cwhip_gtk_widget_css_class.
         *
         * Parameters:
         *   token — int64 token.
         *   name — String name.
         *   add — bool add.
         *
         * Does not return a value.
         */
        void _cssClass(int64 token, String name, bool add)

        /*
         * Handles tooltip for this Widget by calling the native function
         * cwhip_gtk_widget_tooltip.
         *
         * Parameters:
         *   token — int64 token.
         *   text — String text.
         *
         * Does not return a value.
         */
        void _tooltip(int64 token, String text)

        /*
         * Handles focus for this Widget by calling the native function
         * cwhip_gtk_widget_focus.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _focus(int64 token)

        /*
         * Handles focus on click for this Widget by calling the native
         * function cwhip_gtk_widget_focus_on_click.
         *
         * Parameters:
         *   token — int64 token.
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void _focusOnClick(int64 token, bool enabled)

        /*
         * Handles can focus for this Widget by calling the native function
         * cwhip_gtk_widget_can_focus.
         *
         * Parameters:
         *   token — int64 token.
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void _canFocus(int64 token, bool enabled)

        /*
         * Handles text set for this Widget by calling the native function
         * cwhip_gtk_widget_text_set.
         *
         * Parameters:
         *   token — int64 token.
         *   text — String text.
         *
         * Does not return a value.
         */
        void _textSet(int64 token, String text)

        /*
         * Handles text get for this Widget by calling the native function
         * cwhip_gtk_widget_text_get.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns String.
         */
        String _textGet(int64 token)

        /*
         * Handles attach for this Widget by calling the native function
         * cwhip_gtk_widget_attach.
         *
         * Parameters:
         *   parent — int64 parent.
         *   child — int64 child.
         *
         * Does not return a value.
         */
        void _attach(int64 parent, int64 child)

        /*
         * Handles remove for this Widget by calling the native function
         * cwhip_gtk_widget_remove.
         *
         * Parameters:
         *   parent — int64 parent.
         *   child — int64 child.
         *
         * Does not return a value.
         */
        void _remove(int64 parent, int64 child)

        /*
         * Handles window action for this Widget by calling the native function
         * cwhip_gtk_window_action.
         *
         * Parameters:
         *   token — int64 token.
         *   action — int64 action.
         *
         * Does not return a value.
         */
        void _windowAction(int64 token, int64 action)

        /*
         * Handles window size for this Widget by calling the native function
         * cwhip_gtk_window_size.
         *
         * Parameters:
         *   token — int64 token.
         *   width — int64 width.
         *   height — int64 height.
         *
         * Does not return a value.
         */
        void _windowSize(int64 token, int64 width, int64 height)

        /*
         * Handles window width for this Widget by calling the native function
         * cwhip_gtk_window_width.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns int64.
         */
        int64 _windowWidth(int64 token)

        /*
         * Handles window height for this Widget by calling the native function
         * cwhip_gtk_window_height.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns int64.
         */
        int64 _windowHeight(int64 token)

        /*
         * Handles window transient for this Widget by calling the native
         * function cwhip_gtk_window_transient_for.
         *
         * Parameters:
         *   token — int64 token.
         *   parent — int64 parent.
         *
         * Does not return a value.
         */
        void _windowTransientFor(int64 token, int64 parent)

        /*
         * Handles layout for this Widget by calling the native function
         * cwhip_gtk_box_layout.
         *
         * Parameters:
         *   token — int64 token.
         *   orientation — int64 orientation.
         *   spacing — int64 spacing.
         *
         * Does not return a value.
         */
        void _layout(int64 token, int64 orientation, int64 spacing)

        /*
         * Handles active set for this Widget by calling the native function
         * cwhip_gtk_checkbox_set.
         *
         * Parameters:
         *   token — int64 token.
         *   value — bool value.
         *
         * Does not return a value.
         */
        void _activeSet(int64 token, bool value)

        /*
         * Handles active get for this Widget by calling the native function
         * cwhip_gtk_checkbox_get.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _activeGet(int64 token)
        protected:
        /*
         * Handles notebook append for this Widget by calling the native
         * function cwhip_gtk_notebook_append.
         *
         * Parameters:
         *   notebook — int64 notebook.
         *   child — int64 child.
         *   title — String title.
         *
         * Does not return a value.
         */
        void _notebookAppend(int64 notebook, int64 child, String title)

        /*
         * Handles notebook current for this Widget by calling the native
         * function cwhip_gtk_notebook_current.
         *
         * Parameters:
         *   notebook — int64 notebook.
         *
         * Returns int64.
         */
        int64 _notebookCurrent(int64 notebook)

        /*
         * Handles notebook set current for this Widget by calling the native
         * function cwhip_gtk_notebook_set_current.
         *
         * Parameters:
         *   notebook — int64 notebook.
         *   page — int64 page.
         *
         * Does not return a value.
         */
        void _notebookSetCurrent(int64 notebook, int64 page)

        /*
         * Handles notebook count for this Widget by calling the native
         * function cwhip_gtk_notebook_count.
         *
         * Parameters:
         *   notebook — int64 notebook.
         *
         * Returns int64.
         */
        int64 _notebookCount(int64 notebook)

        /*
         * Handles notebook title for this Widget by calling the native
         * function cwhip_gtk_notebook_title.
         *
         * Parameters:
         *   notebook — int64 notebook.
         *   page — int64 page.
         *   title — String title.
         *
         * Does not return a value.
         */
        void _notebookTitle(int64 notebook, int64 page, String title)

        /*
         * Constructs a Widget and stores _id.
         *
         * Parameters:
         *   kind — int64 kind.
         *   text — String text.
         *   orientation — int64 orientation.
         *   spacing — int64 spacing.
         *
         * Returns the constructed Widget.
         */
        Widget(int64 kind, String text, int64 orientation, int64 spacing) {
            _id = _create(kind, text, orientation, spacing, _self()._keepAlive)
        }

        /*
         * Handles set text for this Widget.
         *
         * Parameters:
         *   text — String text.
         *
         * Does not return a value.
         */
        void _setText(String text) {
            _textSet(_id, text)
        }

        /*
         * Returns _textGet(_id).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String _getText() {
            return(_textGet(_id))
        }

        /*
         * Handles attach child for this Widget.
         *
         * Parameters:
         *   child — Widget child.
         *
         * Does not return a value.
         */
        void _attachChild(Widget child) {
            _attach(_id, child._id)
        }

        /*
         * Handles remove child for this Widget.
         *
         * Parameters:
         *   child — Widget child.
         *
         * Does not return a value.
         */
        void _removeChild(Widget child) {
            _remove(_id, child._id)
        }

        /*
         * Handles present window for this Widget.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void _presentWindow() {
            _windowAction(_id, 0)
        }

        /*
         * Handles close window for this Widget.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void _closeWindow() {
            _windowAction(_id, 1)
        }

        /*
         * Handles size window for this Widget.
         *
         * Parameters:
         *   width — int64 width.
         *   height — int64 height.
         *
         * Does not return a value.
         */
        void _sizeWindow(int64 width, int64 height) {
            _windowSize(_id, width, height)
        }

        /*
         * Returns _windowWidth(_id).
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 _defaultWidth() {
            return(_windowWidth(_id))
        }

        /*
         * Returns _windowHeight(_id).
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 _defaultHeight() {
            return(_windowHeight(_id))
        }

        /*
         * Handles set transient for this Widget.
         *
         * Parameters:
         *   parent — int64 parent.
         *
         * Does not return a value.
         */
        void _setTransientFor(int64 parent) {
            _windowTransientFor(_id, parent)
        }

        /*
         * Handles box layout for this Widget.
         *
         * Parameters:
         *   orientation — int64 orientation.
         *   spacing — int64 spacing.
         *
         * Does not return a value.
         */
        void _boxLayout(int64 orientation, int64 spacing) {
            _layout(_id, orientation, spacing)
        }

        /*
         * Handles set active for this Widget.
         *
         * Parameters:
         *   value — bool value.
         *
         * Does not return a value.
         */
        void _setActive(bool value) {
            _activeSet(_id, value)
        }

        /*
         * Returns _activeGet(_id).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool _getActive() {
            return(_activeGet(_id))
        }

        /*
         * Handles grab focus for this Widget.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void _grabFocus() {
            _focus(_id)
        }
        public:
        /*
         * Returns the stored _id.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 _widgetToken() {
            return(_id)
        }

        /*
         * Disposes the Widget state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void dispose() {
            _dispose(_id)
        }

        /*
         * Returns _disposed(_id).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool disposed() {
            return(_disposed(_id))
        }

        /*
         * Sets visible for this Widget.
         *
         * Parameters:
         *   value — bool value.
         *
         * Does not return a value.
         */
        void setVisible(bool value) {
            _visible(_id, value)
        }

        /*
         * Returns _isVisible(_id).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool visible() {
            return(_isVisible(_id))
        }

        /*
         * Sets sensitive for this Widget.
         *
         * Parameters:
         *   value — bool value.
         *
         * Does not return a value.
         */
        void setSensitive(bool value) {
            _sensitive(_id, value)
        }

        /*
         * Sets hexpand for this Widget.
         *
         * Parameters:
         *   value — bool value.
         *
         * Does not return a value.
         */
        void setHExpand(bool value) {
            _expand(_id, true, value)
        }

        /*
         * Sets vexpand for this Widget.
         *
         * Parameters:
         *   value — bool value.
         *
         * Does not return a value.
         */
        void setVExpand(bool value) {
            _expand(_id, false, value)
        }

        /*
         * Sets width request for this Widget.
         *
         * Parameters:
         *   width — int64 width.
         *
         * Does not return a value.
         */
        void setWidthRequest(int64 width) {
            _widthRequest(_id, width)
        }

        /*
         * Adds css class for this Widget.
         *
         * Parameters:
         *   name — String name.
         *
         * Does not return a value.
         */
        void addCssClass(String name) {
            _cssClass(_id, name, true)
        }

        /*
         * Removes css class for this Widget.
         *
         * Parameters:
         *   name — String name.
         *
         * Does not return a value.
         */
        void removeCssClass(String name) {
            _cssClass(_id, name, false)
        }

        /*
         * Sets tooltip for this Widget.
         *
         * Parameters:
         *   text — String text.
         *
         * Does not return a value.
         */
        void setTooltip(String text) {
            _tooltip(_id, text)
        }

        /*
         * Buttons default to focus-on-click off; use these for toolbar
         * controls that must not take focus from an editor on the first press.
         *
         * Parameters:
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void setFocusOnClick(bool enabled) {
            _focusOnClick(_id, enabled)
        }

        /*
         * Sets can focus for this Widget.
         *
         * Parameters:
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void setCanFocus(bool enabled) {
            _canFocus(_id, enabled)
        }
    }
}
