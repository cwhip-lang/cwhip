/*
 * tests/functional/negative/negative_string_condition.cw
 *
 * Rejects using a string expression as an if condition, which requires bool.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    if ("not an integer") {
        print(1)
    }
}
