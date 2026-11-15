/*
 * tests/functional/negative/negative_map_missing_key.cw
 *
 * Raises an uncaught runtime error when indexing a dict with an absent key.
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
    print(values["missing"])
}
