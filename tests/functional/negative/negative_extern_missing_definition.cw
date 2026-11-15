/*
 * tests/functional/negative/negative_extern_missing_definition.cw
 *
 * Rejects a bodyless method declaration that has no out-of-line definition.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Native is a class, used as a fixture by this test.
 *
 * Its methods include missing.
 */
class Native {
    public:
    /*
     * Handles missing for this Native.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 missing(int64 value)
}

start {
    print(1)
}
