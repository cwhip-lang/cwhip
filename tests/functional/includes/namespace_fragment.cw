/*
 * tests/functional/includes/namespace_fragment.cw — namespace fragment.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Included {

    /*
     * Remote is a class, used as a fixture by this test.
     *
     * Its methods include value.
     */
    class Remote {
        public:
        /*
         * Returns 40.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 value() {
            return(40)
        }
    }
}
