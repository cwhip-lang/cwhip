/*
 * stdlib/gtk/0.1.0/file_dialog.cw — Gtk.FileDialog from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * FileDialog is a class in this standard-library package.
     *
     * Its methods include _create, _createMultiple, _createFolder, _cancel,
     * _pending, constructor, and 2 more.
     */
    class FileDialog {
        private:
        int64 _token
        FileSelection _selection

        /*
         * Handles create for this FileDialog by calling the native function
         * cwhip_gtk_file_dialog_create.
         *
         * Parameters:
         *   parent — int64 parent.
         *   save — bool save.
         *   initialPath — String initial path.
         *   result — void<String> result.
         *
         * Returns int64.
         */
        int64 _create(
                int64 parent,
                bool save,
                String initialPath,
                void<String> result)

        /*
         * Handles create multiple for this FileDialog by calling the native
         * function cwhip_gtk_file_dialog_create_multiple.
         *
         * Parameters:
         *   parent — int64 parent.
         *   initialPath — String initial path.
         *   path — void<String> path.
         *
         * Returns int64.
         */
        int64 _createMultiple(
                int64 parent,
                String initialPath,
                void<String> path)

        /*
         * Handles create folder for this FileDialog by calling the native
         * function cwhip_gtk_file_dialog_create_folder.
         *
         * Parameters:
         *   parent — int64 parent.
         *   initialPath — String initial path.
         *   result — void<String> result.
         *
         * Returns int64.
         */
        int64 _createFolder(
                int64 parent,
                String initialPath,
                void<String> result)

        /*
         * Handles cancel for this FileDialog by calling the native function
         * cwhip_gtk_file_dialog_cancel.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Does not return a value.
         */
        void _cancel(int64 token)

        /*
         * Handles pending for this FileDialog by calling the native function
         * cwhip_gtk_file_dialog_pending.
         *
         * Parameters:
         *   token — int64 token.
         *
         * Returns bool.
         */
        bool _pending(int64 token)
        public:
        /*
         * Constructs a FileDialog and stores _token.
         *
         * Parameters:
         *   parent — Window parent.
         *   save — bool save.
         *   initialPath — String initial path.
         *   result — void<String> result.
         *
         * Returns the constructed FileDialog.
         */
        FileDialog(
                Window parent,
                bool save,
                String initialPath,
                void<String> result) {
            _token = _create(parent._widgetToken(), save, initialPath, result)
        }

        /*
         * Constructs a FileDialog and stores _selection, _token.
         *
         * Parameters:
         *   parent — Window parent.
         *   initialPath — String initial path.
         *   results — void<list> results.
         *
         * Returns the constructed FileDialog.
         */
        FileDialog(Window parent, String initialPath, void<list> results) {
            _selection = FileSelection(results)
            _token = _createMultiple(
                    parent._widgetToken(),
                    initialPath,
                    _selection.add)
        }

        /*
         * Constructs a FileDialog and stores _token.
         *
         * Parameters:
         *   parent — Window parent.
         *   initialPath — String initial path.
         *   folder — void<String> folder.
         *
         * Returns the constructed FileDialog.
         */
        FileDialog(Window parent, String initialPath, void<String> folder) {
            _token = _createFolder(parent._widgetToken(), initialPath, folder)
        }

        /*
         * Cancels the FileDialog state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void cancel() {
            _cancel(_token)
        }

        /*
         * Returns _pending(_token).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool pending() {
            return(_pending(_token))
        }
    }
}
