/*
 * tests/functional/negative/negative_buffer_element_bool.cw
 *
 * Rejects writing a bool into a byte buffer.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    buffer bytes = buffer(1)
    bytes[0] = true
}
