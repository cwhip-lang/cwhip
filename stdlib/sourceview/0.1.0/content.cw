/*
 * stdlib/sourceview/0.1.0/content.cw
 *
 * GtkSource.Content from the sourceview package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace GtkSource {
    /*
     * Content is a class in this standard-library package.
     *
     * Classifies file names and contents for source editing.
     */
    class Content {
        // Registered language id for a file name ("" means plain text).
        public:
        /*
         * Handles language for this Content by calling the native function
         * cwhip_gtk_source_language_for.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns String.
         */
        String languageFor(String path)

        /*
         * False for data that is not editable text (contains NUL bytes). The
         * body is the native function cwhip_gtk_source_is_text.
         *
         * Parameters:
         *   data — String data.
         *
         * Returns bool.
         */
        bool isText(String data)
    }
}
