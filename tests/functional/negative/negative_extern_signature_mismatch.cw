/*
 * tests/functional/negative/negative_extern_signature_mismatch.cw
 *
 * Rejects an out-of-line definition whose parameter and return types differ
 * from its declaration.
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
 * Its methods include absolute.
 */
class Native {
    public:
    /*
     * Handles absolute for this Native.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 absolute(int64 value)
}

/*
 * Handles absolute for this Native by calling the native function
 * cwhip_method_demo_abs.
 *
 * Parameters:
 *   value — strg value.
 *
 * Returns strg.
 */
strg Native.absolute(strg value) from "cwhip_method_demo_abs"

start {
    print(1)
}
