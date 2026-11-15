/*
 * stdlib/system/0.1.0/file.cw — System.File from the system package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace System {
    /*
     * File is a class in this standard-library package.
     *
     * Its methods include constructor, path, mode, isOpen, eof, read, and 12
     * more.
     */
    class File {
        private:
        handle _fp
        String _path
        String _mode
        bool _isOpen

        public:
        /*
         * Constructs a File and stores _path, _mode, _fp, _fp.
         *
         * Parameters:
         *   path — String path.
         *   mode — String mode.
         *
         * Returns the constructed File.
         */
        File(String path, String mode) {
            _path = path
            _mode = mode
            _fp = Runtime().fileOpen(path, mode)
            if (_fp == null) {
                String err = System().lastError()
                if (err == "") {
                    err = "failed to open file"
                }
                raise(Exception(format("Cannot open file '{}': {}", path, err)))
            }
            _isOpen = true
        }

        /*
         * Returns the stored _path.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String path() {
            return(_path)
        }

        /*
         * Returns the stored _mode.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String mode() {
            return(_mode)
        }

        /*
         * Returns the stored _isOpen.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isOpen() {
            return(_isOpen)
        }

        /*
         * Returns Runtime().fileEof(_fp).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool eof() {
            return(Runtime().fileEof(_fp))
        }

        /*
         * Returns Runtime().fileRead(_fp, size).
         *
         * Parameters:
         *   size — int64 size.
         *
         * Returns String.
         */
        String read(int64 size) {
            return(Runtime().fileRead(_fp, size))
        }

        /*
         * Returns Runtime().fileReadAll(_fp).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String readAll() {
            return(Runtime().fileReadAll(_fp))
        }

        /*
         * Returns Runtime().fileReadBytes(_fp, size).
         *
         * Parameters:
         *   size — int64 size.
         *
         * Returns buffer.
         */
        buffer readBytes(int64 size) {
            return(Runtime().fileReadBytes(_fp, size))
        }

        /*
         * Returns Runtime().fileReadAllBytes(_fp).
         *
         * Takes no parameters.
         *
         * Returns buffer.
         */
        buffer readAllBytes() {
            return(Runtime().fileReadAllBytes(_fp))
        }

        /*
         * Returns Runtime().fileReadLine(_fp).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String readLine() {
            return(Runtime().fileReadLine(_fp))
        }

        /*
         * Returns Runtime().fileReadLines(_fp).
         *
         * Takes no parameters.
         *
         * Returns list.
         */
        list readLines() {
            return(Runtime().fileReadLines(_fp))
        }

        /*
         * Returns Runtime().fileWrite(_fp, data).
         *
         * Parameters:
         *   data — String data.
         *
         * Returns int64.
         */
        int64 write(String data) {
            return(Runtime().fileWrite(_fp, data))
        }

        /*
         * Returns Runtime().fileWriteBytes(_fp, data).
         *
         * Parameters:
         *   data — buffer data.
         *
         * Returns int64.
         */
        int64 writeBytes(buffer data) {
            return(Runtime().fileWriteBytes(_fp, data))
        }

        /*
         * Returns Runtime().fileWriteLine(_fp, line).
         *
         * Parameters:
         *   line — String line.
         *
         * Returns int64.
         */
        int64 writeLine(String line) {
            return(Runtime().fileWriteLine(_fp, line))
        }

        /*
         * Returns Runtime().fileSeek(_fp, offset, whence).
         *
         * Parameters:
         *   offset — int64 offset.
         *   whence — int64 whence.
         *
         * Returns int64.
         */
        int64 seek(int64 offset, int64 whence) {
            return(Runtime().fileSeek(_fp, offset, whence))
        }

        /*
         * Returns Runtime().fileTell(_fp).
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 tell() {
            return(Runtime().fileTell(_fp))
        }

        /*
         * Flushes the File state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void flush() {
            Runtime().fileFlush(_fp)
        }

        /*
         * Closes the File state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void close() {
            if (_isOpen) {
                Runtime().fileClose(_fp)
                _fp = null
                _isOpen = false
            }
        }
    }
}
