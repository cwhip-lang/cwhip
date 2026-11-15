/*
 * tests/functional/negative/negative_raise_nonconstructor.cw
 *
 * Rejects raise nonconstructor.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Box is a class derived from Exception, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Box : Exception {
    public:
    /*
     * Constructs a Box.
     *
     * Takes no parameters.
     *
     * Returns the constructed Box.
     */
    Box() {
        super Exception("box")
    }
}
start {
    Box error = Box()
    raise(error)
}
