/*
 * tests/functional/negative/negative_partial_return.cw
 *
 * Rejects partial return.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * PartialReturn is a class, used as a fixture by this test.
 *
 * Its methods include value.
 */
class PartialReturn {
    public:
    /*
     * Returns 1.
     *
     * Parameters:
     *   choose — bool choose.
     *
     * Returns int64.
     */
    int64 value(bool choose) {
        if (choose) {
            return(1)
        }
    }
}

start {
}
