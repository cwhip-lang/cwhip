/*
 * stdlib/sourceview/0.1.0/view_methods.cw
 *
 * Out-of-line GtkSource.View methods.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace GtkSource {
    /*
     * Constructs a View and stores an empty source widget.
     *
     * Takes no parameters.
     *
     * Returns the constructed View.
     */
    View View.View() {
        _widget = Gtk.SourceViewWidget()
        _language(_widgetToken(), "")
    }

    /*
     * Returns _widget.nativeToken().
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 View._widgetToken() {
        return(_widget.nativeToken())
    }

    /*
     * Sets text for this View.
     *
     * Parameters:
     *   text — String text.
     *
     * Does not return a value.
     */
    void View.setText(String text) {
        _setText(_widgetToken(), text)
    }

    /*
     * Returns _getText(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns String.
     */
    String View.text() {
        return(_getText(_widgetToken()))
    }

    /*
     * Returns _modified(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool View.modified() {
        return(_modified(_widgetToken()))
    }

    /*
     * Handles mark saved for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.markSaved() {
        _markSaved(_widgetToken())
    }

    /*
     * Handles undo for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.undo() {
        _undo(_widgetToken())
    }

    /*
     * Handles redo for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.redo() {
        _redo(_widgetToken())
    }

    /*
     * Removes trailing spaces and tabs as one undo step; true when text
     * changed.
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool View.stripTrailingSpaces() {
        return(_stripTrailingSpaces(_widgetToken()))
    }

    /*
     * Auto-closes ()[]{}"'' pairs, wraps selections, and steps over
     * closers.
     *
     * Parameters:
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View.setAutoCompleteBrackets(bool enabled) {
        _autoPair(_widgetToken(), enabled)
    }

    /*
     * When enabled, printable typing / Backspace / Delete apply at the
     * selection-start column on each line of a multi-line selection.
     *
     * Parameters:
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View.setSelectedLinesEdit(bool enabled) {
        _selectedLines(_widgetToken(), enabled)
    }

    /*
     * Returns _canUndo(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool View.canUndo() {
        return(_canUndo(_widgetToken()))
    }

    /*
     * Returns _canRedo(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool View.canRedo() {
        return(_canRedo(_widgetToken()))
    }

    /*
     * Returns _hasSelection(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool View.hasSelection() {
        return(_hasSelection(_widgetToken()))
    }

    /*
     * Handles cut for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.cut() {
        _edit(_widgetToken(), 0)
    }

    /*
     * Handles copy for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.copy() {
        _edit(_widgetToken(), 1)
    }

    /*
     * Handles paste for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.paste() {
        _edit(_widgetToken(), 2)
    }

    /*
     * Handles select all for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.selectAll() {
        _edit(_widgetToken(), 3)
    }

    /*
     * Handles focus for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.focus() {
        _focus(_widgetToken())
    }

    /*
     * Sets monospace for this View.
     *
     * Parameters:
     *   monospace — bool monospace.
     *
     * Does not return a value.
     */
    void View.setMonospace(bool monospace) {
        _monospace(_widgetToken(), monospace)
    }

    /*
     * Sets emoji menu for this View.
     *
     * Parameters:
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View.setEmojiMenu(bool enabled) {
        _emojiMenu(_widgetToken(), enabled)
    }

    /*
     * Returns _find(_widgetToken(), query).
     *
     * Parameters:
     *   query — String query.
     *
     * Returns bool.
     */
    bool View.find(String query) {
        return(_find(_widgetToken(), query))
    }

    /*
     * Returns _replaceNext(_widgetToken(), query, replacement).
     *
     * Parameters:
     *   query — String query.
     *   replacement — String replacement.
     *
     * Returns bool.
     */
    bool View.replaceNext(String query, String replacement) {
        return(_replaceNext(_widgetToken(), query, replacement))
    }

    /*
     * Returns _search(_widgetToken(), query, options).
     *
     * Parameters:
     *   query — String query.
     *   options — int64 options.
     *
     * Returns bool.
     */
    bool View.findWith(String query, int64 options) {
        return(_search(_widgetToken(), query, options))
    }

    /*
     * Returns _replace(_widgetToken(), query, replacement, options).
     *
     * Parameters:
     *   query — String query.
     *   replacement — String replacement.
     *   options — int64 options.
     *
     * Returns bool.
     */
    bool View.replaceWith(String query, String replacement, int64 options) {
        return(_replace(_widgetToken(), query, replacement, options))
    }

    /*
     * Returns _replaceAll(_widgetToken(), query, replacement, options).
     *
     * Parameters:
     *   query — String query.
     *   replacement — String replacement.
     *   options — int64 options.
     *
     * Returns int64.
     */
    int64 View.replaceAll(String query, String replacement, int64 options) {
        return(_replaceAll(_widgetToken(), query, replacement, options))
    }

    /*
     * Returns _captureScope(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool View.captureSearchScope() {
        return(_captureScope(_widgetToken()))
    }

    /*
     * Returns _hasScope(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool View.hasSearchScope() {
        return(_hasScope(_widgetToken()))
    }

    /*
     * Returns _selectedText(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns String.
     */
    String View.selectedText() {
        return(_selectedText(_widgetToken()))
    }

    /*
     * Returns _language(_widgetToken(), language).
     *
     * Parameters:
     *   language — String language.
     *
     * Returns bool.
     */
    bool View.setLanguage(String language) {
        return(_language(_widgetToken(), language))
    }

    /*
     * Returns _languageId(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns String.
     */
    String View.language() {
        return(_languageId(_widgetToken()))
    }

    /*
     * Returns _line(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 View.line() {
        return(_line(_widgetToken()))
    }

    /*
     * Returns _column(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 View.column() {
        return(_column(_widgetToken()))
    }

    /*
     * Sets cursor for this View.
     *
     * Parameters:
     *   line — int64 line.
     *   column — int64 column.
     *
     * Does not return a value.
     */
    void View.setCursor(int64 line, int64 column) {
        _setCursor(_widgetToken(), line, column)
    }

    /*
     * Handles center cursor for this View.
     *
     * Parameters:
     *   line — int64 line.
     *   column — int64 column.
     *
     * Does not return a value.
     */
    void View.centerCursor(int64 line, int64 column) {
        _centerCursor(_widgetToken(), line, column)
    }

    /*
     * Sets editable for this View.
     *
     * Parameters:
     *   editable — bool editable.
     *
     * Does not return a value.
     */
    void View.setEditable(bool editable) {
        _editable(_widgetToken(), editable)
    }

    /*
     * Returns _hasContext(_widgetToken(), context, offset).
     *
     * Parameters:
     *   context — String context.
     *   offset — int64 offset.
     *
     * Returns bool.
     */
    bool View.hasContextAt(String context, int64 offset) {
        return(_hasContext(_widgetToken(), context, offset))
    }

    /*
     * Returns _bindShortcut(_widgetToken(), trigger, action).
     *
     * Parameters:
     *   trigger — String trigger.
     *   action — void<> action.
     *
     * Returns bool.
     */
    bool View.bindShortcut(String trigger, void<> action) {
        return(_bindShortcut(_widgetToken(), trigger, action))
    }

    /*
     * Returns _hasShortcut(_widgetToken(), trigger).
     *
     * Parameters:
     *   trigger — String trigger.
     *
     * Returns bool.
     */
    bool View.hasShortcut(String trigger) {
        return(_hasShortcut(_widgetToken(), trigger))
    }

    /*
     * Clears shortcuts for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.clearShortcuts() {
        _clearShortcuts(_widgetToken())
    }

    /*
     * Handles configure for this View.
     *
     * Parameters:
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
    void View.configure(
            String font,
            int64 size,
            int64 tabs,
            bool spaces,
            bool numbers,
            bool wrap,
            bool highlight) {
        _configure(
                    _widgetToken(),
                    font,
                    size,
                    tabs,
                    spaces,
                    numbers,
                    wrap,
                    highlight)
    }

    /*
     * Sets show whitespace for this View.
     *
     * Parameters:
     *   show — bool show.
     *
     * Does not return a value.
     */
    void View.setShowWhitespace(bool show) {
        _whitespace(_widgetToken(), show)
    }

    /*
     * Sets show line ends for this View.
     *
     * Parameters:
     *   show — bool show.
     *
     * Does not return a value.
     */
    void View.setShowLineEnds(bool show) {
        _lineEnds(_widgetToken(), show)
    }

    /*
     * Sets show indent markers for this View.
     *
     * Parameters:
     *   show — bool show.
     *
     * Does not return a value.
     */
    void View.setShowIndentMarkers(bool show) {
        _indent(_widgetToken(), show)
    }

    /*
     * Column is clamped to 1-512. show=false hides the margin without
     * changing the remembered column.
     *
     * Parameters:
     *   show — bool show.
     *   column — int64 column.
     *
     * Does not return a value.
     */
    void View.setRightMargin(bool show, int64 column) {
        _rightMargin(_widgetToken(), show, column)
    }

    /*
     * Returns _rightMarginShown(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns bool.
     */
    bool View.rightMarginShown() {
        return(_rightMarginShown(_widgetToken()))
    }

    /*
     * Returns _rightMarginColumn(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 View.rightMarginColumn() {
        return(_rightMarginColumn(_widgetToken()))
    }

    /*
     * Empty selection reports the insertion cursor for both edges.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 View.selectionStartLine() {
        return(_selStartLine(_widgetToken()))
    }

    /*
     * Returns _selStartColumn(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 View.selectionStartColumn() {
        return(_selStartColumn(_widgetToken()))
    }

    /*
     * Returns _selEndLine(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 View.selectionEndLine() {
        return(_selEndLine(_widgetToken()))
    }

    /*
     * Returns _selEndColumn(_widgetToken()).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 View.selectionEndColumn() {
        return(_selEndColumn(_widgetToken()))
    }

    /*
     * Handles begin user action for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.beginUserAction() {
        _beginUserAction(_widgetToken())
    }

    /*
     * Handles end user action for this View.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void View.endUserAction() {
        _endUserAction(_widgetToken())
    }

    /*
     * Handles insert text for this View.
     *
     * Parameters:
     *   line — int64 line.
     *   column — int64 column.
     *   text — String text.
     *
     * Does not return a value.
     */
    void View.insertText(int64 line, int64 column, String text) {
        _insertText(_widgetToken(), line, column, text)
    }

    /*
     * Handles delete range for this View.
     *
     * Parameters:
     *   startLine — int64 start line.
     *   startColumn — int64 start column.
     *   endLine — int64 end line.
     *   endColumn — int64 end column.
     *
     * Does not return a value.
     */
    void View.deleteRange(
            int64 startLine,
            int64 startColumn,
            int64 endLine,
            int64 endColumn) {
        _deleteRange(
                    _widgetToken(),
                    startLine,
                    startColumn,
                    endLine,
                    endColumn)
    }

    /*
     * One undo group: delete then insert at the start edge.
     *
     * Parameters:
     *   startLine — int64 start line.
     *   startColumn — int64 start column.
     *   endLine — int64 end line.
     *   endColumn — int64 end column.
     *   text — String text.
     *
     * Does not return a value.
     */
    void View.replaceRange(
            int64 startLine,
            int64 startColumn,
            int64 endLine,
            int64 endColumn,
            String text) {
        _replaceRange(
                    _widgetToken(),
                    startLine,
                    startColumn,
                    endLine,
                    endColumn,
                    text)
    }

    /*
     * Handles select range for this View.
     *
     * Parameters:
     *   startLine — int64 start line.
     *   startColumn — int64 start column.
     *   endLine — int64 end line.
     *   endColumn — int64 end column.
     *
     * Does not return a value.
     */
    void View.selectRange(
            int64 startLine,
            int64 startColumn,
            int64 endLine,
            int64 endColumn) {
        _selectRange(
                    _widgetToken(),
                    startLine,
                    startColumn,
                    endLine,
                    endColumn)
    }

    /*
     * Returns _changed(_widgetToken(), action).
     *
     * Parameters:
     *   action — void<> action.
     *
     * Returns int64.
     */
    int64 View.onChanged(void<> action) {
        return(_changed(_widgetToken(), action))
    }

    /*
     * Returns _cursorMoved(_widgetToken(), action).
     *
     * Parameters:
     *   action — void<> action.
     *
     * Returns int64.
     */
    int64 View.onCursorMoved(void<> action) {
        return(_cursorMoved(_widgetToken(), action))
    }

    /*
     * Sets line selection for this View.
     *
     * Parameters:
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View.setLineSelection(bool enabled) {
        _lineSelection(_widgetToken(), enabled)
    }

    /*
     * Returns _lineActivated(_widgetToken(), action).
     *
     * Parameters:
     *   action — void<int64> action.
     *
     * Returns int64.
     */
    int64 View.onLineActivated(void<int64> action) {
        return(_lineActivated(_widgetToken(), action))
    }

    /*
     * lineHighlight applies underline + paragraph tint; false is gutter
     * icon only.
     *
     * Parameters:
     *   category — String category.
     *   icon — String icon.
     *   background — String background.
     *
     * Does not return a value.
     */
    void View.setMarkStyle(String category, String icon, String background) {
        _markStyle(_widgetToken(), category, icon, background, true)
    }

    /*
     * Sets mark style for this View.
     *
     * Parameters:
     *   category — String category.
     *   icon — String icon.
     *   background — String background.
     *   lineHighlight — bool line highlight.
     *
     * Does not return a value.
     */
    void View.setMarkStyle(
            String category,
            String icon,
            String background,
            bool lineHighlight) {
        _markStyle(
                    _widgetToken(),
                    category,
                    icon,
                    background,
                    lineHighlight)
    }

    /*
     * Sets auto indent for this View.
     *
     * Parameters:
     *   enabled — bool enabled.
     *
     * Does not return a value.
     */
    void View.setAutoIndent(bool enabled) {
        _autoIndent(_widgetToken(), enabled)
    }

    /*
     * Adds line mark for this View.
     *
     * Parameters:
     *   category — String category.
     *   line — int64 line.
     *
     * Does not return a value.
     */
    void View.addLineMark(String category, int64 line) {
        _lineMark(_widgetToken(), category, line)
    }

    /*
     * Adds line mark tooltip for this View.
     *
     * Parameters:
     *   category — String category.
     *   line — int64 line.
     *   tooltip — String tooltip.
     *
     * Does not return a value.
     */
    void View.addLineMarkTooltip(String category, int64 line, String tooltip) {
        _lineMarkTooltip(_widgetToken(), category, line, tooltip)
    }

    /*
     * Clears line marks for this View.
     *
     * Parameters:
     *   category — String category.
     *
     * Does not return a value.
     */
    void View.clearLineMarks(String category) {
        _clearMarks(_widgetToken(), category)
    }

    /*
     * Appends to the native right-click menu; does not replace
     * Cut/Copy/Paste.
     *
     * Parameters:
     *   label — String label.
     *   action — void<> action.
     *
     * Does not return a value.
     */
    void View.addContextAction(String label, void<> action) {
        _contextAction(_widgetToken(), label, action)
    }
}
