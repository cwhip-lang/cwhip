/*
 * stdlib/system/0.1.0/glob.cw — System.Glob from the system package.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace System {
    /*
     * Glob is a class in this standard-library package.
     *
     * Its methods include glob.
     */
    class Glob {
        public:
        /*
         * Handles glob for this Glob by calling the native function
         * cwhip_glob_glob.
         *
         * Parameters:
         *   pattern — String pattern.
         *
         * Returns list.
         */
        list glob(String pattern)
    }
}
