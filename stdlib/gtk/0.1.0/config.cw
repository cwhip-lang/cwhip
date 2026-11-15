/*
 * stdlib/gtk/0.1.0/config.cw — Gtk.Config from the gtk package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Gtk {
    /*
     * Config is a class in this standard-library package.
     *
     * Its methods include validate, fileStatus, value, key, quote, merge, and
     * 6 more.
     */
    class Config {
        public:
        /*
         * Validates the Config state by calling the native function
         * cwhip_gtk_config_validate.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns String.
         */
        String validate(String text)

        /*
         * Handles file status for this Config by calling the native function
         * cwhip_gtk_config_file_status.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns String.
         */
        String fileStatus(String path)

        /*
         * Handles value for this Config by calling the native function
         * cwhip_gtk_config_value.
         *
         * Parameters:
         *   text — String text.
         *   section — String section.
         *   key — String key.
         *
         * Returns String.
         */
        String value(String text, String section, String key)

        /*
         * Handles key for this Config by calling the native function
         * cwhip_gtk_config_key.
         *
         * Parameters:
         *   text — String text.
         *   section — String section.
         *   index — int64 index.
         *
         * Returns String.
         */
        String key(String text, String section, int64 index)

        /*
         * Handles quote for this Config by calling the native function
         * cwhip_gtk_config_quote.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns String.
         */
        String quote(String text)

        /*
         * Handles merge for this Config by calling the native function
         * cwhip_gtk_config_merge.
         *
         * Parameters:
         *   original — String original.
         *   updates — String updates.
         *
         * Returns String.
         */
        String merge(String original, String updates)

        /*
         * Removes the Config state by calling the native function
         * cwhip_gtk_config_remove.
         *
         * Parameters:
         *   text — String text.
         *   section — String section.
         *   key — String key.
         *
         * Returns String.
         */
        String remove(String text, String section, String key)

        /*
         * Handles item for this Config by calling the native function
         * cwhip_gtk_config_item.
         *
         * Parameters:
         *   text — String text.
         *   section — String section.
         *   key — String key.
         *   index — int64 index.
         *   field — String field.
         *
         * Returns String.
         */
        String item(
                String text,
                String section,
                String key,
                int64 index,
                String field)

        /*
         * Handles array size for this Config by calling the native function
         * cwhip_gtk_config_array_size.
         *
         * Parameters:
         *   text — String text.
         *   section — String section.
         *   key — String key.
         *
         * Returns int64.
         */
        int64 arraySize(String text, String section, String key)

        /*
         * Saves the Config state by calling the native function
         * cwhip_gtk_config_save.
         *
         * Parameters:
         *   path — String path.
         *   text — String text.
         *   expected — String expected.
         *   result — void<String> result.
         *
         * Does not return a value.
         */
        void save(
                String path,
                String text,
                String expected,
                void<String> result)

        /*
         * Saves now for this Config by calling the native function
         * cwhip_gtk_config_save_now.
         *
         * Parameters:
         *   path — String path.
         *   text — String text.
         *   expected — String expected.
         *
         * Returns String.
         */
        String saveNow(String path, String text, String expected)

        /*
         * Flushes the Config state by calling the native function
         * cwhip_gtk_config_flush.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void flush()
    }

    String Config.validate(String text) from "cwhip_gtk_config_validate"

    String Config.fileStatus(String path) from "cwhip_gtk_config_file_status"

    String Config.value(String text, String section, String key) from "cwhip_gtk_config_value"

    String Config.key(String text, String section, int64 index) from "cwhip_gtk_config_key"

    String Config.quote(String text) from "cwhip_gtk_config_quote"

    String Config.merge(String original, String updates) from "cwhip_gtk_config_merge"

    String Config.remove(String text, String section, String key) from "cwhip_gtk_config_remove"

    String Config.item(
            String text,
            String section,
            String key,
            int64 index,
            String field)
        from "cwhip_gtk_config_item"

    int64 Config.arraySize(String text, String section, String key) from "cwhip_gtk_config_array_size"

    void Config.save(
            String path,
            String text,
            String expected,
            void<String> result)
        from "cwhip_gtk_config_save"

    String Config.saveNow(String path, String text, String expected) from "cwhip_gtk_config_save_now"

    void Config.flush() from "cwhip_gtk_config_flush"

}
