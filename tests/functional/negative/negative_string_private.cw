/*
 * tests/functional/negative/negative_string_private.cw
 *
 * Rejects string private.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg text = "private"
    buffer leaked = text._bytes
}
