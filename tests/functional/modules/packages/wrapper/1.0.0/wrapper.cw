/*
 * tests/functional/modules/packages/wrapper/1.0.0/wrapper.cw — wrapper.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import greeting as G

/*
 * Wrapper is a class, used as a fixture by this test.
 *
 * Its methods include constructor, answer.
 */
class Wrapper {
    public:
    /*
     * Constructs a Wrapper.
     *
     * Takes no parameters.
     *
     * Returns the constructed Wrapper.
     */
    Wrapper() {
    }

    /*
     * Returns G().answer().
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 answer() {
        return(G().answer())
    }
}
