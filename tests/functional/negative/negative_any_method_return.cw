/*
 * tests/functional/negative/negative_any_method_return.cw
 *
 * Rejects an any-typed method return value.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Holder is a class, used as a fixture by this test.
 *
 * Its methods include value.
 */
class Holder {
    public:
    /*
     * Returns 1.
     *
     * Takes no parameters.
     *
     * Returns any.
     */
    any value() {
        return(1)
    }
}

start {
    print(1)
}
