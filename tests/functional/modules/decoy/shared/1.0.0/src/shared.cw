/*
 * tests/functional/modules/decoy/shared/1.0.0/src/shared.cw — shared.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * SharedOne is a class, used as a fixture by this test.
 *
 * Its methods include version.
 */
class SharedOne {
    public:
    /*
     * Returns 1.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 version() {
        return(1)
    }
}
