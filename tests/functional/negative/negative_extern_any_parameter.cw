/*
 * tests/functional/negative/negative_extern_any_parameter.cw
 *
 * Rejects declared any types in native method parameters.
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
 * Its methods include use.
 */
class Native {
    public:
    /*
     * Handles use for this Native by calling the native function some_symbol.
     *
     * Parameters:
     *   value — any value.
     *
     * Returns int64.
     */
    int64 use(any value)
}

int64 Native.use(any value) from "some_symbol"

start {
    print(1)
}
