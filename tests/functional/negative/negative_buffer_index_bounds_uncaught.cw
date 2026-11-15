/*
 * tests/functional/negative/negative_buffer_index_bounds_uncaught.cw
 *
 * Raises when a buffer index is below the negative length.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    buffer values = buffer(2)
    uint64 value = values[-3]
}
