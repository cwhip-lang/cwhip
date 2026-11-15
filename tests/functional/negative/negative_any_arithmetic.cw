/*
 * tests/functional/negative/negative_any_arithmetic.cw
 *
 * Rejects using an internal dynamic collection value as an arithmetic operand.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [1]
    int64 sum = values[0] + 1
}
