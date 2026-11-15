/*
 * tests/functional/negative/negative_float_int_mixing.cw
 *
 * Rejects arithmetic between signed and unsigned 64-bit values with no common
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
    int64 signedValue = 1
    uint64 unsignedValue = 1u
    int64 invalid = signedValue + unsignedValue
}
