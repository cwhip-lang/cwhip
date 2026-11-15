/*
 * stdlib/gtk/0.1.0/bindings.cw — native method bindings for the
 * gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    void Application._create(String id) from "cwhip_gtk_application_create"

    Application Application._self() from "cwhip_gtk_self"

    Widget Widget._self() from "cwhip_gtk_self"

    Window Window._windowSelf() from "cwhip_gtk_self"

    TransientWindow TransientWindow._transientSelf() from "cwhip_gtk_self"

    Button Button._buttonSelf() from "cwhip_gtk_self"

    Entry Entry._entrySelf() from "cwhip_gtk_self"

    CheckButton CheckButton._checkSelf() from "cwhip_gtk_self"

    Notebook Notebook._notebookSelf() from "cwhip_gtk_self"

    DrawingArea DrawingArea._drawSelf() from "cwhip_gtk_self"

    ContextMenu ContextMenu._menuSelf() from "cwhip_gtk_self"

    Scrollbar Scrollbar._barSelf() from "cwhip_gtk_self"

    Scale Scale._scaleSelf() from "cwhip_gtk_self"

    SpinButton SpinButton._spinSelf() from "cwhip_gtk_self"

    DropDown DropDown._dropSelf() from "cwhip_gtk_self"

    TextView TextView._textSelf() from "cwhip_gtk_self"

    void Application.initialize() from "cwhip_gtk_initialize"

    String Application.id() from "cwhip_gtk_application_id"

    void Application.run() from "cwhip_gtk_run"

    void Application.quit() from "cwhip_gtk_quit"

    void Application.shutdown() from "cwhip_gtk_shutdown"

    int64 Application.post(void<> action) from "cwhip_gtk_post"

    int64 Application.schedule(int64 milliseconds, void<> action) from "cwhip_gtk_schedule"

    bool Application.cancel(int64 token) from "cwhip_gtk_cancel"

    int64 SignalConnection._activate(Application source, void<> action)
            from "cwhip_gtk_activation_signal"

    int64 SignalConnection._click(Button source, void<> action) from "cwhip_gtk_button_signal"

    int64 SignalConnection._changed(Entry source, void<String> action) from "cwhip_gtk_entry_signal"

    int64 SignalConnection._close(Window source, bool<> action) from "cwhip_gtk_window_signal"

    int64 SignalConnection._close(TransientWindow source, bool<> action)
            from "cwhip_gtk_window_signal"

    int64 SignalConnection._toggled(CheckButton source, void<bool> action) from "cwhip_gtk_checkbox_signal"

    int64 SignalConnection._pageChanged(Notebook source, void<> action)
            from "cwhip_gtk_notebook_signal"

    int64 SignalConnection._focusChanged(Window source, void<bool> action)
            from "cwhip_gtk_window_focus_signal"

    int64 SignalConnection._draw(DrawingArea source, void<int64, int64> action)
            from "cwhip_gtk_drawing_area_signal"

    int64 SignalConnection._click(
            DrawingArea source,
            void<int64,
            fp64,
            fp64> action)
            from "cwhip_gtk_drawing_area_click_signal"

    int64 SignalConnection._drag(
            DrawingArea source,
            void<int64,
            fp64,
            fp64,
            fp64,
            fp64> action)
            from "cwhip_gtk_drawing_area_drag_signal"

    int64 SignalConnection._scroll(
            DrawingArea source,
            void<fp64,
            fp64,
            fp64,
            fp64> action)
            from "cwhip_gtk_drawing_area_scroll_signal"

    int64 SignalConnection._popup(ContextMenu source, void<fp64, fp64> action)
            from "cwhip_gtk_context_menu_popup_signal"

    int64 SignalConnection._valueChanged(Scrollbar source, void<fp64> action)
            from "cwhip_gtk_scrollbar_signal"

    int64 SignalConnection._valueChanged(Scale source, void<fp64> action)
            from "cwhip_gtk_scale_signal"

    int64 SignalConnection._valueChanged(SpinButton source, void<fp64> action)
            from "cwhip_gtk_spin_button_signal"

    int64 SignalConnection._selected(DropDown source, void<int64> action)
            from "cwhip_gtk_drop_down_signal"

    int64 SignalConnection._changed(TextView source, void<String> action)
            from "cwhip_gtk_text_view_signal"

    void DrawingArea._queueDraw(int64 token) from "cwhip_gtk_drawing_area_queue_draw"

    void DrawingArea._contentSize(int64 token, int64 width, int64 height)
            from "cwhip_gtk_drawing_area_set_content_size"

    void DrawingArea._color(int64 token, fp64 r, fp64 g, fp64 b, fp64 a)
            from "cwhip_gtk_drawing_area_set_color"

    void DrawingArea._lineWidth(int64 token, fp64 width)
            from "cwhip_gtk_drawing_area_set_line_width"

    void DrawingArea._fillRect(
            int64 token,
            fp64 x,
            fp64 y,
            fp64 width,
            fp64 height)
            from "cwhip_gtk_drawing_area_fill_rect"

    void DrawingArea._strokeRect(
            int64 token,
            fp64 x,
            fp64 y,
            fp64 width,
            fp64 height)
            from "cwhip_gtk_drawing_area_stroke_rect"

    void DrawingArea._fillCircle(int64 token, fp64 cx, fp64 cy, fp64 radius)
            from "cwhip_gtk_drawing_area_fill_circle"

    void DrawingArea._strokeCircle(int64 token, fp64 cx, fp64 cy, fp64 radius)
            from "cwhip_gtk_drawing_area_stroke_circle"

    void DrawingArea._strokeLine(
            int64 token,
            fp64 x1,
            fp64 y1,
            fp64 x2,
            fp64 y2)
            from "cwhip_gtk_drawing_area_stroke_line"

    void Grid._attachAt(
            int64 token,
            int64 child,
            int64 column,
            int64 row,
            int64 width,
            int64 height)
            from "cwhip_gtk_grid_attach"

    void ContextMenu._bind(int64 token, int64 owner) from "cwhip_gtk_context_menu_bind"

    int64 ContextMenu._addItem(
            int64 token,
            int64 menu,
            String label,
            void<> action)
            from "cwhip_gtk_menu_item_add"

    int64 ContextMenu._addCheck(
            int64 token,
            int64 menu,
            String label,
            bool initial,
            void<bool> action)
            from "cwhip_gtk_menu_check_add"

    int64 ContextMenu._addSubmenu(int64 token, int64 menu, String label)
            from "cwhip_gtk_menu_submenu_add"

    void ContextMenu._separator(int64 token, int64 menu) from "cwhip_gtk_menu_separator_add"

    void ContextMenu._clearMenu(int64 token, int64 menu) from "cwhip_gtk_menu_clear"

    void ContextMenu._popupAt(int64 token, fp64 x, fp64 y) from "cwhip_gtk_context_menu_popup_at"

    void ContextMenu._enabled(int64 token, int64 item, bool value) from "cwhip_gtk_menu_item_enabled"

    void ContextMenu._checked(int64 token, int64 item, bool value) from "cwhip_gtk_menu_item_set_checked"

    bool ContextMenu._isChecked(int64 token, int64 item) from "cwhip_gtk_menu_item_checked"

    void Scrollbar._configure(
            int64 token,
            fp64 value,
            fp64 lower,
            fp64 upper,
            fp64 step,
            fp64 page,
            fp64 pageSize)
        from "cwhip_gtk_scrollbar_configure"

    void Scrollbar._setValue(int64 token, fp64 value) from "cwhip_gtk_scrollbar_set_value"

    fp64 Scrollbar._getValue(int64 token) from "cwhip_gtk_scrollbar_get_value"

    fp64 Scrollbar._getLower(int64 token) from "cwhip_gtk_scrollbar_get_lower"

    fp64 Scrollbar._getUpper(int64 token) from "cwhip_gtk_scrollbar_get_upper"

    fp64 Scrollbar._getPageSize(int64 token) from "cwhip_gtk_scrollbar_get_page_size"

    void Scale._configure(
            int64 token,
            fp64 value,
            fp64 lower,
            fp64 upper,
            fp64 step)
            from "cwhip_gtk_scale_configure"

    void Scale._setValue(int64 token, fp64 value) from "cwhip_gtk_scale_set_value"

    fp64 Scale._getValue(int64 token) from "cwhip_gtk_scale_get_value"

    fp64 Scale._getLower(int64 token) from "cwhip_gtk_scale_get_lower"

    fp64 Scale._getUpper(int64 token) from "cwhip_gtk_scale_get_upper"

    fp64 Scale._getStep(int64 token) from "cwhip_gtk_scale_get_step"

    void ProgressBar._setFraction(int64 token, fp64 fraction)
            from "cwhip_gtk_progress_bar_set_fraction"

    fp64 ProgressBar._getFraction(int64 token) from "cwhip_gtk_progress_bar_get_fraction"

    void ProgressBar._setText(int64 token, String text) from "cwhip_gtk_progress_bar_set_text"

    String ProgressBar._getText(int64 token) from "cwhip_gtk_progress_bar_get_text"

    void ProgressBar._setShowText(int64 token, bool show)
            from "cwhip_gtk_progress_bar_set_show_text"

    bool ProgressBar._getShowText(int64 token) from "cwhip_gtk_progress_bar_get_show_text"

    void ProgressBar._pulse(int64 token) from "cwhip_gtk_progress_bar_pulse"

    void ProgressBar._setPulseStep(int64 token, fp64 step)
            from "cwhip_gtk_progress_bar_set_pulse_step"

    fp64 ProgressBar._getPulseStep(int64 token) from "cwhip_gtk_progress_bar_get_pulse_step"

    void SpinButton._configure(
            int64 token,
            fp64 value,
            fp64 lower,
            fp64 upper,
            fp64 step)
            from "cwhip_gtk_spin_button_configure"

    void SpinButton._setValue(int64 token, fp64 value) from "cwhip_gtk_spin_button_set_value"

    fp64 SpinButton._getValue(int64 token) from "cwhip_gtk_spin_button_get_value"

    fp64 SpinButton._getLower(int64 token) from "cwhip_gtk_spin_button_get_lower"

    fp64 SpinButton._getUpper(int64 token) from "cwhip_gtk_spin_button_get_upper"

    fp64 SpinButton._getStep(int64 token) from "cwhip_gtk_spin_button_get_step"

    void DropDown._clear(int64 token) from "cwhip_gtk_drop_down_clear"

    void DropDown._append(int64 token, String label) from "cwhip_gtk_drop_down_append"

    void DropDown._setSelected(int64 token, int64 index) from "cwhip_gtk_drop_down_set_selected"

    int64 DropDown._getSelected(int64 token) from "cwhip_gtk_drop_down_get_selected"

    String DropDown._getSelectedText(int64 token) from "cwhip_gtk_drop_down_get_selected_text"

    int64 DropDown._getSize(int64 token) from "cwhip_gtk_drop_down_get_size"

    String DropDown._getItem(int64 token, int64 index) from "cwhip_gtk_drop_down_get_item"

    void Frame._setLabel(int64 token, String label) from "cwhip_gtk_frame_set_label"

    String Frame._getLabel(int64 token) from "cwhip_gtk_frame_get_label"

    void Expander._setLabel(int64 token, String label) from "cwhip_gtk_expander_set_label"

    String Expander._getLabel(int64 token) from "cwhip_gtk_expander_get_label"

    void Expander._setExpanded(int64 token, bool expanded)
            from "cwhip_gtk_expander_set_expanded"

    bool Expander._getExpanded(int64 token) from "cwhip_gtk_expander_get_expanded"

    void TextView._setText(int64 token, String text) from "cwhip_gtk_text_view_set_text"

    String TextView._getText(int64 token) from "cwhip_gtk_text_view_get_text"

    void TextView._editable(int64 token, bool editable) from "cwhip_gtk_text_view_set_editable"

    bool TextView._getEditable(int64 token) from "cwhip_gtk_text_view_get_editable"

    void TextView._wrap(int64 token, bool wrap) from "cwhip_gtk_text_view_set_wrap"

    bool TextView._getWrap(int64 token) from "cwhip_gtk_text_view_get_wrap"

    void Entry._editable(int64 token, bool editable) from "cwhip_gtk_entry_editable"

    void Notebook._closable(
            int64 token,
            int64 child,
            String title,
            void<> close)
            from "cwhip_gtk_notebook_closable"

    void Notebook._bordered(int64 token) from "cwhip_gtk_notebook_bordered"

    void Notebook._scrollable(int64 token, bool enabled) from "cwhip_gtk_notebook_scrollable"

    bool Window._bindShortcut(int64 token, String trigger, void<> action)
            from "cwhip_gtk_window_bind_shortcut"

    bool Window._hasShortcut(int64 token, String trigger) from "cwhip_gtk_window_has_shortcut"

    void Window._clearWindowShortcuts(int64 token)
            from "cwhip_gtk_source_view_clear_shortcuts"

    bool Window._maximized(int64 token) from "cwhip_gtk_window_maximized"

    void Window._maximize(int64 token, bool enabled) from "cwhip_gtk_window_maximize"

    void Window._setMenubarAccel(int64 token, bool enabled)
            from "cwhip_gtk_window_handle_menubar_accel"

    bool Window._menubarAccel(int64 token)
            from "cwhip_gtk_window_handles_menubar_accel"

    bool SignalConnection._disconnect(int64 token) from "cwhip_gtk_connection_disconnect"

    bool SignalConnection._connected(int64 token) from "cwhip_gtk_connected"

    int64 Widget._create(
            int64 kind,
            String text,
            int64 orientation,
            int64 spacing,
            void<> root)
            from "cwhip_gtk_widget_create"

    void Widget._dispose(int64 token) from "cwhip_gtk_widget_dispose"

    bool Widget._disposed(int64 token) from "cwhip_gtk_widget_disposed"

    void Widget._visible(int64 token, bool value) from "cwhip_gtk_widget_visible"

    bool Widget._isVisible(int64 token) from "cwhip_gtk_widget_is_visible"

    void Widget._sensitive(int64 token, bool value) from "cwhip_gtk_widget_sensitive"

    void Widget._focusOnClick(int64 token, bool enabled) from "cwhip_gtk_widget_focus_on_click"

    void Widget._canFocus(int64 token, bool enabled) from "cwhip_gtk_widget_can_focus"

    void Widget._expand(int64 token, bool horizontal, bool value) from "cwhip_gtk_widget_expand"

    void Widget._widthRequest(int64 token, int64 width) from "cwhip_gtk_widget_width_request"

    void Widget._cssClass(int64 token, String name, bool add) from "cwhip_gtk_widget_css_class"

    void Widget._tooltip(int64 token, String text) from "cwhip_gtk_widget_tooltip"

    void Widget._focus(int64 token) from "cwhip_gtk_widget_focus"

    void Button._icon(int64 token, String name) from "cwhip_gtk_button_icon"

    int64 MenuBar._addMenu(int64 token, String label) from "cwhip_gtk_menu_add"

    int64 MenuBar._addItem(
            int64 token,
            int64 menu,
            String label,
            void<> action)
            from "cwhip_gtk_menu_item_add"

    void MenuBar._enabled(int64 token, int64 item, bool value) from "cwhip_gtk_menu_item_enabled"

    void MenuBar._activate(int64 token, int64 item) from "cwhip_gtk_menu_item_activate"

    void MenuBar._separator(int64 token, int64 menu) from "cwhip_gtk_menu_separator_add"

    int64 MenuBar._addCheck(
            int64 token,
            int64 menu,
            String label,
            bool initial,
            void<bool> action)
            from "cwhip_gtk_menu_check_add"

    void MenuBar._checked(int64 token, int64 item, bool value) from "cwhip_gtk_menu_item_set_checked"

    bool MenuBar._isChecked(int64 token, int64 item) from "cwhip_gtk_menu_item_checked"

    int64 MenuBar._addSubmenu(int64 token, int64 menu, String label) from "cwhip_gtk_menu_submenu_add"

    void MenuBar._clearMenu(int64 token, int64 menu) from "cwhip_gtk_menu_clear"

    int64 FileDialog._create(
            int64 parent,
            bool save,
            String initialPath,
            void<String> result)
            from "cwhip_gtk_file_dialog_create"

    int64 FileDialog._createMultiple(
            int64 parent,
            String initialPath,
            void<String> path)
            from "cwhip_gtk_file_dialog_create_multiple"

    int64 FileDialog._createFolder(
            int64 parent,
            String initialPath,
            void<String> result)
            from "cwhip_gtk_file_dialog_create_folder"

    void Paned._position(int64 token, int64 position) from "cwhip_gtk_paned_position"

    int64 Paned._getPosition(int64 token) from "cwhip_gtk_paned_get_position"

    bool Tree._isExpanded(int64 token, int64 id) from "cwhip_gtk_tree_is_expanded"

    int64 DirectoryScan._startFiltered(
            int64 owner,
            String path,
            bool hidden,
            String root,
            String excludes,
            void<int64,
            String> result)
        from "cwhip_gtk_directory_start_filtered"

    void Tree._setup(int64 token, void<int64> request, void<int64> activate)
            from "cwhip_gtk_tree_setup"

    void Tree._singleClick(int64 token, bool enabled) from "cwhip_gtk_tree_single_click"

    void Tree._add(
            int64 token,
            int64 parent,
            int64 id,
            String label,
            String icon,
            bool expandable,
            String value,
            int64 data)
            from "cwhip_gtk_tree_add"

    String Tree._value(int64 token, int64 id) from "cwhip_gtk_tree_value"

    int64 Tree._data(int64 token, int64 id) from "cwhip_gtk_tree_data"

    int64 Tree._find(int64 token, String value) from "cwhip_gtk_tree_find"

    int64 Tree._count(int64 token, int64 parent) from "cwhip_gtk_tree_count"

    void Tree._clear(int64 token, int64 parent) from "cwhip_gtk_tree_clear"

    void Tree._expandRow(int64 token, int64 id, bool expanded) from "cwhip_gtk_tree_expand"

    int64 DirectoryScan._start(
            int64 owner,
            String path,
            bool hidden,
            void<int64,
            String> result)
            from "cwhip_gtk_directory_start"

    void DirectoryScan._cancel(int64 token) from "cwhip_gtk_directory_cancel"

    void DirectoryScan._append(
            int64 token,
            int64 tree,
            int64 parent,
            int64 firstId,
            int64 count,
            String icons)
            from "cwhip_gtk_directory_append"

    void AlertDialog._show(int64 parent, String message, String detail) from "cwhip_gtk_alert_show"

    void FileDialog._cancel(int64 token) from "cwhip_gtk_file_dialog_cancel"

    bool FileDialog._pending(int64 token) from "cwhip_gtk_file_dialog_pending"

    void Widget._textSet(int64 token, String text) from "cwhip_gtk_widget_text_set"

    String Widget._textGet(int64 token) from "cwhip_gtk_widget_text_get"

    void Widget._attach(int64 parent, int64 child) from "cwhip_gtk_widget_attach"

    void Widget._remove(int64 parent, int64 child) from "cwhip_gtk_widget_remove"

    void Widget._windowAction(int64 token, int64 action) from "cwhip_gtk_window_action"

    void Widget._windowSize(int64 token, int64 width, int64 height) from "cwhip_gtk_window_size"

    int64 Widget._windowWidth(int64 token) from "cwhip_gtk_window_width"

    int64 Widget._windowHeight(int64 token) from "cwhip_gtk_window_height"

    void Widget._windowTransientFor(int64 token, int64 parent)
            from "cwhip_gtk_window_transient_for"

    void Widget._layout(int64 token, int64 orientation, int64 spacing) from "cwhip_gtk_box_layout"

    void Widget._activeSet(int64 token, bool value) from "cwhip_gtk_checkbox_set"

    bool Widget._activeGet(int64 token) from "cwhip_gtk_checkbox_get"

    void Widget._notebookAppend(int64 notebook, int64 child, String title)
            from "cwhip_gtk_notebook_append"

    int64 Widget._notebookCurrent(int64 notebook) from "cwhip_gtk_notebook_current"

    void Widget._notebookSetCurrent(int64 notebook, int64 page)
            from "cwhip_gtk_notebook_set_current"

    int64 Widget._notebookCount(int64 notebook) from "cwhip_gtk_notebook_count"

    void Widget._notebookTitle(int64 notebook, int64 page, String title)
            from "cwhip_gtk_notebook_title"

}
