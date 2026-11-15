/*
 * tests/functional/negative/negative_compound_division_by_zero.cw
 *
 * Compound integer division by zero must use the ordinary arithmetic runtime
 * check.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 value = 1
    value /= 0
}
