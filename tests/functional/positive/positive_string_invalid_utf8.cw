/*
 * tests/functional/positive/positive_string_invalid_utf8.cw
 *
 * Checks string invalid utf8.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg value = "valid"
    try {
        inline (strg value) {
            const char invalid[] = { (char)0xc0 };
            cwhip_string_append_bytes(*value, invalid, 1);
        }
    }
    except() as error {
        print(error)
    }
    print(value)
}
