/*
 * stdlib/cli/0.1.0/action.cw — actions a command-line option can request.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Cli {

    /*
     * Action is a class in this standard-library package.
     *
     * It groups the data used by the surrounding program.
     */
    class Action {
        public:
        int64 NONE = 0
        int64 HELP = 1
        int64 VERSION = 2
        # Help and version stop parsing. Any other action keeps parsing so
        # later flags are still checked, and required arguments are not
        # enforced once an action is set.
        int64 DUMP_CONFIG = 3
    }
}
