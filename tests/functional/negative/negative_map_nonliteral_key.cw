/*
 * tests/functional/negative/negative_map_nonliteral_key.cw
 *
 * Rejects a dict lookup key whose static type is any rather than string.
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
    list keys = ["present"]
    dict value = values[keys[0]]
}
