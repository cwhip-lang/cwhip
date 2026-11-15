/*
 * tests/functional/negative/negative_private_destructor.cw
 *
 * Rejects calling a class destructor that is private to outside code.
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
 * It groups the data used by the surrounding program.
 */
class Hidden {
    private:
    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
    }
}

start {
    Hidden hidden = Hidden()
    hidden.destroy()
}
