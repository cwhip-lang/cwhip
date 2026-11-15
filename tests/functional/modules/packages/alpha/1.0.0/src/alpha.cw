/*
 * tests/functional/modules/packages/alpha/1.0.0/src/alpha.cw — alpha.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import shared as Shared

/*
 * Alpha is a class, used as a fixture by this test.
 *
 * Its methods include version.
 */
class Alpha {
    public:
    /*
     * Handles version for this Alpha.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 version() {
        Shared shared = Shared()
        return(shared.version())
    }
}
