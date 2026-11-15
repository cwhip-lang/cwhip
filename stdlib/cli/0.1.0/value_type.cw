/*
 * stdlib/cli/0.1.0/value_type.cw — value kinds for command-line options.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split from the package source.
 */

namespace Cli {

    /*
     * ValueType is a class in this standard-library package.
     *
     * It groups the data used by the surrounding program.
     */
    class ValueType {
        public:
        int64 FLAG = 0
        int64 COUNTER = 1
        int64 STRING = 2
        int64 NUMBER = 3
    }
}
