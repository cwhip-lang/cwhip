/*
 * stdlib/system/0.1.0/system_class.cw — System.System from the system package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace System {
    /*
     * System is a class in this standard-library package.
     *
     * Its methods include argc, argv, arg, exit, abort, io, and 4 more.
     */
    class System {
        public:
        /*
         * Returns Process().argc().
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 argc() {
            return(Process().argc())
        }

        /*
         * Returns Process().argv().
         *
         * Takes no parameters.
         *
         * Returns list.
         */
        list argv() {
            return(Process().argv())
        }

        /*
         * Returns Process().arg(index).
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns String.
         */
        String arg(int64 index) {
            return(Process().arg(index))
        }

        /*
         * Handles exit for this System by calling the native function
         * cwhip_system_exit.
         *
         * Parameters:
         *   code — int64 code.
         *
         * Does not return a value.
         */
        void exit(int64 code)

        /*
         * Handles abort for this System by calling the native function
         * cwhip_system_abort.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void abort()

        /*
         * Returns StandardIO().
         *
         * Takes no parameters.
         *
         * Returns StandardIO.
         */
        StandardIO io() {
            return(StandardIO())
        }

        /*
         * Handles last error for this System by calling the native function
         * cwhip_system_last_error.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String lastError()

        /*
         * Returns File(path, mode).
         *
         * Parameters:
         *   path — String path.
         *   mode — String mode.
         *
         * Returns File.
         */
        File open(String path, String mode) {
            return(File(path, mode))
        }

        /*
         * Returns FileSystem().exists(path).
         *
         * Parameters:
         *   path — String path.
         *
         * Returns bool.
         */
        bool exists(String path) {
            return(FileSystem().exists(path))
        }

        /*
         * Returns Process().getEnv(name).
         *
         * Parameters:
         *   name — String name.
         *
         * Returns String.
         */
        String getEnv(String name) {
            return(Process().getEnv(name))
        }
    }

    String System.lastError() from "cwhip_system_last_error"

    void System.exit(int64 code) from "cwhip_system_exit"

    void System.abort() from "cwhip_system_abort"

}
