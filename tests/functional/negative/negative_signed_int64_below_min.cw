/*
 * tests/functional/negative/negative_signed_int64_below_min.cw
 *
 * Rejects signed int64 below min.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 invalid = -9223372036854775809
}
