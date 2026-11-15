/*
 * tests/functional/negative/negative_buffer_addition.cw
 *
 * Rejects using a byte buffer as an arithmetic operand.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    buffer first = buffer(1)
    buffer second = buffer(1)
    buffer combined = first + second
}
