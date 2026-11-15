/*
 * tests/functional/modules/packages/shared/2.0.0/src/shared.cw — shared.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * SharedTwo is a class, used as a fixture by this test.
 *
 * Its methods include version.
 */
class SharedTwo {
    public:
    /*
     * Returns 2.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 version() {
        return(2)
    }
}
