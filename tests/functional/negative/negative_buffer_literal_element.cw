/*
 * tests/functional/negative/negative_buffer_literal_element.cw
 *
 * Buffer literal elements must have type int64 or uint64.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    buffer bytes = buffer[65, false]
}
