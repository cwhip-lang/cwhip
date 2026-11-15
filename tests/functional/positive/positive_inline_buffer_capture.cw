/*
 * tests/functional/positive/positive_inline_buffer_capture.cw
 *
 * Checks inline buffer capture.
 *
 * Created: 2026-10-09
 * Author: chuck
 *
 * Changelog:
 *   2026-10-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    buffer bytes = buffer(2)
    inline (buffer bytes) {
        cwhip_buffer_resize(*bytes, 3, "<inline>", 8, 1, 1);
        cwhip_buffer_set(*bytes, 0, 65, "<inline>", 8, 1, 1);
    }
    print(bytes.length)
    print(bytes[0])
}
