/*
 * tests/functional/negative/negative_array_iteration_arity.cw
 *
 * Rejects binding both a key and value while iterating an list, which supplies
 * values only.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [1, 2]
    for (key, value in values) {
        print(value)
    }
}
