/*
 * tests/functional/negative/negative_protected_base_conversion.cw
 *
 * Rejects converting a protectedly derived object to its inaccessible base
 * type.
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
}

/*
 * ProtectedChild is a class derived from Base, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class ProtectedChild : protected Base {
}

start {
    ProtectedChild child = ProtectedChild()
    Base base = child
}
