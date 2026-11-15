/*
 * stdlib/cli/0.1.0/positional.cw — one registered positional argument.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Cli {

    /*
     * Positional is a class in this standard-library package.
     *
     * It groups the data used by the surrounding program.
     */
    class Positional {
        public:
        String name = ""
        String description = ""
        bool required = false
        bool isList = false
    }
}
