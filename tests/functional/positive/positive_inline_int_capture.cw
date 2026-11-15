/*
 * tests/functional/positive/positive_inline_int_capture.cw
 *
 * Verifies inline C can mutate a captured integer and the change is visible to
 * Cwhip code.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 value = 7
    inline (int64 value) {
        *value += 5;
    }
    print(value)
}
