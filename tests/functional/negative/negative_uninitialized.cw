/*
 * tests/functional/negative/negative_uninitialized.cw
 *
 * Rejects reading a local integer before any value has been assigned to it.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 value
    print(value)
}
