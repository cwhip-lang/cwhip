/*
 * tests/functional/cli/include/first/search_target.cw — search target.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "nested_value.cw"

/*
 * SearchTarget is a class, used as a fixture by this test.
 *
 * Its methods include answer.
 */
class SearchTarget {
    public:
    /*
     * Handles answer for this SearchTarget.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 answer() {
        NestedValue nested = NestedValue()
        return(40 + nested.value())
    }
}
