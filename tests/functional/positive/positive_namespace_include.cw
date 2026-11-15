/*
 * tests/functional/positive/positive_namespace_include.cw
 *
 * Merges an included namespace fragment with a local declaration and calls
 * both classes.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "../includes/namespace_fragment.cw"

namespace Included {

    /*
     * Local is a class, used as a fixture by this test.
     *
     * Its methods include value.
     */
    class Local {
        public:
        /*
         * Returns 2.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 value() {
            return(2)
        }
    }
}

start {
    Included.Remote remote = Included.Remote()
    Included.Local local = Included.Local()
    print(remote.value() + local.value())
}
