/*
 * tests/functional/negative/negative_int_condition.cw
 *
 * Rejects integer truthiness in an if condition now that conditions require
 * bool.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    if (1) {
        print(1)
    }
}
