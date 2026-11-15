/*
 * tests/functional/negative/negative_inline_undefined_capture.cw
 *
 * Rejects capturing a name that is not defined in the surrounding function.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    inline (int64 missing) {
        (void)missing;
    }
}
