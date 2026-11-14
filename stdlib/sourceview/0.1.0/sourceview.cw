import gtk

namespace GtkSource {
    // Classifies file names and contents for source editing.
    class Content {
        // Registered language id for a file name ("" means plain text).
        public:
        String languageFor(String path)
        // False for data that is not editable text (contains NUL bytes).
        bool isText(String data)
    }

    class View {
        private:
        Gtk.SourceViewWidget _widget
        void _setText(int64 token, String text)
        String _getText(int64 token)
        bool _modified(int64 token)
        void _markSaved(int64 token)
        void _undo(int64 token)
        void _redo(int64 token)
        bool _stripTrailingSpaces(int64 token)
        void _autoPair(int64 token, bool enabled)
        void _selectedLines(int64 token, bool enabled)
        bool _canUndo(int64 token)
        bool _canRedo(int64 token)
        bool _hasSelection(int64 token)
        void _edit(int64 token, int64 operation)
        void _focus(int64 token)
        bool _find(int64 token, String query)
        bool _replaceNext(int64 token, String query, String replacement)
        bool _search(int64 token, String query, int64 options)
        bool _replace(int64 token, String query, String replacement, int64 options)
        int64 _replaceAll(int64 token, String query, String replacement, int64 options)
        bool _captureScope(int64 token)
        bool _hasScope(int64 token)
        String _selectedText(int64 token)
        String _languageId(int64 token)
        int64 _line(int64 token)
        int64 _column(int64 token)
        void _setCursor(int64 token, int64 line, int64 column)
        void _centerCursor(int64 token, int64 line, int64 column)
        void _editable(int64 token, bool editable)
        bool _hasContext(int64 token, String context, int64 offset)
        bool _language(int64 token, String language)
        void _monospace(int64 token, bool monospace)
        void _emojiMenu(int64 token, bool enabled)
        bool _bindShortcut(int64 token, String trigger, void<> action)
        bool _hasShortcut(int64 token, String trigger)
        void _clearShortcuts(int64 token)
        void _configure(int64 token, String font, int64 size, int64 tabs, bool spaces,
                        bool numbers, bool wrap, bool highlight)
        void _whitespace(int64 token, bool show)
        void _lineEnds(int64 token, bool show)
        void _indent(int64 token, bool show)
        void _rightMargin(int64 token, bool show, int64 column)
        bool _rightMarginShown(int64 token)
        int64 _rightMarginColumn(int64 token)
        int64 _selStartLine(int64 token)
        int64 _selStartColumn(int64 token)
        int64 _selEndLine(int64 token)
        int64 _selEndColumn(int64 token)
        void _beginUserAction(int64 token)
        void _endUserAction(int64 token)
        void _insertText(int64 token, int64 line, int64 column, String text)
        void _deleteRange(int64 token, int64 startLine, int64 startColumn, int64 endLine,
                          int64 endColumn)
        void _replaceRange(int64 token, int64 startLine, int64 startColumn, int64 endLine,
                           int64 endColumn, String text)
        void _selectRange(int64 token, int64 startLine, int64 startColumn, int64 endLine,
                          int64 endColumn)
        int64 _changed(int64 token, void<> action)
        int64 _cursorMoved(int64 token, void<> action)
        void _lineSelection(int64 token, bool enabled)
        int64 _lineActivated(int64 token, void<int64> action)
        void _markStyle(int64 token, String category, String icon, String color, bool lineHighlight)
        void _autoIndent(int64 token, bool enabled)
        void _lineMark(int64 token, String category, int64 line)
        void _lineMarkTooltip(int64 token, String category, int64 line, String tooltip)
        void _clearMarks(int64 token, String category)
        void _contextAction(int64 token, String label, void<> action)
        public:
        // Search option bits; add them together to combine options.
        enum { CASE_SENSITIVE = 1, WHOLE_WORDS = 2, IN_SELECTION = 4, BACKWARD = 8 }
        View() {
            _widget = Gtk.SourceViewWidget()
            _language(_widgetToken(), "")
        }
        Gtk.SourceViewWidget widget() { return(_widget)}
        int64 _widgetToken() { return(_widget.nativeToken())}
        void setText(String text) { _setText(_widgetToken(), text) }
        String text() { return(_getText(_widgetToken()))}
        bool modified() { return(_modified(_widgetToken()))}
        void markSaved() { _markSaved(_widgetToken()) }
        void undo() { _undo(_widgetToken()) }
        void redo() { _redo(_widgetToken()) }
        // Removes trailing spaces and tabs as one undo step; true when text changed.
        bool stripTrailingSpaces() { return(_stripTrailingSpaces(_widgetToken()))}
        // Auto-closes ()[]{}"'' pairs, wraps selections, and steps over closers.
        void setAutoCompleteBrackets(bool enabled) { _autoPair(_widgetToken(), enabled) }
        // When enabled, printable typing / Backspace / Delete apply at the
        // selection-start column on each line of a multi-line selection.
        void setSelectedLinesEdit(bool enabled) { _selectedLines(_widgetToken(), enabled) }
        bool canUndo() { return(_canUndo(_widgetToken()))}
        bool canRedo() { return(_canRedo(_widgetToken()))}
        bool hasSelection() { return(_hasSelection(_widgetToken()))}
        void cut() { _edit(_widgetToken(), 0) }
        void copy() { _edit(_widgetToken(), 1) }
        void paste() { _edit(_widgetToken(), 2) }
        void selectAll() { _edit(_widgetToken(), 3) }
        void focus() { _focus(_widgetToken()) }
        void setMonospace(bool monospace) {
            _monospace(_widgetToken(), monospace)
        }
        void setEmojiMenu(bool enabled) { _emojiMenu(_widgetToken(), enabled) }
        bool find(String query) { return(_find(_widgetToken(), query))}
        bool replaceNext(String query, String replacement) {
            return(_replaceNext(_widgetToken(), query, replacement))
        }
        bool findWith(String query, int64 options) {
            return(_search(_widgetToken(), query, options))
        }
        bool replaceWith(String query, String replacement, int64 options) {
            return(_replace(_widgetToken(), query, replacement, options))
        }
        int64 replaceAll(String query, String replacement, int64 options) {
            return(_replaceAll(_widgetToken(), query, replacement, options))
        }
        bool captureSearchScope() { return(_captureScope(_widgetToken()))}
        bool hasSearchScope() { return(_hasScope(_widgetToken()))}
        String selectedText() { return(_selectedText(_widgetToken()))}
        bool setLanguage(String language) { return(_language(_widgetToken(), language))}
        String language() { return(_languageId(_widgetToken()))}
        int64 line() { return(_line(_widgetToken()))}
        int64 column() { return(_column(_widgetToken()))}
        void setCursor(int64 line, int64 column) { _setCursor(_widgetToken(), line, column) }
        void centerCursor(int64 line, int64 column) { _centerCursor(_widgetToken(), line, column) }
        void setEditable(bool editable) { _editable(_widgetToken(), editable) }
        bool hasContextAt(String context, int64 offset) {
            return(_hasContext(_widgetToken(), context, offset))
        }
        bool bindShortcut(String trigger, void<> action) {
            return(_bindShortcut(_widgetToken(), trigger, action))
        }
        bool hasShortcut(String trigger) { return(_hasShortcut(_widgetToken(), trigger))}
        void clearShortcuts() { _clearShortcuts(_widgetToken()) }
        void configure(String font, int64 size, int64 tabs, bool spaces,
                       bool numbers, bool wrap, bool highlight) {
            _configure(_widgetToken(), font, size, tabs, spaces, numbers, wrap, highlight)
        }
        void setShowWhitespace(bool show) { _whitespace(_widgetToken(), show) }
        void setShowLineEnds(bool show) { _lineEnds(_widgetToken(), show) }
        void setShowIndentMarkers(bool show) { _indent(_widgetToken(), show) }
        // Column is clamped to 1-512. show=false hides the margin without changing
        // the remembered column.
        void setRightMargin(bool show, int64 column) {
            _rightMargin(_widgetToken(), show, column)
        }
        bool rightMarginShown() { return(_rightMarginShown(_widgetToken()))}
        int64 rightMarginColumn() { return(_rightMarginColumn(_widgetToken()))}
        // Empty selection reports the insertion cursor for both edges.
        int64 selectionStartLine() { return(_selStartLine(_widgetToken()))}
        int64 selectionStartColumn() { return(_selStartColumn(_widgetToken()))}
        int64 selectionEndLine() { return(_selEndLine(_widgetToken()))}
        int64 selectionEndColumn() { return(_selEndColumn(_widgetToken()))}
        void beginUserAction() { _beginUserAction(_widgetToken()) }
        void endUserAction() { _endUserAction(_widgetToken()) }
        void insertText(int64 line, int64 column, String text) {
            _insertText(_widgetToken(), line, column, text)
        }
        void deleteRange(int64 startLine, int64 startColumn, int64 endLine, int64 endColumn) {
            _deleteRange(_widgetToken(), startLine, startColumn, endLine, endColumn)
        }
        // One undo group: delete then insert at the start edge.
        void replaceRange(int64 startLine, int64 startColumn, int64 endLine, int64 endColumn,
                          String text) {
            _replaceRange(_widgetToken(), startLine, startColumn, endLine, endColumn, text)
        }
        void selectRange(int64 startLine, int64 startColumn, int64 endLine, int64 endColumn) {
            _selectRange(_widgetToken(), startLine, startColumn, endLine, endColumn)
        }
        int64 onChanged(void<> action) {
            return(_changed(_widgetToken(), action))
        }
        int64 onCursorMoved(void<> action) {
            return(_cursorMoved(_widgetToken(), action))
        }
        void setLineSelection(bool enabled) { _lineSelection(_widgetToken(), enabled) }
        int64 onLineActivated(void<int64> action) { return(_lineActivated(_widgetToken(), action))}
        // lineHighlight applies underline + paragraph tint; false is gutter icon only.
        void setMarkStyle(String category, String icon, String background) {
            _markStyle(_widgetToken(), category, icon, background, true)
        }
        void setMarkStyle(String category, String icon, String background, bool lineHighlight) {
            _markStyle(_widgetToken(), category, icon, background, lineHighlight)
        }
        void setAutoIndent(bool enabled) { _autoIndent(_widgetToken(), enabled) }
        void addLineMark(String category, int64 line) { _lineMark(_widgetToken(), category, line) }
        void addLineMarkTooltip(String category, int64 line, String tooltip) {
            _lineMarkTooltip(_widgetToken(), category, line, tooltip)
        }
        void clearLineMarks(String category) { _clearMarks(_widgetToken(), category) }
        // Appends to the native right-click menu; does not replace Cut/Copy/Paste.
        void addContextAction(String label, void<> action) {
            _contextAction(_widgetToken(), label, action)
        }
    }

    void View._setText(int64 token, String text) from "cwhip_gtk_source_view_set_text"
    String View._getText(int64 token) from "cwhip_gtk_source_view_get_text"
    bool View._modified(int64 token) from "cwhip_gtk_source_view_modified"
    void View._markSaved(int64 token) from "cwhip_gtk_source_view_mark_saved"
    void View._undo(int64 token) from "cwhip_gtk_source_view_undo"
    void View._redo(int64 token) from "cwhip_gtk_source_view_redo"
    bool View._stripTrailingSpaces(int64 token) from "cwhip_gtk_source_view_strip_trailing_spaces"
    void View._autoPair(int64 token, bool enabled) from "cwhip_gtk_source_view_auto_pair"
    void View._selectedLines(int64 token, bool enabled)
        from "cwhip_gtk_source_view_selected_lines_edit"
    bool View._canUndo(int64 token) from "cwhip_gtk_source_view_can_undo"
    bool View._canRedo(int64 token) from "cwhip_gtk_source_view_can_redo"
    bool View._hasSelection(int64 token) from "cwhip_gtk_source_view_has_selection"
    void View._edit(int64 token, int64 operation) from "cwhip_gtk_source_view_edit"
    void View._focus(int64 token) from "cwhip_gtk_widget_focus"
    bool View._find(int64 token, String query) from "cwhip_gtk_source_view_find"
    bool View._replaceNext(int64 token, String query, String replacement)
        from "cwhip_gtk_source_view_replace_next"
    int64 View._line(int64 token) from "cwhip_gtk_source_view_line"
    int64 View._column(int64 token) from "cwhip_gtk_source_view_column"
    void View._setCursor(int64 token, int64 line, int64 column) from "cwhip_gtk_source_view_set_cursor"
    void View._centerCursor(int64 token, int64 line, int64 column) from "cwhip_gtk_source_view_center_cursor"
    void View._editable(int64 token, bool editable) from "cwhip_gtk_source_view_editable"
    bool View._hasContext(int64 token, String context, int64 offset)
        from "cwhip_gtk_source_view_has_context"
    bool View._language(int64 token, String language) from "cwhip_gtk_source_view_language"
    void View._monospace(int64 token, bool monospace)
        from "cwhip_gtk_source_view_monospace"
    void View._emojiMenu(int64 token, bool enabled) from "cwhip_gtk_source_view_emoji_menu"
    String View._languageId(int64 token) from "cwhip_gtk_source_view_language_id"
    bool View._search(int64 token, String query, int64 options) from "cwhip_gtk_source_view_search"
    bool View._replace(int64 token, String query, String replacement, int64 options)
        from "cwhip_gtk_source_view_replace"
    int64 View._replaceAll(int64 token, String query, String replacement, int64 options)
        from "cwhip_gtk_source_view_replace_all"
    bool View._captureScope(int64 token) from "cwhip_gtk_source_view_capture_scope"
    bool View._hasScope(int64 token) from "cwhip_gtk_source_view_has_scope"
    String View._selectedText(int64 token) from "cwhip_gtk_source_view_selected_text"
    String Content.languageFor(String path) from "cwhip_gtk_source_language_for"
    bool Content.isText(String data) from "cwhip_gtk_source_is_text"
    bool View._bindShortcut(int64 token, String trigger, void<> action)
        from "cwhip_gtk_source_view_bind_shortcut"
    bool View._hasShortcut(int64 token, String trigger)
        from "cwhip_gtk_source_view_has_shortcut"
    void View._clearShortcuts(int64 token) from "cwhip_gtk_source_view_clear_shortcuts"
    void View._configure(int64 token, String font, int64 size, int64 tabs, bool spaces,
                         bool numbers, bool wrap, bool highlight)
        from "cwhip_gtk_source_view_configure"
    void View._whitespace(int64 token, bool show) from "cwhip_gtk_source_view_show_whitespace"
    void View._lineEnds(int64 token, bool show) from "cwhip_gtk_source_view_show_line_ends"
    void View._indent(int64 token, bool show) from "cwhip_gtk_source_view_show_indent"
    void View._rightMargin(int64 token, bool show, int64 column)
        from "cwhip_gtk_source_view_set_right_margin"
    bool View._rightMarginShown(int64 token) from "cwhip_gtk_source_view_right_margin_shown"
    int64 View._rightMarginColumn(int64 token) from "cwhip_gtk_source_view_right_margin_column"
    int64 View._selStartLine(int64 token) from "cwhip_gtk_source_view_selection_start_line"
    int64 View._selStartColumn(int64 token) from "cwhip_gtk_source_view_selection_start_column"
    int64 View._selEndLine(int64 token) from "cwhip_gtk_source_view_selection_end_line"
    int64 View._selEndColumn(int64 token) from "cwhip_gtk_source_view_selection_end_column"
    void View._beginUserAction(int64 token) from "cwhip_gtk_source_view_begin_user_action"
    void View._endUserAction(int64 token) from "cwhip_gtk_source_view_end_user_action"
    void View._insertText(int64 token, int64 line, int64 column, String text)
        from "cwhip_gtk_source_view_insert_text"
    void View._deleteRange(int64 token, int64 startLine, int64 startColumn, int64 endLine,
                           int64 endColumn) from "cwhip_gtk_source_view_delete_range"
    void View._replaceRange(int64 token, int64 startLine, int64 startColumn, int64 endLine,
                            int64 endColumn, String text)
        from "cwhip_gtk_source_view_replace_range"
    void View._selectRange(int64 token, int64 startLine, int64 startColumn, int64 endLine,
                           int64 endColumn) from "cwhip_gtk_source_view_select_range"
    int64 View._changed(int64 token, void<> action)
        from "cwhip_gtk_source_view_changed"
    int64 View._cursorMoved(int64 token, void<> action)
        from "cwhip_gtk_source_view_cursor_moved"
    void View._lineSelection(int64 token, bool enabled) from "cwhip_gtk_source_view_line_selection"
    int64 View._lineActivated(int64 token, void<int64> action)
        from "cwhip_gtk_source_view_line_activated"
    void View._markStyle(int64 token, String category, String icon, String color, bool lineHighlight)
        from "cwhip_gtk_source_view_mark_style"
    void View._autoIndent(int64 token, bool enabled) from "cwhip_gtk_source_view_auto_indent"
    void View._lineMark(int64 token, String category, int64 line) from "cwhip_gtk_source_view_line_mark"
    void View._lineMarkTooltip(int64 token, String category, int64 line, String tooltip)
        from "cwhip_gtk_source_view_line_mark_tooltip"
    void View._clearMarks(int64 token, String category) from "cwhip_gtk_source_view_clear_marks"
    void View._contextAction(int64 token, String label, void<> action)
        from "cwhip_gtk_source_view_context_action"
}
