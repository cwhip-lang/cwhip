/*
 * tests/functional/negative/negative_map_slice_step.cw
 *
 * Rejects steps on insertion-order dict slices.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    dict values = ["a": 1]
    dict invalid = values[::2]
}
