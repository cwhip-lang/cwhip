/*
 * tests/functional/negative/negative_unmatched_constructor_arity.cw
 *
 * Rejects unmatched constructor arity.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * OnlyOne is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class OnlyOne {
    public:
    /*
     * Constructs a OnlyOne.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed OnlyOne.
     */
    OnlyOne(int64 value) {
    }
}

start {
    OnlyOne value = OnlyOne()
}
