/*
 * tests/functional/negative/negative_private_constructor.cw
 *
 * Rejects constructing a class through its private constructor from start
 * code.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Hidden is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Hidden {
    private:
    /*
     * Constructs a Hidden.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Hidden.
     */
    Hidden(int64 value) {
    }
}

start {
    Hidden hidden = Hidden(1)
}
