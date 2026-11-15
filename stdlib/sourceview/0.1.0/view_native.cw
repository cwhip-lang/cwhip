/*
 * stdlib/sourceview/0.1.0/view_native.cw
 *
 * Native bindings for GtkSource.View and GtkSource.Content.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace GtkSource {
    /*
     * Handles set text for this View by calling the native function
     * cwhip_gtk_source_view_set_text.
     *
     * Parameters:
     *   token — int64 token.
     *   text — String text.
     *
     * Does not return a value.
     */
    void View._setText(int64 token, String text) from "cwhip_gtk_source_view_set_text"

    /*
     * Handles get text for this View by calling the native function
     * cwhip_gtk_source_view_get_text.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns String.
     */
    String View._getText(int64 token) from "cwhip_gtk_source_view_get_text"

    /*
     * Handles modified for this View by calling the native function
     * cwhip_gtk_source_view_modified.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns bool.
     */
    bool View._modified(int64 token) from "cwhip_gtk_source_view_modified"

    /*
     * Handles mark saved for this View by calling the native function
     * cwhip_gtk_source_view_mark_saved.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Does not return a value.
     */
    void View._markSaved(int64 token) from "cwhip_gtk_source_view_mark_saved"

    /*
     * Handles undo for this View by calling the native function
     * cwhip_gtk_source_view_undo.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Does not return a value.
     */
    void View._undo(int64 token) from "cwhip_gtk_source_view_undo"

    /*
     * Handles redo for this View by calling the native function
     * cwhip_gtk_source_view_redo.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Does not return a value.
     */
    void View._redo(int64 token) from "cwhip_gtk_source_view_redo"

    /*
     * Handles strip trailing spaces for this View by calling the native
     * function cwhip_gtk_source_view_strip_trailing_spaces.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns bool.
     */
    bool View._stripTrailingSpaces(int64 token) from "cwhip_gtk_source_view_strip_trailing_spaces"

    /*
     * Handles auto pair for this View by calling the native function
     * cwhip_gtk_source_view_auto_pair.
     *
     * Parameters:
     *   token — int64 token.
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View._autoPair(int64 token, bool enabled) from "cwhip_gtk_source_view_auto_pair"

    /*
     * Handles selected lines for this View by calling the native function
     * cwhip_gtk_source_view_selected_lines_edit.
     *
     * Parameters:
     *   token — int64 token.
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View._selectedLines(int64 token, bool enabled)
        from "cwhip_gtk_source_view_selected_lines_edit"

    /*
     * Handles can undo for this View by calling the native function
     * cwhip_gtk_source_view_can_undo.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns bool.
     */
    bool View._canUndo(int64 token) from "cwhip_gtk_source_view_can_undo"

    /*
     * Handles can redo for this View by calling the native function
     * cwhip_gtk_source_view_can_redo.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns bool.
     */
    bool View._canRedo(int64 token) from "cwhip_gtk_source_view_can_redo"

    /*
     * Handles has selection for this View by calling the native function
     * cwhip_gtk_source_view_has_selection.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns bool.
     */
    bool View._hasSelection(int64 token) from "cwhip_gtk_source_view_has_selection"

    /*
     * Handles edit for this View by calling the native function
     * cwhip_gtk_source_view_edit.
     *
     * Parameters:
     *   token — int64 token.
     *   operation — int64 operation.
     *
     * Does not return a value.
     */
    void View._edit(int64 token, int64 operation) from "cwhip_gtk_source_view_edit"

    /*
     * Handles focus for this View by calling the native function
     * cwhip_gtk_widget_focus.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Does not return a value.
     */
    void View._focus(int64 token) from "cwhip_gtk_widget_focus"

    /*
     * Handles find for this View by calling the native function
     * cwhip_gtk_source_view_find.
     *
     * Parameters:
     *   token — int64 token.
     *   query — String query.
     *
     * Returns bool.
     */
    bool View._find(int64 token, String query) from "cwhip_gtk_source_view_find"

    /*
     * Handles replace next for this View by calling the native function
     * cwhip_gtk_source_view_replace_next.
     *
     * Parameters:
     *   token — int64 token.
     *   query — String query.
     *   replacement — String replacement.
     *
     * Returns bool.
     */
    bool View._replaceNext(int64 token, String query, String replacement)
        from "cwhip_gtk_source_view_replace_next"

    /*
     * Handles line for this View by calling the native function
     * cwhip_gtk_source_view_line.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns int64.
     */
    int64 View._line(int64 token) from "cwhip_gtk_source_view_line"

    /*
     * Handles column for this View by calling the native function
     * cwhip_gtk_source_view_column.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns int64.
     */
    int64 View._column(int64 token) from "cwhip_gtk_source_view_column"

    /*
     * Handles set cursor for this View by calling the native function
     * cwhip_gtk_source_view_set_cursor.
     *
     * Parameters:
     *   token — int64 token.
     *   line — int64 line.
     *   column — int64 column.
     *
     * Does not return a value.
     */
    void View._setCursor(int64 token, int64 line, int64 column) from "cwhip_gtk_source_view_set_cursor"

    /*
     * Handles center cursor for this View by calling the native function
     * cwhip_gtk_source_view_center_cursor.
     *
     * Parameters:
     *   token — int64 token.
     *   line — int64 line.
     *   column — int64 column.
     *
     * Does not return a value.
     */
    void View._centerCursor(int64 token, int64 line, int64 column) from "cwhip_gtk_source_view_center_cursor"

    /*
     * Handles editable for this View by calling the native function
     * cwhip_gtk_source_view_editable.
     *
     * Parameters:
     *   token — int64 token.
     *   editable — bool editable.
     *
     * Does not return a value.
     */
    void View._editable(int64 token, bool editable) from "cwhip_gtk_source_view_editable"

    /*
     * Handles has context for this View by calling the native function
     * cwhip_gtk_source_view_has_context.
     *
     * Parameters:
     *   token — int64 token.
     *   context — String context.
     *   offset — int64 offset.
     *
     * Returns bool.
     */
    bool View._hasContext(int64 token, String context, int64 offset)
        from "cwhip_gtk_source_view_has_context"

    /*
     * Handles language for this View by calling the native function
     * cwhip_gtk_source_view_language.
     *
     * Parameters:
     *   token — int64 token.
     *   language — String language.
     *
     * Returns bool.
     */
    bool View._language(int64 token, String language) from "cwhip_gtk_source_view_language"

    /*
     * Handles monospace for this View by calling the native function
     * cwhip_gtk_source_view_monospace.
     *
     * Parameters:
     *   token — int64 token.
     *   monospace — bool monospace.
     *
     * Does not return a value.
     */
    void View._monospace(int64 token, bool monospace)
        from "cwhip_gtk_source_view_monospace"

    /*
     * Handles emoji menu for this View by calling the native function
     * cwhip_gtk_source_view_emoji_menu.
     *
     * Parameters:
     *   token — int64 token.
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View._emojiMenu(int64 token, bool enabled) from "cwhip_gtk_source_view_emoji_menu"

    /*
     * Handles language id for this View by calling the native function
     * cwhip_gtk_source_view_language_id.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns String.
     */
    String View._languageId(int64 token) from "cwhip_gtk_source_view_language_id"

    /*
     * Handles search for this View by calling the native function
     * cwhip_gtk_source_view_search.
     *
     * Parameters:
     *   token — int64 token.
     *   query — String query.
     *   options — int64 options.
     *
     * Returns bool.
     */
    bool View._search(int64 token, String query, int64 options) from "cwhip_gtk_source_view_search"

    /*
     * Handles replace for this View by calling the native function
     * cwhip_gtk_source_view_replace.
     *
     * Parameters:
     *   token — int64 token.
     *   query — String query.
     *   replacement — String replacement.
     *   options — int64 options.
     *
     * Returns bool.
     */
    bool View._replace(
            int64 token,
            String query,
            String replacement,
            int64 options)
        from "cwhip_gtk_source_view_replace"

    /*
     * Handles replace all for this View by calling the native function
     * cwhip_gtk_source_view_replace_all.
     *
     * Parameters:
     *   token — int64 token.
     *   query — String query.
     *   replacement — String replacement.
     *   options — int64 options.
     *
     * Returns int64.
     */
    int64 View._replaceAll(
            int64 token,
            String query,
            String replacement,
            int64 options)
        from "cwhip_gtk_source_view_replace_all"

    /*
     * Handles capture scope for this View by calling the native function
     * cwhip_gtk_source_view_capture_scope.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns bool.
     */
    bool View._captureScope(int64 token) from "cwhip_gtk_source_view_capture_scope"

    /*
     * Handles has scope for this View by calling the native function
     * cwhip_gtk_source_view_has_scope.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns bool.
     */
    bool View._hasScope(int64 token) from "cwhip_gtk_source_view_has_scope"

    /*
     * Handles selected text for this View by calling the native function
     * cwhip_gtk_source_view_selected_text.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns String.
     */
    String View._selectedText(int64 token) from "cwhip_gtk_source_view_selected_text"

    String Content.languageFor(String path) from "cwhip_gtk_source_language_for"

    bool Content.isText(String data) from "cwhip_gtk_source_is_text"

    /*
     * Handles bind shortcut for this View by calling the native function
     * cwhip_gtk_source_view_bind_shortcut.
     *
     * Parameters:
     *   token — int64 token.
     *   trigger — String trigger.
     *   action — void<> action.
     *
     * Returns bool.
     */
    bool View._bindShortcut(int64 token, String trigger, void<> action)
        from "cwhip_gtk_source_view_bind_shortcut"

    /*
     * Handles has shortcut for this View by calling the native function
     * cwhip_gtk_source_view_has_shortcut.
     *
     * Parameters:
     *   token — int64 token.
     *   trigger — String trigger.
     *
     * Returns bool.
     */
    bool View._hasShortcut(int64 token, String trigger)
        from "cwhip_gtk_source_view_has_shortcut"

    /*
     * Handles clear shortcuts for this View by calling the native function
     * cwhip_gtk_source_view_clear_shortcuts.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Does not return a value.
     */
    void View._clearShortcuts(int64 token) from "cwhip_gtk_source_view_clear_shortcuts"

    /*
     * Handles configure for this View by calling the native function
     * cwhip_gtk_source_view_configure.
     *
     * Parameters:
     *   token — int64 token.
     *   font — String font.
     *   size — int64 size.
     *   tabs — int64 tabs.
     *   spaces — bool spaces.
     *   numbers — bool numbers.
     *   wrap — bool wrap.
     *   highlight — bool highlight.
     *
     * Does not return a value.
     */
    void View._configure(
            int64 token,
            String font,
            int64 size,
            int64 tabs,
            bool spaces,
                         bool numbers,
            bool wrap,
            bool highlight)
        from "cwhip_gtk_source_view_configure"

    /*
     * Handles whitespace for this View by calling the native function
     * cwhip_gtk_source_view_show_whitespace.
     *
     * Parameters:
     *   token — int64 token.
     *   show — bool show.
     *
     * Does not return a value.
     */
    void View._whitespace(int64 token, bool show) from "cwhip_gtk_source_view_show_whitespace"

    /*
     * Handles line ends for this View by calling the native function
     * cwhip_gtk_source_view_show_line_ends.
     *
     * Parameters:
     *   token — int64 token.
     *   show — bool show.
     *
     * Does not return a value.
     */
    void View._lineEnds(int64 token, bool show) from "cwhip_gtk_source_view_show_line_ends"

    /*
     * Handles indent for this View by calling the native function
     * cwhip_gtk_source_view_show_indent.
     *
     * Parameters:
     *   token — int64 token.
     *   show — bool show.
     *
     * Does not return a value.
     */
    void View._indent(int64 token, bool show) from "cwhip_gtk_source_view_show_indent"

    /*
     * Handles right margin for this View by calling the native function
     * cwhip_gtk_source_view_set_right_margin.
     *
     * Parameters:
     *   token — int64 token.
     *   show — bool show.
     *   column — int64 column.
     *
     * Does not return a value.
     */
    void View._rightMargin(int64 token, bool show, int64 column)
        from "cwhip_gtk_source_view_set_right_margin"

    /*
     * Handles right margin shown for this View by calling the native
     * function cwhip_gtk_source_view_right_margin_shown.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns bool.
     */
    bool View._rightMarginShown(int64 token) from "cwhip_gtk_source_view_right_margin_shown"

    /*
     * Handles right margin column for this View by calling the native
     * function cwhip_gtk_source_view_right_margin_column.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns int64.
     */
    int64 View._rightMarginColumn(int64 token) from "cwhip_gtk_source_view_right_margin_column"

    /*
     * Handles sel start line for this View by calling the native function
     * cwhip_gtk_source_view_selection_start_line.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns int64.
     */
    int64 View._selStartLine(int64 token) from "cwhip_gtk_source_view_selection_start_line"

    /*
     * Handles sel start column for this View by calling the native
     * function cwhip_gtk_source_view_selection_start_column.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns int64.
     */
    int64 View._selStartColumn(int64 token) from "cwhip_gtk_source_view_selection_start_column"

    /*
     * Handles sel end line for this View by calling the native function
     * cwhip_gtk_source_view_selection_end_line.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns int64.
     */
    int64 View._selEndLine(int64 token) from "cwhip_gtk_source_view_selection_end_line"

    /*
     * Handles sel end column for this View by calling the native function
     * cwhip_gtk_source_view_selection_end_column.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Returns int64.
     */
    int64 View._selEndColumn(int64 token) from "cwhip_gtk_source_view_selection_end_column"

    /*
     * Handles begin user action for this View by calling the native
     * function cwhip_gtk_source_view_begin_user_action.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Does not return a value.
     */
    void View._beginUserAction(int64 token) from "cwhip_gtk_source_view_begin_user_action"

    /*
     * Handles end user action for this View by calling the native function
     * cwhip_gtk_source_view_end_user_action.
     *
     * Parameters:
     *   token — int64 token.
     *
     * Does not return a value.
     */
    void View._endUserAction(int64 token) from "cwhip_gtk_source_view_end_user_action"

    /*
     * Handles insert text for this View by calling the native function
     * cwhip_gtk_source_view_insert_text.
     *
     * Parameters:
     *   token — int64 token.
     *   line — int64 line.
     *   column — int64 column.
     *   text — String text.
     *
     * Does not return a value.
     */
    void View._insertText(int64 token, int64 line, int64 column, String text)
        from "cwhip_gtk_source_view_insert_text"

    /*
     * Handles delete range for this View by calling the native function
     * cwhip_gtk_source_view_delete_range.
     *
     * Parameters:
     *   token — int64 token.
     *   startLine — int64 start line.
     *   startColumn — int64 start column.
     *   endLine — int64 end line.
     *   endColumn — int64 end column.
     *
     * Does not return a value.
     */
    void View._deleteRange(
            int64 token,
            int64 startLine,
            int64 startColumn,
            int64 endLine,
                           int64 endColumn) from "cwhip_gtk_source_view_delete_range"

    /*
     * Handles replace range for this View by calling the native function
     * cwhip_gtk_source_view_replace_range.
     *
     * Parameters:
     *   token — int64 token.
     *   startLine — int64 start line.
     *   startColumn — int64 start column.
     *   endLine — int64 end line.
     *   endColumn — int64 end column.
     *   text — String text.
     *
     * Does not return a value.
     */
    void View._replaceRange(
            int64 token,
            int64 startLine,
            int64 startColumn,
            int64 endLine,
                            int64 endColumn,
            String text)
        from "cwhip_gtk_source_view_replace_range"

    /*
     * Handles select range for this View by calling the native function
     * cwhip_gtk_source_view_select_range.
     *
     * Parameters:
     *   token — int64 token.
     *   startLine — int64 start line.
     *   startColumn — int64 start column.
     *   endLine — int64 end line.
     *   endColumn — int64 end column.
     *
     * Does not return a value.
     */
    void View._selectRange(
            int64 token,
            int64 startLine,
            int64 startColumn,
            int64 endLine,
                           int64 endColumn) from "cwhip_gtk_source_view_select_range"

    /*
     * Handles changed for this View by calling the native function
     * cwhip_gtk_source_view_changed.
     *
     * Parameters:
     *   token — int64 token.
     *   action — void<> action.
     *
     * Returns int64.
     */
    int64 View._changed(int64 token, void<> action)
        from "cwhip_gtk_source_view_changed"

    /*
     * Handles cursor moved for this View by calling the native function
     * cwhip_gtk_source_view_cursor_moved.
     *
     * Parameters:
     *   token — int64 token.
     *   action — void<> action.
     *
     * Returns int64.
     */
    int64 View._cursorMoved(int64 token, void<> action)
        from "cwhip_gtk_source_view_cursor_moved"

    /*
     * Handles line selection for this View by calling the native function
     * cwhip_gtk_source_view_line_selection.
     *
     * Parameters:
     *   token — int64 token.
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View._lineSelection(int64 token, bool enabled) from "cwhip_gtk_source_view_line_selection"

    /*
     * Handles line activated for this View by calling the native function
     * cwhip_gtk_source_view_line_activated.
     *
     * Parameters:
     *   token — int64 token.
     *   action — void<int64> action.
     *
     * Returns int64.
     */
    int64 View._lineActivated(int64 token, void<int64> action)
        from "cwhip_gtk_source_view_line_activated"

    /*
     * Handles mark style for this View by calling the native function
     * cwhip_gtk_source_view_mark_style.
     *
     * Parameters:
     *   token — int64 token.
     *   category — String category.
     *   icon — String icon.
     *   color — String color.
     *   lineHighlight — bool line highlight.
     *
     * Does not return a value.
     */
    void View._markStyle(
            int64 token,
            String category,
            String icon,
            String color,
            bool lineHighlight)
        from "cwhip_gtk_source_view_mark_style"

    /*
     * Handles auto indent for this View by calling the native function
     * cwhip_gtk_source_view_auto_indent.
     *
     * Parameters:
     *   token — int64 token.
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View._autoIndent(int64 token, bool enabled) from "cwhip_gtk_source_view_auto_indent"

    /*
     * Handles line mark for this View by calling the native function
     * cwhip_gtk_source_view_line_mark.
     *
     * Parameters:
     *   token — int64 token.
     *   category — String category.
     *   line — int64 line.
     *
     * Does not return a value.
     */
    void View._lineMark(int64 token, String category, int64 line) from "cwhip_gtk_source_view_line_mark"

    /*
     * Handles line mark tooltip for this View by calling the native
     * function cwhip_gtk_source_view_line_mark_tooltip.
     *
     * Parameters:
     *   token — int64 token.
     *   category — String category.
     *   line — int64 line.
     *   tooltip — String tooltip.
     *
     * Does not return a value.
     */
    void View._lineMarkTooltip(
            int64 token,
            String category,
            int64 line,
            String tooltip)
        from "cwhip_gtk_source_view_line_mark_tooltip"

    /*
     * Handles clear marks for this View by calling the native function
     * cwhip_gtk_source_view_clear_marks.
     *
     * Parameters:
     *   token — int64 token.
     *   category — String category.
     *
     * Does not return a value.
     */
    void View._clearMarks(int64 token, String category) from "cwhip_gtk_source_view_clear_marks"

    /*
     * Handles context action for this View by calling the native function
     * cwhip_gtk_source_view_context_action.
     *
     * Parameters:
     *   token — int64 token.
     *   label — String label.
     *   action — void<> action.
     *
     * Does not return a value.
     */
    void View._contextAction(int64 token, String label, void<> action)
        from "cwhip_gtk_source_view_context_action"

    /*
     * Constructs a View and stores _widget.
     *
     * Takes no parameters.
     *
     * Returns the constructed View.
     */
}
