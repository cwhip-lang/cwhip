/*
 * tests/functional/negative/negative_native_constructor.cw
 *
 * Rejects native constructor.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * NativeCtor is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class NativeCtor {
    public:
    /*
     * Constructs a NativeCtor.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed NativeCtor.
     */
    NativeCtor(int64 value)
}

NativeCtor NativeCtor.NativeCtor(int64 value) from "native_ctor"

start {
    NativeCtor value = NativeCtor(1)
}
