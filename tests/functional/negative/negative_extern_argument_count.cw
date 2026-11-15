/*
 * tests/functional/negative/negative_extern_argument_count.cw
 *
 * Rejects a native-bound method call with more arguments than its declaration.
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
     * Handles absolute for this Native by calling the native function
     * cwhip_method_demo_abs.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 absolute(int64 value)
}

int64 Native.absolute(int64 value) from "cwhip_method_demo_abs"

start {
    print(Native().absolute(1, 2))
}
