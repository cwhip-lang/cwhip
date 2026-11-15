/*
 * stdlib/cli/0.1.0/option.cw — one registered command-line option.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Cli {

    /*
     * Option is a class in this standard-library package.
     *
     * It groups the data used by the surrounding program.
     */
    class Option {
        public:
        String shortName = ""
        String longName = ""
        String name = ""
        String description = ""
        int64 valueType = 0
        bool isList = false
        String listSeparator = ":"
        bool required = false
        bool hasDefault = false
        String defaultValue = ""
        int64 action = 0
    }
}
