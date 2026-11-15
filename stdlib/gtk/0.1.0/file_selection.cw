/*
 * stdlib/gtk/0.1.0/file_selection.cw — Gtk.FileSelection from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * FileSelection is a class in this standard-library package.
     *
     * Its methods include constructor, add.
     */
    class FileSelection {
        private:
        list _paths
        void<list> _result
        public:
        /*
         * Constructs a FileSelection and stores _paths, _result.
         *
         * Parameters:
         *   result — void<list> result.
         *
         * Returns the constructed FileSelection.
         */
        FileSelection(void<list> result) {
            _paths = []
            _result = result
        }

        /*
         * Adds the FileSelection state.
         *
         * Parameters:
         *   path — String path.
         *
         * Does not return a value.
         */
        void add(String path) {
            if (!path.equals("")) {
                _paths.append(path)
                return
            }
            list paths = _paths
            _paths = []
            _result(paths)
        }
    }
}
