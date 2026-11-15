/*
 * tests/functional/negative/negative_unsupported_scalar_cast.cw
 *
 * Reference and string conversions are not scalar casts.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg text = "1"
    fp64 invalid = fp64(text)
}
