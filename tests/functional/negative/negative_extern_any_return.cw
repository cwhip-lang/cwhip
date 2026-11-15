/*
 * tests/functional/negative/negative_extern_any_return.cw
 *
 * Rejects declared any types in native method return values.
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
 * Its methods include dynamicValue.
 */
class Native {
    public:
    /*
     * Handles dynamic value for this Native by calling the native function
     * some_symbol.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns any.
     */
    any dynamicValue(int64 value)
}

any Native.dynamicValue(int64 value) from "some_symbol"

start {
    print(1)
}
