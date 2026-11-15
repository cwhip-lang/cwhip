/*
 * tests/functional/negative/negative_do_while_condition.cw
 *
 * Rejects a do-while condition that does not have the required bool type.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg condition = "false"
    do {
        print(1)
    } while (condition)
}
