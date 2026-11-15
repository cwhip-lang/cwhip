/*
 * tests/functional/positive/positive_inline_string_capture.cw
 *
 * Passes a Cwhip string into inline C and prints it through the runtime string
 * helper.
 *
 * Created: 2026-10-09
 * Author: chuck
 *
 * Changelog:
 *   2026-10-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg message = "hello from C"
    inline (strg message) {
        printf("%s\n", cwhip_string_cstr(message));
    }
}
