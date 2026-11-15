/*
 * tests/functional/negative/negative_protected_member.cw
 *
 * Rejects calling a protected method from outside its class hierarchy.
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
    protected:
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
