/*
 * tests/functional/negative/negative_else_if.cw
 *
 * Else-if syntax is not supported; conditional alternatives use else
 * (condition).
 *
 * Created: 2026-10-24
 * Author: chuck
 *
 * Changelog:
 *   2026-10-24  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    if (1 == 1) {
    } else if (1 == 2) {
    }
}
