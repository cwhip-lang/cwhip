/*
 * tests/functional/negative/negative_inheritance_cycle.cw
 *
 * Rejects two classes whose base declarations form an inheritance cycle.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * First is a class derived from Second, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class First : Second {
}

/*
 * Second is a class derived from First, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Second : First {
}
start {
}
