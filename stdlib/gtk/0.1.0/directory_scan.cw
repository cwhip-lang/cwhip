/*
 * stdlib/gtk/0.1.0/directory_scan.cw — Gtk.DirectoryScan from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * DirectoryScan is a class in this standard-library package.
     *
     * Its methods include _start, _startFiltered, _cancel, _append,
     * constructor, cancel, and 1 more.
     */
    class DirectoryScan {
        private:
        int64 _token

        /*
         * Handles start for this DirectoryScan by calling the native function
         * cwhip_gtk_directory_start.
         *
         * Parameters:
         *   owner — int64 owner.
         *   path — String path.
         *   hidden — bool hidden.
         *   result — void<int64,String> result.
         *
         * Returns int64.
         */
        int64 _start(
                int64 owner,
                String path,
                bool hidden,
                void<int64,
                String> result)

        /*
         * Handles start filtered for this DirectoryScan by calling the native
         * function cwhip_gtk_directory_start_filtered.
         *
         * Parameters:
         *   owner — int64 owner.
         *   path — String path.
         *   hidden — bool hidden.
         *   root — String root.
         *   excludes — String excludes.
         *   result — void<int64,String> result.
         *
         * Returns int64.
         */
        int64 _startFiltered(
                int64 owner,
                String path,
                bool hidden,
                String root,
                String excludes,
            void<int64,
                String> result)

        /*
         * Handles cancel for this DirectoryScan by calling the native function
         * cwhip_gtk_directory_cancel.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _cancel(int64 token)

        /*
         * Handles append for this DirectoryScan by calling the native function
         * cwhip_gtk_directory_append.
         *
         * Parameters:
         *   token — int64 token.
         *   tree — int64 tree.
         *   parent — int64 parent.
         *   firstId — int64 first id.
         *   count — int64 count.
         *   icons — String icons.
         *
         * Does not return a value.
         */
        void _append(
                int64 token,
                int64 tree,
                int64 parent,
                int64 firstId,
                int64 count,
                String icons)
        public:
        /*
         * Constructs a DirectoryScan and stores _token.
         *
         * Parameters:
         *   owner — Tree owner.
         *   path — String path.
         *   hidden — bool hidden.
         *   result — void<int64,String> result.
         *
         * Returns the constructed DirectoryScan.
         */
        DirectoryScan(
                Tree owner,
                String path,
                bool hidden,
                void<int64,
                String> result) {
            _token = _start(owner._widgetToken(), path, hidden, result)
        }

        /*
         * Constructs a DirectoryScan and stores _token.
         *
         * Parameters:
         *   owner — Tree owner.
         *   path — String path.
         *   hidden — bool hidden.
         *   root — String root.
         *   excludes — String excludes.
         *   result — void<int64,String> result.
         *
         * Returns the constructed DirectoryScan.
         */
        DirectoryScan(
                Tree owner,
                String path,
                bool hidden,
                String root,
                String excludes,
                void<int64, String> result) {
            _token = _startFiltered(
                    owner._widgetToken(),
                    path,
                    hidden,
                    root,
                    excludes,
                    result)
        }

        /*
         * Cancels the DirectoryScan state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void cancel() {
            _cancel(_token)
        }

        /*
         * Appends the DirectoryScan state.
         *
         * Parameters:
         *   owner — Tree owner.
         *   parent — int64 parent.
         *   firstId — int64 first id.
         *   count — int64 count.
         *   icons — String icons.
         *
         * Does not return a value.
         */
        void append(
                Tree owner,
                int64 parent,
                int64 firstId,
                int64 count,
                String icons) {
            _append(
                    _token,
                    owner._widgetToken(),
                    parent,
                    firstId,
                    count,
                    icons)
        }
    }
}
