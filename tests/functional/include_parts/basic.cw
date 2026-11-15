/*
 * tests/functional/include_parts/basic.cw — basic.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * IncludedValue is a class, used as a fixture by this test.
 *
 * Its methods include answer.
 */
class IncludedValue {
    public:
    /*
     * Returns 42.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 answer() {
        return(42)
    }
}
