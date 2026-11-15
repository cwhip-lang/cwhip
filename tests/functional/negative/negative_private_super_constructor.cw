/*
 * tests/functional/negative/negative_private_super_constructor.cw
 *
 * Rejects a derived constructor calling an inaccessible private base
 * constructor.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Base is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Base {
    private:
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
class Child : public Base {
    public:
    /*
     * Constructs a Child.
     *
     * Takes no parameters.
     *
     * Returns the constructed Child.
     */
    Child() {
        super Base()
    }
}

start {
}
