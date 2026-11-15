/*
 * tests/functional/negative/negative_uncaught_division.cw
 *
 * Produces an uncaught runtime exception for integer division by zero.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    print(1 / 0)
}
