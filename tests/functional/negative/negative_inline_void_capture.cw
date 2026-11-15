/*
 * tests/functional/negative/negative_inline_void_capture.cw
 *
 * Rejects a void-typed inline C capture because it cannot represent a variable
 * value.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    inline (void value) {
        (void)value;
    }
}
