/*
 * stdlib/terminal/0.1.0/terminal.cw — terminal package implementation.
 *
 * Created: 2026-10-09
 * Author: chuck
 *
 * Changelog:
 *   2026-10-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Terminal {

    /*
     * Terminal is a class in this standard-library package.
     *
     * Its methods include isInteractive, isOutputInteractive, columns, rows,
     * supportsColor.
     */
    class Terminal {
        public:
        /*
         * Reports whether interactive for this Terminal by calling the native
         * function cwhip_terminal_stdin_interactive.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isInteractive()

        /*
         * Reports whether output interactive for this Terminal by calling the
         * native function cwhip_terminal_stdout_interactive.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isOutputInteractive()

        /*
         * Handles columns for this Terminal by calling the native function
         * cwhip_terminal_columns.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 columns()

        /*
         * Handles rows for this Terminal by calling the native function
         * cwhip_terminal_rows.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 rows()

        /*
         * Handles supports color for this Terminal by calling the native
         * function cwhip_terminal_supports_color.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool supportsColor()
    }

    bool Terminal.isInteractive() from "cwhip_terminal_stdin_interactive"
    bool Terminal.isOutputInteractive() from "cwhip_terminal_stdout_interactive"
    int64 Terminal.columns() from "cwhip_terminal_columns"
    int64 Terminal.rows() from "cwhip_terminal_rows"
    bool Terminal.supportsColor() from "cwhip_terminal_supports_color"
}
