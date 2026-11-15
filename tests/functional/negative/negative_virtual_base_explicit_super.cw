/*
 * tests/functional/negative/negative_virtual_base_explicit_super.cw
 *
 * Rejects ordinary super Base syntax for a virtual base, which requires super
 * virtual.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Root is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Root {
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Left : virtual Root {
    public:
    /*
     * Constructs a Left.
     *
     * Takes no parameters.
     *
     * Returns the constructed Left.
     */
    Left() {
        super Root()
    }
}

start {
}
