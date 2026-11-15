/*
 * stdlib/system/0.1.0/bindings.cw — native method bindings for the
 * system package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace System {
    int64 Process.argc() from "cwhip_system_argc"

    list Process.argv() from "cwhip_system_argv"

    String Process.arg(int64 index) from "cwhip_system_arg"

    void Process.exit(int64 code) from "cwhip_system_exit"

    void Process.abort() from "cwhip_system_abort"

    String Process.getEnv(String name) from "cwhip_system_getenv"

    bool Process.setEnv(String name, String value) from "cwhip_system_setenv"

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

}
