/*
 * tests/functional/negative/negative_extern_missing_symbol.cw
 *
 * Fails to link when a native method names a C symbol that does not exist.
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
     * Handles missing for this Native by calling the native function
     * cwhip_symbol_that_does_not_exist.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 missing(int64 value)
}

int64 Native.missing(int64 value) from "cwhip_symbol_that_does_not_exist"

start {
    print(Native().missing(1))
}
