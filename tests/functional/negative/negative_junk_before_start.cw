/*
 * tests/functional/negative/negative_junk_before_start.cw
 *
 * Rejects unexpected tokens before the top-level start block.
 *
 * Created: 2026-10-29
 * Author: chuck
 *
 * Changelog:
 *   2026-10-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

int64 value = 1
start {
    print("hi")
}
