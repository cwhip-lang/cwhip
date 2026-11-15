/*
 * tests/functional/include_parts/namespace_right.cw — namespace right.
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
     * Right is a class, used as a fixture by this test.
     *
     * Its methods include answer.
     */
    class Right {
        public:
        /*
         * Returns 25.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 answer() {
            return(25)
        }
    }
}
