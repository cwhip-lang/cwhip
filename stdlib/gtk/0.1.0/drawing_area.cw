/*
 * stdlib/gtk/0.1.0/drawing_area.cw — Gtk.DrawingArea from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * DrawingArea is a class derived from Widget in this standard-library
     * package.
     *
     * Custom paint surface embeddable as a normal child of Box, Paned,
     * Notebook, ScrolledWindow, Grid, or Window. Paint helpers are valid only
     * inside the onDraw callback. For view chrome: wrap with ScrolledWindow
     * after setContentSize, and/or drive Scrollbar widgets from pan/zoom
     * extents; attach ContextMenu(area) and rebuild items in onPopup.
     */
    class DrawingArea : Widget {
        private:
        /*
         * Handles draw self for this DrawingArea by calling the native
         * function cwhip_gtk_self.
         *
         * Takes no parameters.
         *
         * Returns DrawingArea.
         */
        DrawingArea _drawSelf()

        /*
         * Handles queue draw for this DrawingArea by calling the native
         * function cwhip_gtk_drawing_area_queue_draw.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _queueDraw(int64 token)

        /*
         * Handles content size for this DrawingArea by calling the native
         * function cwhip_gtk_drawing_area_set_content_size.
         *
         * Parameters:
         *   token — int64 token.
         *   width — int64 width.
         *   height — int64 height.
         *
         * Does not return a value.
         */
        void _contentSize(int64 token, int64 width, int64 height)

        /*
         * Handles color for this DrawingArea by calling the native function
         * cwhip_gtk_drawing_area_set_color.
         *
         * Parameters:
         *   token — int64 token.
         *   r — fp64 input value.
         *   g — fp64 input value.
         *   b — fp64 input value.
         *   a — fp64 input value.
         *
         * Does not return a value.
         */
        void _color(int64 token, fp64 r, fp64 g, fp64 b, fp64 a)

        /*
         * Handles line width for this DrawingArea by calling the native
         * function cwhip_gtk_drawing_area_set_line_width.
         *
         * Parameters:
         *   token — int64 token.
         *   width — fp64 width.
         *
         * Does not return a value.
         */
        void _lineWidth(int64 token, fp64 width)

        /*
         * Handles fill rect for this DrawingArea by calling the native
         * function cwhip_gtk_drawing_area_fill_rect.
         *
         * Parameters:
         *   token — int64 token.
         *   x — fp64 input value.
         *   y — fp64 input value.
         *   width — fp64 width.
         *   height — fp64 height.
         *
         * Does not return a value.
         */
        void _fillRect(int64 token, fp64 x, fp64 y, fp64 width, fp64 height)

        /*
         * Handles stroke rect for this DrawingArea by calling the native
         * function cwhip_gtk_drawing_area_stroke_rect.
         *
         * Parameters:
         *   token — int64 token.
         *   x — fp64 input value.
         *   y — fp64 input value.
         *   width — fp64 width.
         *   height — fp64 height.
         *
         * Does not return a value.
         */
        void _strokeRect(int64 token, fp64 x, fp64 y, fp64 width, fp64 height)

        /*
         * Handles fill circle for this DrawingArea by calling the native
         * function cwhip_gtk_drawing_area_fill_circle.
         *
         * Parameters:
         *   token — int64 token.
         *   cx — fp64 input value.
         *   cy — fp64 input value.
         *   radius — fp64 radius.
         *
         * Does not return a value.
         */
        void _fillCircle(int64 token, fp64 cx, fp64 cy, fp64 radius)

        /*
         * Handles stroke circle for this DrawingArea by calling the native
         * function cwhip_gtk_drawing_area_stroke_circle.
         *
         * Parameters:
         *   token — int64 token.
         *   cx — fp64 input value.
         *   cy — fp64 input value.
         *   radius — fp64 radius.
         *
         * Does not return a value.
         */
        void _strokeCircle(int64 token, fp64 cx, fp64 cy, fp64 radius)

        /*
         * Handles stroke line for this DrawingArea by calling the native
         * function cwhip_gtk_drawing_area_stroke_line.
         *
         * Parameters:
         *   token — int64 token.
         *   x1 — fp64 input value.
         *   y1 — fp64 input value.
         *   x2 — fp64 input value.
         *   y2 — fp64 input value.
         *
         * Does not return a value.
         */
        void _strokeLine(int64 token, fp64 x1, fp64 y1, fp64 x2, fp64 y2)
        public:
        // Mouse button numbers match GDK (1 primary, 2 middle, 3 secondary).
        enum {
            BUTTON_PRIMARY = 1, BUTTON_MIDDLE = 2, BUTTON_SECONDARY = 3
        }
        // onDrag phase values: begin at the press point, then update/end
        // offsets.
        enum {
            DRAG_BEGIN = 0, DRAG_UPDATE = 1, DRAG_END = 2
        }

        /*
         * Constructs a DrawingArea.
         *
         * Takes no parameters.
         *
         * Returns the constructed DrawingArea.
         */
        DrawingArea() {
            super Widget(16, "", 0, 0)
        }

        /*
         * Marks the area dirty so GTK schedules another onDraw.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void queueDraw() {
            _queueDraw(_widgetToken())
        }

        /*
         * Sets GtkDrawingArea content width/height used for measuring (useful
         * inside ScrolledWindow or when a fixed canvas size is wanted).
         *
         * Parameters:
         *   width — int64 width.
         *   height — int64 height.
         *
         * Does not return a value.
         */
        void setContentSize(int64 width, int64 height) {
            _contentSize(_widgetToken(), width, height)
        }

        /*
         * Installs the paint callback; width/height are the current
         * allocation. A later onDraw replaces the previous draw func.
         *
         * Parameters:
         *   action — void<int64,int64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onDraw(void<int64, int64> action) {
            return(SignalConnection(_drawSelf(), action))
        }

        /*
         * Click with widget-local coordinates. Fires on release of any button
         * (button is BUTTON_PRIMARY / MIDDLE / SECONDARY). A primary-button
         * drag that moves past GTK's drag threshold typically suppresses the
         * click so pick and pan can share the left button.
         *
         * Parameters:
         *   action — void<int64,fp64,fp64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onClick(void<int64, fp64, fp64> action) {
            return(SignalConnection(_drawSelf(), action))
        }

        /*
         * Primary-button drag for pan. Callback args are (phase, start_x,
         * start_y, offset_x, offset_y) with phase DRAG_*.
         *
         * Parameters:
         *   action — void<int64,fp64,fp64,fp64,fp64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onDrag(void<int64, fp64, fp64, fp64, fp64> action) {
            return(SignalConnection(_drawSelf(), action))
        }

        /*
         * Scroll-wheel / trackpad scroll for zoom. Args are (x, y, dx, dy) in
         * widget coordinates; x/y are the pointer focus when known.
         *
         * Parameters:
         *   action — void<fp64,fp64,fp64,fp64> action.
         *
         * Returns SignalConnection.
         */
        SignalConnection onScroll(void<fp64, fp64, fp64, fp64> action) {
            return(SignalConnection(_drawSelf(), action))
        }

        /*
         * Source color for subsequent fill/stroke calls (components 0..1).
         *
         * Parameters:
         *   r — fp64 input value.
         *   g — fp64 input value.
         *   b — fp64 input value.
         *   a — fp64 input value.
         *
         * Does not return a value.
         */
        void setColor(fp64 r, fp64 g, fp64 b, fp64 a) {
            _color(_widgetToken(), r, g, b, a)
        }

        /*
         * Sets line width for this DrawingArea.
         *
         * Parameters:
         *   width — fp64 width.
         *
         * Does not return a value.
         */
        void setLineWidth(fp64 width) {
            _lineWidth(_widgetToken(), width)
        }

        /*
         * Handles fill rect for this DrawingArea.
         *
         * Parameters:
         *   x — fp64 input value.
         *   y — fp64 input value.
         *   width — fp64 width.
         *   height — fp64 height.
         *
         * Does not return a value.
         */
        void fillRect(fp64 x, fp64 y, fp64 width, fp64 height) {
            _fillRect(_widgetToken(), x, y, width, height)
        }

        /*
         * Handles stroke rect for this DrawingArea.
         *
         * Parameters:
         *   x — fp64 input value.
         *   y — fp64 input value.
         *   width — fp64 width.
         *   height — fp64 height.
         *
         * Does not return a value.
         */
        void strokeRect(fp64 x, fp64 y, fp64 width, fp64 height) {
            _strokeRect(_widgetToken(), x, y, width, height)
        }

        /*
         * Handles fill circle for this DrawingArea.
         *
         * Parameters:
         *   cx — fp64 input value.
         *   cy — fp64 input value.
         *   radius — fp64 radius.
         *
         * Does not return a value.
         */
        void fillCircle(fp64 cx, fp64 cy, fp64 radius) {
            _fillCircle(_widgetToken(), cx, cy, radius)
        }

        /*
         * Handles stroke circle for this DrawingArea.
         *
         * Parameters:
         *   cx — fp64 input value.
         *   cy — fp64 input value.
         *   radius — fp64 radius.
         *
         * Does not return a value.
         */
        void strokeCircle(fp64 cx, fp64 cy, fp64 radius) {
            _strokeCircle(_widgetToken(), cx, cy, radius)
        }

        /*
         * Handles stroke line for this DrawingArea.
         *
         * Parameters:
         *   x1 — fp64 input value.
         *   y1 — fp64 input value.
         *   x2 — fp64 input value.
         *   y2 — fp64 input value.
         *
         * Does not return a value.
         */
        void strokeLine(fp64 x1, fp64 y1, fp64 x2, fp64 y2) {
            _strokeLine(_widgetToken(), x1, y1, x2, y2)
        }
    }
}
