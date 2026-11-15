/*
 * tests/functional/negative/negative_unsigned_int_mixing.cw
 *
 * Rejects arithmetic between unsigned and signed 64-bit values with no common
 * type.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    uint64 unsignedValue = 1u
    int64 signedValue = 1
    uint64 invalid = unsignedValue + signedValue
}
