/*
 * tests/functional/negative/negative_buffer_slice_step.cw
 *
 * Rejects steps on buffer slices.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    buffer values = buffer(1)
    buffer invalid = values[::2]
}
