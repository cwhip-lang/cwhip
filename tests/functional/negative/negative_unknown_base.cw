/*
 * tests/functional/negative/negative_unknown_base.cw
 *
 * Rejects a class declaration that names an undefined base class.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Derived is a class derived from Missing, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Derived : Missing {
}

start {
}
