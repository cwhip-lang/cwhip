/*
 * tests/functional/negative/negative_format_ascii_uncaught.cw
 *
 * Rejects format ascii uncaught.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 character = 128
    print("no partial output {:c}", character)
}
