/*
 * stdlib/system/0.1.0/standard_io.cw
 *
 * System.StandardIO from the system package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace System {
    /*
     * StandardIO is a class in this standard-library package.
     *
     * Its methods include read, readLine, write, writeLine, writeBytes,
     * writeError, and 4 more.
     */
    class StandardIO {
        public:
        /*
         * Reads the StandardIO state by calling the native function
         * cwhip_stdio_read.
         *
         * Parameters:
         *   size — int64 size.
         *
         * Returns String.
         */
        String read(int64 size)

        /*
         * Reads line for this StandardIO by calling the native function
         * cwhip_stdio_read_line.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String readLine()

        /*
         * Writes the StandardIO state by calling the native function
         * cwhip_stdio_write.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns int64.
         */
        int64 write(String text)

        /*
         * Writes line for this StandardIO by calling the native function
         * cwhip_stdio_write_line.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns int64.
         */
        int64 writeLine(String text)

        /*
         * Writes bytes for this StandardIO by calling the native function
         * cwhip_stdio_write_bytes.
         *
         * Parameters:
         *   data — buffer data.
         *
         * Returns int64.
         */
        int64 writeBytes(buffer data)

        /*
         * Writes error for this StandardIO by calling the native function
         * cwhip_stdio_write_error.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns int64.
         */
        int64 writeError(String text)

        /*
         * Writes error line for this StandardIO by calling the native function
         * cwhip_stdio_write_error_line.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns int64.
         */
        int64 writeErrorLine(String text)

        /*
         * Writes error bytes for this StandardIO by calling the native
         * function cwhip_stdio_write_error_bytes.
         *
         * Parameters:
         *   data — buffer data.
         *
         * Returns int64.
         */
        int64 writeErrorBytes(buffer data)

        /*
         * Flushes the StandardIO state by calling the native function
         * cwhip_stdio_flush.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void flush()

        /*
         * Flushes error for this StandardIO by calling the native function
         * cwhip_stdio_flush_error.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void flushError()
    }
}
