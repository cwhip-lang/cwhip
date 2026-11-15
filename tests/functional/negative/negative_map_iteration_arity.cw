/*
 * tests/functional/negative/negative_map_iteration_arity.cw
 *
 * Rejects one-variable iteration over a dict, which requires key/value
 * bindings.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    dict values = ["key": 1]
    for (value in values) {
        print(value)
    }
}
