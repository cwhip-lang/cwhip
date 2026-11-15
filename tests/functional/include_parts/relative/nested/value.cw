/*
 * tests/functional/include_parts/relative/nested/value.cw — value.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * RelativeValue is a class, used as a fixture by this test.
 *
 * Its methods include answer.
 */
class RelativeValue {
    public:
    /*
     * Returns 33.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 answer() {
        return(33)
    }
}
