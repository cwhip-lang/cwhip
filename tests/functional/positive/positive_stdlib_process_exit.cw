/*
 * tests/functional/positive/positive_stdlib_process_exit.cw
 *
 * Checks stdlib process exit.
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
    Sys.Process().exit(37)
}
