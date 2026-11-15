/*
 * tests/functional/negative/negative_return_in_finally.cw
 *
 * Rejects return in finally.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * InvalidReturn is a class, used as a fixture by this test.
 *
 * Its methods include value.
 */
class InvalidReturn {
    public:
    /*
     * Handles value for this InvalidReturn.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 value() {
        try {
            return(1)
        }
        finally {
            if (true) {
                {
                    return(2)
                }
            }
        }
    }
}

start {
}
