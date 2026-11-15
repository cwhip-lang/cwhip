/*
 * tests/functional/negative/negative_string_remove_range.cw
 *
 * Rejects string remove range.
 *
 * Created: 2026-10-28
 * Author: chuck
 *
 * Changelog:
 *   2026-10-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg text = "abcd"
    text.removeRange(0, 2)
}
