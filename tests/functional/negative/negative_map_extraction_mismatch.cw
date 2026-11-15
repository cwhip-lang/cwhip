/*
 * tests/functional/negative/negative_map_extraction_mismatch.cw
 *
 * Raises a runtime error when an integer-valued any is extracted as a dict.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [7]
    dict invalid = values[0]
}
