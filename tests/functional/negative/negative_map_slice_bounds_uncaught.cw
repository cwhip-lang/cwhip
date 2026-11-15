/*
 * tests/functional/negative/negative_map_slice_bounds_uncaught.cw
 *
 * Raises an uncaught runtime error when a dict slice extends beyond its
 * entries.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    dict values = ["first": 1, "second": 2]
    dict copy = values[0:3]
    print(copy.length)
}
