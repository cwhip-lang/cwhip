/*
 * tests/functional/negative/negative_any_method_parameter.cw
 *
 * Rejects an any-typed method parameter.
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
 * Its methods include use.
 */
class Holder {
    public:
    /*
     * Returns 1.
     *
     * Parameters:
     *   value — any value.
     *
     * Returns int64.
     */
    int64 use(any value) {
        return(1)
    }
}

start {
    print(1)
}
