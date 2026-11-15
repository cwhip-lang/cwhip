/*
 * tests/functional/negative/negative_map_numeric_key.cw
 *
 * Rejects indexing a dict with an integer key rather than a string.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    dict values = [:]
    strg value = values[0]
}
