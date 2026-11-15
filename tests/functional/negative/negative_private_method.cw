/*
 * tests/functional/negative/negative_private_method.cw
 *
 * Rejects calling a private method through an external object reference.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Hidden is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class Hidden {
    private:
    /*
     * Returns 1.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(1)
    }
}

start {
    Hidden hidden = Hidden()
    print(hidden.read())
}
