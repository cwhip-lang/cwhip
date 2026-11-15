/*
 * stdlib/gtk/0.1.0/source_view_widget.cw
 *
 * Gtk.SourceViewWidget from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * SourceViewWidget is a class derived from Widget in this standard-library
     * package.
     *
     * Its methods include constructor, nativeToken.
     */
    class SourceViewWidget : Widget {
        public:
        /*
         * Constructs a SourceViewWidget.
         *
         * Takes no parameters.
         *
         * Returns the constructed SourceViewWidget.
         */
        SourceViewWidget() {
            super Widget(8, "", 0, 0)
        }

        /*
         * Returns _widgetToken().
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 nativeToken() {
            return(_widgetToken())
        }
    }
}
