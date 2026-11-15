/*
 * stdlib/sourceview/0.1.0/view.cw
 *
 * GtkSource.View from the sourceview package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace GtkSource {
    /*
     * View is a class in this standard-library package.
     *
     * Its methods include _setText, _getText, _modified, _markSaved, _undo,
     * _redo, and 123 more.
     */
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

        bool _replace(
                int64 token,
                String query,
                String replacement,
                int64 options)

        int64 _replaceAll(
                int64 token,
                String query,
                String replacement,
                int64 options)

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

        void _configure(
                int64 token,
                String font,
                int64 size,
                int64 tabs,
                bool spaces,
                        bool numbers,
                bool wrap,
                bool highlight)

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

        void _deleteRange(
                int64 token,
                int64 startLine,
                int64 startColumn,
                int64 endLine,
                          int64 endColumn)

        void _replaceRange(
                int64 token,
                int64 startLine,
                int64 startColumn,
                int64 endLine,
                           int64 endColumn,
                String text)

        void _selectRange(
                int64 token,
                int64 startLine,
                int64 startColumn,
                int64 endLine,
                          int64 endColumn)

        int64 _changed(int64 token, void<> action)

        int64 _cursorMoved(int64 token, void<> action)

        void _lineSelection(int64 token, bool enabled)

        int64 _lineActivated(int64 token, void<int64> action)

        void _markStyle(
                int64 token,
                String category,
                String icon,
                String color,
                bool lineHighlight)

        void _autoIndent(int64 token, bool enabled)

        void _lineMark(int64 token, String category, int64 line)

        void _lineMarkTooltip(
                int64 token,
                String category,
                int64 line,
                String tooltip)

        void _clearMarks(int64 token, String category)

        void _contextAction(int64 token, String label, void<> action)
        public:
        // Search option bits; add them together to combine options.
        enum {
            CASE_SENSITIVE = 1, WHOLE_WORDS = 2, IN_SELECTION = 4, BACKWARD = 8
        }

        View()

        /*
         * Returns the source widget this view draws.
         *
         * Takes no parameters.
         *
         * Returns Gtk.SourceViewWidget.
         */
        Gtk.SourceViewWidget widget() {
            return(_widget)
        }

        int64 _widgetToken()

        void setText(String text)

        String text()

        bool modified()

        void markSaved()

        void undo()

        void redo()

        bool stripTrailingSpaces()

        void setAutoCompleteBrackets(bool enabled)

        void setSelectedLinesEdit(bool enabled)

        bool canUndo()

        bool canRedo()

        bool hasSelection()

        void cut()

        void copy()

        void paste()

        void selectAll()

        void focus()

        void setMonospace(bool monospace)

        void setEmojiMenu(bool enabled)

        bool find(String query)

        bool replaceNext(String query, String replacement)

        bool findWith(String query, int64 options)

        bool replaceWith(String query, String replacement, int64 options)

        int64 replaceAll(String query, String replacement, int64 options)

        bool captureSearchScope()

        bool hasSearchScope()

        String selectedText()

        bool setLanguage(String language)

        String language()

        int64 line()

        int64 column()

        void setCursor(int64 line, int64 column)

        void centerCursor(int64 line, int64 column)

        void setEditable(bool editable)

        bool hasContextAt(String context, int64 offset)

        bool bindShortcut(String trigger, void<> action)

        bool hasShortcut(String trigger)

        void clearShortcuts()

        void configure(
                String font,
                int64 size,
                int64 tabs,
                bool spaces,
                       bool numbers,
                bool wrap,
                bool highlight)

        void setShowWhitespace(bool show)

        void setShowLineEnds(bool show)

        void setShowIndentMarkers(bool show)

        void setRightMargin(bool show, int64 column)

        bool rightMarginShown()

        int64 rightMarginColumn()

        int64 selectionStartLine()

        int64 selectionStartColumn()

        int64 selectionEndLine()

        int64 selectionEndColumn()

        void beginUserAction()

        void endUserAction()

        void insertText(int64 line, int64 column, String text)

        void deleteRange(
                int64 startLine,
                int64 startColumn,
                int64 endLine,
                int64 endColumn)

        void replaceRange(
                int64 startLine,
                int64 startColumn,
                int64 endLine,
                int64 endColumn,
                          String text)

        void selectRange(
                int64 startLine,
                int64 startColumn,
                int64 endLine,
                int64 endColumn)

        int64 onChanged(void<> action)

        int64 onCursorMoved(void<> action)

        void setLineSelection(bool enabled)

        int64 onLineActivated(void<int64> action)

        void setMarkStyle(String category, String icon, String background)

        void setMarkStyle(
                String category,
                String icon,
                String background,
                bool lineHighlight)

        void setAutoIndent(bool enabled)

        void addLineMark(String category, int64 line)

        void addLineMarkTooltip(String category, int64 line, String tooltip)

        void clearLineMarks(String category)

        void addContextAction(String label, void<> action)
    }
}
