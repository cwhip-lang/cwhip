/*
 * tests/functional/positive/positive_inline_array_capture.cw
 *
 * Passes an list into inline C and verifies its length is visible both inside
 * C and in Cwhip.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [1, 2, 3]
    inline (list values) {
        printf("%llu\n", (unsigned long long)((CwhipArray *)*values)->length);
    }
    print(values.length)
}
