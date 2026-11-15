/*
 * tests/functional/negative/negative_map_literal_key.cw
 *
 * Rejects a dict literal whose key is an integer instead of a string literal.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    dict values = [1: "value"]
}
