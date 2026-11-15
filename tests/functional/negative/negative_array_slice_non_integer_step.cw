/*
 * tests/functional/negative/negative_array_slice_non_integer_step.cw
 *
 * Rejects a non-integer list slice step.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [1, 2, 3]
    list invalid = values[::"two"]
}
