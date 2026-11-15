/*
 * tests/functional/negative/negative_private_inheritance.cw
 *
 * Rejects exposing a private base subobject through a qualified member access.
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

start {
    PrivateChild child = PrivateChild()
    print(child.Base.value)
}
