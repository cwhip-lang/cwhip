/*
 * tests/functional/negative/negative_declaration_after_start.cw
 *
 * Rejects declarations placed after the top-level start block.
 *
 * Created: 2026-10-29
 * Author: chuck
 *
 * Changelog:
 *   2026-10-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    print("hi")
}

/*
 * TooLate is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class TooLate {
}
