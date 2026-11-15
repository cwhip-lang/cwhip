/*
 * tests/functional/negative/negative_any_member_access.cw
 *
 * Rejects member lookup on an internal dynamic collection value.
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
    print(values[0].length)
}
