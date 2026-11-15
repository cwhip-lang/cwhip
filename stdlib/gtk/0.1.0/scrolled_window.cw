/*
 * stdlib/gtk/0.1.0/scrolled_window.cw
 *
 * Gtk.ScrolledWindow from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * ScrolledWindow is a class derived from Widget in this standard-library
     * package.
     *
     * Its methods include constructor, setChild, remove, setPolicy,
     * setOverlayScrolling, _policy, and 1 more.
     */
    class ScrolledWindow : Widget {
        // Matches GtkPolicyType: always / automatic / never / external.
        public:
        enum {
            POLICY_ALWAYS = 0,
            POLICY_AUTOMATIC = 1,
            POLICY_NEVER = 2,
            POLICY_EXTERNAL = 3
        }
        public:
        /*
         * Constructs a ScrolledWindow.
         *
         * Takes no parameters.
         *
         * Returns the constructed ScrolledWindow.
         */
        ScrolledWindow() {
            super Widget(7, "", 0, 0)
        }

        /*
         * Sets child for this ScrolledWindow.
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
         * Removes the ScrolledWindow state.
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
         * Sets policy for this ScrolledWindow.
         *
         * Parameters:
         *   horizontal — int64 horizontal.
         *   vertical — int64 vertical.
         *
         * Does not return a value.
         */
        void setPolicy(int64 horizontal, int64 vertical) {
            _policy(_widgetToken(), horizontal, vertical)
        }

        /*
         * Sets overlay scrolling for this ScrolledWindow.
         *
         * Parameters:
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void setOverlayScrolling(bool enabled) {
            _overlay(_widgetToken(), enabled)
        }

        /*
         * Handles policy for this ScrolledWindow by calling the native
         * function cwhip_gtk_scrolled_window_set_policy.
         *
         * Parameters:
         *   token — int64 token.
         *   horizontal — int64 horizontal.
         *   vertical — int64 vertical.
         *
         * Does not return a value.
         */
        void _policy(int64 token, int64 horizontal, int64 vertical)

        /*
         * Handles overlay for this ScrolledWindow by calling the native
         * function cwhip_gtk_scrolled_window_set_overlay_scrolling.
         *
         * Parameters:
         *   token — int64 token.
         *   enabled — bool enabled.
         *
         * Does not return a value.
         */
        void _overlay(int64 token, bool enabled)
    }

    void ScrolledWindow._policy(int64 token, int64 horizontal, int64 vertical)
        from "cwhip_gtk_scrolled_window_set_policy"

    void ScrolledWindow._overlay(int64 token, bool enabled)
        from "cwhip_gtk_scrolled_window_set_overlay_scrolling"

}
