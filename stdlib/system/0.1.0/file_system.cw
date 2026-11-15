/*
 * stdlib/system/0.1.0/file_system.cw
 *
 * System.FileSystem from the system package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace System {
    /*
     * FileSystem is a class in this standard-library package.
     *
     * Its methods include exists, isFile, isDir, fileSize, remove, rename, and
     * 14 more.
     */
    class FileSystem {
        public:
        /*
         * Handles exists for this FileSystem by calling the native function
         * cwhip_fs_exists.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns bool.
         */
        bool exists(String path)

        /*
         * Reports whether file for this FileSystem by calling the native
         * function cwhip_fs_is_file.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns bool.
         */
        bool isFile(String path)

        /*
         * Reports whether dir for this FileSystem by calling the native
         * function cwhip_fs_is_dir.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns bool.
         */
        bool isDir(String path)

        /*
         * Handles file size for this FileSystem by calling the native function
         * cwhip_fs_file_size.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns int64.
         */
        int64 fileSize(String path)

        /*
         * Removes the FileSystem state by calling the native function
         * cwhip_fs_remove.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns bool.
         */
        bool remove(String path)

        /*
         * Handles rename for this FileSystem by calling the native function
         * cwhip_fs_rename.
         *
         * Parameters:
         *   oldPath — String old path.
         *   newPath — String new path.
         *
         * Returns bool.
         */
        bool rename(String oldPath, String newPath)

        /*
         * Handles copy for this FileSystem by calling the native function
         * cwhip_fs_copy.
         *
         * Parameters:
         *   src — String src.
         *   dest — String dest.
         *
         * Returns bool.
         */
        bool copy(String src, String dest)

        /*
         * Handles mkdir for this FileSystem by calling the native function
         * cwhip_fs_mkdir.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns bool.
         */
        bool mkdir(String path)

        /*
         * Handles rmdir for this FileSystem by calling the native function
         * cwhip_fs_rmdir.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns bool.
         */
        bool rmdir(String path)

        /*
         * Handles list dir for this FileSystem by calling the native function
         * cwhip_fs_list_dir.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns list.
         */
        list listDir(String path)

        /*
         * Returns cwd for this FileSystem by calling the native function
         * cwhip_fs_get_cwd.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String getCwd()

        /*
         * Handles ch dir for this FileSystem by calling the native function
         * cwhip_fs_ch_dir.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns bool.
         */
        bool chDir(String path)

        /*
         * Handles absolute path for this FileSystem by calling the native
         * function cwhip_fs_absolute_path.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns String.
         */
        String absolutePath(String path)

        /*
         * Handles join for this FileSystem by calling the native function
         * cwhip_path_join.
         *
         * Parameters:
         *   left — String left.
         *   right — String right.
         *
         * Returns String.
         */
        String join(String left, String right)

        /*
         * Handles normalize for this FileSystem by calling the native function
         * cwhip_path_normalize.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns String.
         */
        String normalize(String path)

        /*
         * Handles basename for this FileSystem by calling the native function
         * cwhip_path_basename.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns String.
         */
        String basename(String path)

        /*
         * Handles dirname for this FileSystem by calling the native function
         * cwhip_path_dirname.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns String.
         */
        String dirname(String path)

        /*
         * Handles extension for this FileSystem by calling the native function
         * cwhip_path_extension.
         *
         * Parameters:
         *   path — String path.
         *
         * Returns String.
         */
        String extension(String path)

        /*
         * Handles temp file for this FileSystem by calling the native function
         * cwhip_fs_temp_file.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String tempFile()

        /*
         * Handles temp dir for this FileSystem by calling the native function
         * cwhip_fs_temp_dir.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String tempDir()
    }
}
