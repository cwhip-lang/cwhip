/*
 * tests/functional/negative/negative_array_resize_type.cw
 *
 * Rejects array resize type.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = []
    values.resize("large")
}
