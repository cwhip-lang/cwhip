/*
 * tests/functional/negative/negative_inline_duplicate_capture.cw
 *
 * Rejects listing the same variable more than once in an inline capture list.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 value = 1
    inline (int64 value, int64 value) {
        (void)value;
    }
}
