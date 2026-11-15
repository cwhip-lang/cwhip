/*
 * tests/functional/include_parts/cycle_a.cw — cycle a.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "cycle_b.cw"

/*
 * CycleValue is a class, used as a fixture by this test.
 *
 * Its methods include answer.
 */
class CycleValue {
    public:
    /*
     * Returns 9.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 answer() {
        return(9)
    }
}
