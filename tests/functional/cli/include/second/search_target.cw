/*
 * tests/functional/cli/include/second/search_target.cw — search target.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * SearchTarget is a class, used as a fixture by this test.
 *
 * Its methods include answer.
 */
class SearchTarget {
    public:
    /*
     * Returns 99.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 answer() {
        return(99)
    }
}
