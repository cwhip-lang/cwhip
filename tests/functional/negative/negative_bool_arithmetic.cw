/*
 * tests/functional/negative/negative_bool_arithmetic.cw
 *
 * Rejects arithmetic operators on the distinct bool type.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    bool invalid = true + false
}
