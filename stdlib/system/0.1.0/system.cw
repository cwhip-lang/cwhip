namespace System {
    class Runtime {
        public:
        handle fileOpen(String path, String mode)
        String fileRead(handle fp, int64 size)
        String fileReadAll(handle fp)
        buffer fileReadBytes(handle fp, int64 size)
        buffer fileReadAllBytes(handle fp)
        String fileReadLine(handle fp)
        list fileReadLines(handle fp)
        int64 fileWrite(handle fp, String data)
        int64 fileWriteBytes(handle fp, buffer data)
        int64 fileWriteLine(handle fp, String line)
        int64 fileSeek(handle fp, int64 offset, int64 whence)
        int64 fileTell(handle fp)
        void fileFlush(handle fp)
        void fileClose(handle fp)
        bool fileEof(handle fp)
    }

    class Process {
        public:
        int64 argc()
        list argv()
        String arg(int64 index)
        void exit(int64 code)
        void abort()
        String getEnv(String name)
        bool setEnv(String name, String value)
    }

    class StandardIO {
        public:
        String read(int64 size)
        String readLine()
        int64 write(String text)
        int64 writeLine(String text)
        int64 writeBytes(buffer data)
        int64 writeError(String text)
        int64 writeErrorLine(String text)
        int64 writeErrorBytes(buffer data)
        void flush()
        void flushError()
    }

    class File {
        private:
        handle _fp
        String _path
        String _mode
        bool _isOpen

        public:
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

        String path() {
            return(_path)
        }

        String mode() {
            return(_mode)
        }

        bool isOpen() {
            return(_isOpen)
        }

        bool eof() {
            return(Runtime().fileEof(_fp))
        }

        String read(int64 size) {
            return(Runtime().fileRead(_fp, size))
        }

        String readAll() {
            return(Runtime().fileReadAll(_fp))
        }

        buffer readBytes(int64 size) {
            return(Runtime().fileReadBytes(_fp, size))
        }

        buffer readAllBytes() {
            return(Runtime().fileReadAllBytes(_fp))
        }

        String readLine() {
            return(Runtime().fileReadLine(_fp))
        }

        list readLines() {
            return(Runtime().fileReadLines(_fp))
        }

        int64 write(String data) {
            return(Runtime().fileWrite(_fp, data))
        }

        int64 writeBytes(buffer data) {
            return(Runtime().fileWriteBytes(_fp, data))
        }

        int64 writeLine(String line) {
            return(Runtime().fileWriteLine(_fp, line))
        }

        int64 seek(int64 offset, int64 whence) {
            return(Runtime().fileSeek(_fp, offset, whence))
        }

        int64 tell() {
            return(Runtime().fileTell(_fp))
        }

        void flush() {
            Runtime().fileFlush(_fp)
        }

        void close() {
            if (_isOpen) {
                Runtime().fileClose(_fp)
                _fp = null
                _isOpen = false
            }
        }
    }

    class FileSystem {
        public:
        bool exists(String path)
        bool isFile(String path)
        bool isDir(String path)
        int64 fileSize(String path)
        bool remove(String path)
        bool rename(String oldPath, String newPath)
        bool copy(String src, String dest)
        bool mkdir(String path)
        bool rmdir(String path)
        list listDir(String path)
        String getCwd()
        bool chDir(String path)
        String absolutePath(String path)
        String join(String left, String right)
        String normalize(String path)
        String basename(String path)
        String dirname(String path)
        String extension(String path)
        String tempFile()
        String tempDir()
    }

    class Glob {
        public:
        list glob(String pattern)
    }

    class System {
        public:
        int64 argc() {
            return(Process().argc())
        }

        list argv() {
            return(Process().argv())
        }

        String arg(int64 index) {
            return(Process().arg(index))
        }

        void exit(int64 code)
        void abort()

        StandardIO io() {
            return(StandardIO())
        }

        String lastError()

        File open(String path, String mode) {
            return(File(path, mode))
        }

        bool exists(String path) {
            return(FileSystem().exists(path))
        }

        String getEnv(String name) {
            return(Process().getEnv(name))
        }
    }

    int64 Process.argc() from "cwhip_system_argc"
    list Process.argv() from "cwhip_system_argv"
    String Process.arg(int64 index) from "cwhip_system_arg"
    void Process.exit(int64 code) from "cwhip_system_exit"
    void Process.abort() from "cwhip_system_abort"
    String Process.getEnv(String name) from "cwhip_system_getenv"
    bool Process.setEnv(String name, String value) from "cwhip_system_setenv"
    String System.lastError() from "cwhip_system_last_error"

    String StandardIO.read(int64 size) from "cwhip_stdio_read"
    String StandardIO.readLine() from "cwhip_stdio_read_line"
    int64 StandardIO.write(String text) from "cwhip_stdio_write"
    int64 StandardIO.writeLine(String text) from "cwhip_stdio_write_line"
    int64 StandardIO.writeBytes(buffer data) from "cwhip_stdio_write_bytes"
    int64 StandardIO.writeError(String text) from "cwhip_stdio_write_error"
    int64 StandardIO.writeErrorLine(String text) from "cwhip_stdio_write_error_line"
    int64 StandardIO.writeErrorBytes(buffer data) from "cwhip_stdio_write_error_bytes"
    void StandardIO.flush() from "cwhip_stdio_flush"
    void StandardIO.flushError() from "cwhip_stdio_flush_error"

    handle Runtime.fileOpen(String path, String mode) from "cwhip_file_open"
    String Runtime.fileRead(handle fp, int64 size) from "cwhip_file_read"
    String Runtime.fileReadAll(handle fp) from "cwhip_file_read_all"
    buffer Runtime.fileReadBytes(handle fp, int64 size) from "cwhip_file_read_bytes"
    buffer Runtime.fileReadAllBytes(handle fp) from "cwhip_file_read_all_bytes"
    String Runtime.fileReadLine(handle fp) from "cwhip_file_read_line"
    list Runtime.fileReadLines(handle fp) from "cwhip_file_read_lines"
    int64 Runtime.fileWrite(handle fp, String data) from "cwhip_file_write"
    int64 Runtime.fileWriteBytes(handle fp, buffer data) from "cwhip_file_write_bytes"
    int64 Runtime.fileWriteLine(handle fp, String line) from "cwhip_file_write_line"
    int64 Runtime.fileSeek(handle fp, int64 offset, int64 whence) from "cwhip_file_seek"
    int64 Runtime.fileTell(handle fp) from "cwhip_file_tell"
    void Runtime.fileFlush(handle fp) from "cwhip_file_flush"
    void Runtime.fileClose(handle fp) from "cwhip_file_close"
    bool Runtime.fileEof(handle fp) from "cwhip_file_eof"

    bool FileSystem.exists(String path) from "cwhip_fs_exists"
    bool FileSystem.isFile(String path) from "cwhip_fs_is_file"
    bool FileSystem.isDir(String path) from "cwhip_fs_is_dir"
    int64 FileSystem.fileSize(String path) from "cwhip_fs_file_size"
    bool FileSystem.remove(String path) from "cwhip_fs_remove"
    bool FileSystem.rename(String oldPath, String newPath) from "cwhip_fs_rename"
    bool FileSystem.copy(String src, String dest) from "cwhip_fs_copy"
    bool FileSystem.mkdir(String path) from "cwhip_fs_mkdir"
    bool FileSystem.rmdir(String path) from "cwhip_fs_rmdir"
    list FileSystem.listDir(String path) from "cwhip_fs_list_dir"
    String FileSystem.getCwd() from "cwhip_fs_get_cwd"
    bool FileSystem.chDir(String path) from "cwhip_fs_ch_dir"
    String FileSystem.absolutePath(String path) from "cwhip_fs_absolute_path"
    String FileSystem.join(String left, String right) from "cwhip_path_join"
    String FileSystem.normalize(String path) from "cwhip_path_normalize"
    String FileSystem.basename(String path) from "cwhip_path_basename"
    String FileSystem.dirname(String path) from "cwhip_path_dirname"
    String FileSystem.extension(String path) from "cwhip_path_extension"
    String FileSystem.tempFile() from "cwhip_fs_temp_file"
    String FileSystem.tempDir() from "cwhip_fs_temp_dir"

    list Glob.glob(String pattern) from "cwhip_glob_glob"

    void System.exit(int64 code) from "cwhip_system_exit"
    void System.abort() from "cwhip_system_abort"
}
