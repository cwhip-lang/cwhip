/*
 * tests/functional/negative/negative_duplicate_constructor.cw
 *
 * Rejects duplicate constructor.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Duplicate is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Duplicate {
    public:
    /*
     * Constructs a Duplicate.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Duplicate.
     */
    Duplicate(int64 value) {
    }

    /*
     * Constructs a Duplicate.
     *
     * Parameters:
     *   other — int64 other.
     *
     * Returns the constructed Duplicate.
     */
    Duplicate(int64 other) {
    }
}

start {
    Duplicate duplicate = Duplicate(1)
}
