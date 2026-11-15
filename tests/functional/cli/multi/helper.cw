/*
 * tests/functional/cli/multi/helper.cw — helper.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Shared {

    /*
     * Helper is a class, used as a fixture by this test.
     *
     * Its methods include get.
     */
    class Helper {
        public:
        /*
         * Returns 40.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 get() {
            return(40)
        }
    }
}
