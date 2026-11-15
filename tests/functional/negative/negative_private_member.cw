/*
 * tests/functional/negative/negative_private_member.cw
 *
 * Rejects reading a private field through an external object reference.
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
    int64 value

    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(value)
    }
}

start {
    Hidden hidden = Hidden()
    print(hidden.value)
}
