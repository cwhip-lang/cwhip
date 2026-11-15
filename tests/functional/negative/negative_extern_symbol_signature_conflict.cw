/*
 * tests/functional/negative/negative_extern_symbol_signature_conflict.cw
 *
 * Rejects reusing one C symbol for native methods with incompatible ABI
 * signatures.
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
 * Its methods include integerValue, stringValue.
 */
class Native {
    public:
    /*
     * Handles integer value for this Native by calling the native function
     * same_c_symbol.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 integerValue(int64 value)

    /*
     * Handles string value for this Native by calling the native function
     * same_c_symbol.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns strg.
     */
    strg stringValue(strg value)
}

int64 Native.integerValue(int64 value) from "same_c_symbol"
strg Native.stringValue(strg value) from "same_c_symbol"

start {
    print(1)
}
