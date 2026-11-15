/*
 * tests/functional/negative/negative_inline_type_mismatch_capture.cw
 *
 * Rejects declaring a string variable as an int64 capture in inline C.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg value = "text"
    inline (int64 value) {
        (void)value;
    }
}
