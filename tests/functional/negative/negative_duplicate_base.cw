/*
 * tests/functional/negative/negative_duplicate_base.cw
 *
 * Rejects listing the same base class twice in one inheritance declaration.
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
 * It groups the data used by the surrounding program.
 */
class Base {
}

/*
 * Duplicate is a class derived from Base, Base, used as a fixture by this
 * test.
 *
 * It groups the data used by the surrounding program.
 */
class Duplicate : Base, Base {
}

start {
}
