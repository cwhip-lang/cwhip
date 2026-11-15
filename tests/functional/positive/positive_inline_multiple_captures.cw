/*
 * tests/functional/positive/positive_inline_multiple_captures.cw
 *
 * Passes both a 64-bit integer and a string into one inline C block.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 count = 9223372036854775807
    strg message = "answer"
    inline (int64 count, strg message) {
        printf("%s: %lld\n", cwhip_string_cstr(message), (long long)*count);
    }
}
