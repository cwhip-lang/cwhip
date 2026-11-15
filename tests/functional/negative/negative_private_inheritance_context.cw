/*
 * tests/functional/negative/negative_private_inheritance_context.cw
 *
 * Rejects accessing a privately inherited field from a further-derived class.
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
 * It groups the data used by the surrounding program.
 */
class Base {
    public:
    int64 value
}

/*
 * PrivateChild is a class derived from Base, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class PrivateChild : private Base {
}

/*
 * Grandchild is a class derived from PrivateChild, used as a fixture by this
 * test.
 *
 * Its methods include readValue.
 */
class Grandchild : public PrivateChild {
    public:
    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 readValue() {
        return(value)
    }
}

start {
}
