/*
 * tests/functional/negative/negative_dotted_base_initializer.cw
 *
 * Dotted forms are no longer valid base-initializer syntax.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
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
        super.Base()
    }
}

start {
}
