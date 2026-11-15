/*
 * stdlib/system/0.1.0/process.cw — System.Process from the system package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace System {
    /*
     * Process is a class in this standard-library package.
     *
     * Its methods include argc, argv, arg, exit, abort, getEnv, and 1 more.
     */
    class Process {
        public:
        /*
         * Handles argc for this Process by calling the native function
         * cwhip_system_argc.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 argc()

        /*
         * Handles argv for this Process by calling the native function
         * cwhip_system_argv.
         *
         * Takes no parameters.
         *
         * Returns list.
         */
        list argv()

        /*
         * Handles arg for this Process by calling the native function
         * cwhip_system_arg.
         *
         * Parameters:
         *   index — int64 index.
         *
         * Returns String.
         */
        String arg(int64 index)

        /*
         * Handles exit for this Process by calling the native function
         * cwhip_system_exit.
         *
         * Parameters:
         *   code — int64 code.
         *
         * Does not return a value.
         */
        void exit(int64 code)

        /*
         * Handles abort for this Process by calling the native function
         * cwhip_system_abort.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void abort()

        /*
         * Returns env for this Process by calling the native function
         * cwhip_system_getenv.
         *
         * Parameters:
         *   name — String name.
         *
         * Returns String.
         */
        String getEnv(String name)

        /*
         * Sets env for this Process by calling the native function
         * cwhip_system_setenv.
         *
         * Parameters:
         *   name — String name.
         *   value — String value.
         *
         * Returns bool.
         */
        bool setEnv(String name, String value)
    }
}
