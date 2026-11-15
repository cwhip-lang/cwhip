/*
 * tests/functional/cli/multi/native.cw — native.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Native is a class, used as a fixture by this test.
 *
 * Its methods include get.
 */
class Native {
    public:
    /*
     * Returns the Native state by calling the native function
     * cwhip_multi_external_value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 get()
}
int64 Native.get() from "cwhip_multi_external_value"
start {
    Native native = Native()
    print(native.get())
}
