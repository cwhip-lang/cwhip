/*
 * tests/functional/positive/positive_escape_e.cw
 *
 * Checks that double-quoted \e emits the ESC byte.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    print("\e")
}
