/*
 * stdlib/system/0.1.0/runtime.cw — System.Runtime from the system package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace System {
    /*
     * Runtime is a class in this standard-library package.
     *
     * Its methods include fileOpen, fileRead, fileReadAll, fileReadBytes,
     * fileReadAllBytes, fileReadLine, and 9 more.
     */
    class Runtime {
        public:
        /*
         * Handles file open for this Runtime by calling the native function
         * cwhip_file_open.
         *
         * Parameters:
         *   path — String path.
         *   mode — String mode.
         *
         * Returns handle.
         */
        handle fileOpen(String path, String mode)

        /*
         * Handles file read for this Runtime by calling the native function
         * cwhip_file_read.
         *
         * Parameters:
         *   fp — handle input value.
         *   size — int64 size.
         *
         * Returns String.
         */
        String fileRead(handle fp, int64 size)

        /*
         * Handles file read all for this Runtime by calling the native
         * function cwhip_file_read_all.
         *
         * Parameters:
         *   fp — handle input value.
         *
         * Returns String.
         */
        String fileReadAll(handle fp)

        /*
         * Handles file read bytes for this Runtime by calling the native
         * function cwhip_file_read_bytes.
         *
         * Parameters:
         *   fp — handle input value.
         *   size — int64 size.
         *
         * Returns buffer.
         */
        buffer fileReadBytes(handle fp, int64 size)

        /*
         * Handles file read all bytes for this Runtime by calling the native
         * function cwhip_file_read_all_bytes.
         *
         * Parameters:
         *   fp — handle input value.
         *
         * Returns buffer.
         */
        buffer fileReadAllBytes(handle fp)

        /*
         * Handles file read line for this Runtime by calling the native
         * function cwhip_file_read_line.
         *
         * Parameters:
         *   fp — handle input value.
         *
         * Returns String.
         */
        String fileReadLine(handle fp)

        /*
         * Handles file read lines for this Runtime by calling the native
         * function cwhip_file_read_lines.
         *
         * Parameters:
         *   fp — handle input value.
         *
         * Returns list.
         */
        list fileReadLines(handle fp)

        /*
         * Handles file write for this Runtime by calling the native function
         * cwhip_file_write.
         *
         * Parameters:
         *   fp — handle input value.
         *   data — String data.
         *
         * Returns int64.
         */
        int64 fileWrite(handle fp, String data)

        /*
         * Handles file write bytes for this Runtime by calling the native
         * function cwhip_file_write_bytes.
         *
         * Parameters:
         *   fp — handle input value.
         *   data — buffer data.
         *
         * Returns int64.
         */
        int64 fileWriteBytes(handle fp, buffer data)

        /*
         * Handles file write line for this Runtime by calling the native
         * function cwhip_file_write_line.
         *
         * Parameters:
         *   fp — handle input value.
         *   line — String line.
         *
         * Returns int64.
         */
        int64 fileWriteLine(handle fp, String line)

        /*
         * Handles file seek for this Runtime by calling the native function
         * cwhip_file_seek.
         *
         * Parameters:
         *   fp — handle input value.
         *   offset — int64 offset.
         *   whence — int64 whence.
         *
         * Returns int64.
         */
        int64 fileSeek(handle fp, int64 offset, int64 whence)

        /*
         * Handles file tell for this Runtime by calling the native function
         * cwhip_file_tell.
         *
         * Parameters:
         *   fp — handle input value.
         *
         * Returns int64.
         */
        int64 fileTell(handle fp)

        /*
         * Handles file flush for this Runtime by calling the native function
         * cwhip_file_flush.
         *
         * Parameters:
         *   fp — handle input value.
         *
         * Does not return a value.
         */
        void fileFlush(handle fp)

        /*
         * Handles file close for this Runtime by calling the native function
         * cwhip_file_close.
         *
         * Parameters:
         *   fp — handle input value.
         *
         * Does not return a value.
         */
        void fileClose(handle fp)

        /*
         * Handles file eof for this Runtime by calling the native function
         * cwhip_file_eof.
         *
         * Parameters:
         *   fp — handle input value.
         *
         * Returns bool.
         */
        bool fileEof(handle fp)
    }
}
