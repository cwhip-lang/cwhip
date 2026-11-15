/*
 * tests/functional/negative/negative_continue_outside_loop.cw
 *
 * Rejects continue when no while, do-while, or collection loop encloses it.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    continue
}
