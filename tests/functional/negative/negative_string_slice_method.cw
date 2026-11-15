/*
 * tests/functional/negative/negative_string_slice_method.cw
 *
 * Rejects string slice method.
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
    print(text.slice(0, 2))
}
