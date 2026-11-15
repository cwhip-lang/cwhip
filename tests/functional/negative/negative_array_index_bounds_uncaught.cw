/*
 * tests/functional/negative/negative_array_index_bounds_uncaught.cw
 *
 * Raises when an list index is below the negative length.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [1, 2]
    int64 value = values[-3]
}
