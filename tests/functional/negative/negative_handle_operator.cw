/*
 * tests/functional/negative/negative_handle_operator.cw
 *
 * Rejects using an opaque handle as a non-null-check operator operand.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    handle first = null
    handle second = null
    bool same = first == second
}
