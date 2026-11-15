/*
 * tests/functional/negative/negative_inheritance_missing_super.cw
 *
 * Rejects a derived constructor that does not initialize its direct base
 * first.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Base is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Base {
    public:
    /*
     * Constructs a Base.
     *
     * Takes no parameters.
     *
     * Returns the constructed Base.
     */
    Base() {
    }
}

/*
 * Child is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Child : Base {
    public:
    /*
     * Constructs a Child.
     *
     * Takes no parameters.
     *
     * Returns the constructed Child.
     */
    Child() {
    }
}

start {
}
