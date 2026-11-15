/*
 * tests/functional/negative/negative_float_remainder.cw
 *
 * Rejects remainder because it is not defined for floating-point operands.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    fp64 invalid = 4.0 % 2.0
}
