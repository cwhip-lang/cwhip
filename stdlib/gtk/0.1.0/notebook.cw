/*
 * stdlib/gtk/0.1.0/notebook.cw — Gtk.Notebook from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Notebook is a class derived from Widget in this standard-library
     * package.
     *
     * Its methods include _notebookSelf, _closable, _bordered, _scrollable,
     * constructor, appendPage, and 9 more.
     */
    class Notebook : Widget {
        private:
        /*
         * Handles notebook self for this Notebook by calling the native
         * function cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns Notebook.
         */
        Notebook _notebookSelf()

        /*
         * Handles closable for this Notebook by calling the native function
         * cwhip_gtk_notebook_closable.
         *
         * Parameters:
         *   token — int64 token.
         *   child — int64 child.
         *   title — String title.
         *   close — void<> close.
         *
         * Does not return a value.
         */
        void _closable(int64 token, int64 child, String title, void<> close)

        /*
         * Handles bordered for this Notebook by calling the native function
         * cwhip_gtk_notebook_bordered.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _bordered(int64 token)

        /*
         * Handles scrollable for this Notebook by calling the native function
         * cwhip_gtk_notebook_scrollable.
         *
         * Parameters:
         *   token — int64 token.
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void _scrollable(int64 token, bool enabled)
        public:
        /*
         * Constructs a Notebook.
         *
         * Takes no parameters.
         *
         * Returns the constructed Notebook.
         */
        Notebook() {
            super Widget(9, "", 0, 0)
        }

        /*
         * Appends page for this Notebook.
         *
         * Parameters:
         *   child — Widget child.
         *   title — String title.
         *
         * Does not return a value.
         */
        void appendPage(Widget child, String title) {
            _notebookAppend(_widgetToken(), child._widgetToken(), title)
        }

        /*
         * Appends closable page for this Notebook.
         *
         * Parameters:
         *   child — Widget child.
         *   title — String title.
         *   close — void<> close.
         *
         * Does not return a value.
         */
        void appendClosablePage(Widget child, String title, void<> close) {
            _closable(_widgetToken(), child._widgetToken(), title, close)
        }

        /*
         * Draws a border around every tab label, as closable pages already do.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void setBorderedTabs() {
            _bordered(_widgetToken())
        }

        /*
         * Sets scrollable for this Notebook.
         *
         * Parameters:
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void setScrollable(bool enabled) {
            _scrollable(_widgetToken(), enabled)
        }

        /*
         * Returns _notebookCurrent(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 currentPage() {
            return(_notebookCurrent(_widgetToken()))
        }

        /*
         * Sets current page for this Notebook.
         *
         * Parameters:
         *   page — int64 page.
         *
         * Does not return a value.
         */
        void setCurrentPage(int64 page) {
            _notebookSetCurrent(_widgetToken(), page)
        }

        /*
         * Returns _notebookCount(_widgetToken()).
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 pageCount() {
            return(_notebookCount(_widgetToken()))
        }

        /*
         * Sets page title for this Notebook.
         *
         * Parameters:
         *   page — int64 page.
         *   title — String title.
         *
         * Does not return a value.
         */
        void setPageTitle(int64 page, String title) {
            _notebookTitle(_widgetToken(), page, title)
        }

        /*
         * Removes the Notebook state.
         *
         * Parameters:
         *   child — Widget child.
         *
         * Does not return a value.
         */
        void remove(Widget child) {
            _removeChild(child)
        }

        /*
         * Returns SignalConnection(_notebookSelf(), action).
         *
         * Parameters:
         *   action — void<> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onPageChanged(void<> action) {
            return(SignalConnection(_notebookSelf(), action))
        }
    }
}
