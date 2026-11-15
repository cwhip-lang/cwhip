/*
 * tests/functional/negative/negative_string_byte_at.cw
 *
 * Rejects string byte at.
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
    print(text.byteAt(0))
}
