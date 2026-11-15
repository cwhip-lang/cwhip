/*
 * tests/functional/include_parts/namespace_left.cw — namespace left.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Library {

    /*
     * Left is a class, used as a fixture by this test.
     *
     * Its methods include answer.
     */
    class Left {
        public:
        /*
         * Returns 17.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 answer() {
            return(17)
        }
    }
}
