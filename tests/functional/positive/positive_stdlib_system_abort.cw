/*
 * tests/functional/positive/positive_stdlib_system_abort.cw
 *
 * Checks stdlib system abort.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system as Sys

start {
    Sys.System().abort()
}
