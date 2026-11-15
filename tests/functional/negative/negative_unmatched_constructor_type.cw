/*
 * tests/functional/negative/negative_unmatched_constructor_type.cw
 *
 * Rejects unmatched constructor type.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * OnlyInt is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class OnlyInt {
    public:
    /*
     * Constructs a OnlyInt.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed OnlyInt.
     */
    OnlyInt(int64 value) {
    }
}

start {
    OnlyInt value = OnlyInt("wrong")
}
