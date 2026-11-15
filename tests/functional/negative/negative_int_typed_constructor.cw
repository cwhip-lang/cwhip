/*
 * tests/functional/negative/negative_int_typed_constructor.cw
 *
 * Rejects int typed constructor.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Its methods include Counter.
 */
class Counter {
    public:
    /*
     * Returns the stored start.
     *
     * Parameters:
     *   start — int start.
     *
     * Returns int.
     */
    int Counter(int start) {
        return(start)
    }
}
start {
    Counter c(1)
}
