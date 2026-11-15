/*
 * tests/functional/negative/negative_compound_division_overflow.cw
 *
 * Signed minimum divided by negative one must use the ordinary overflow check.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 value = -9223372036854775808
    value /= -1
}
