/*
 * tests/functional/negative/negative_checked_extraction_mismatch.cw
 *
 * Rejects checked extraction mismatch.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    list values = [true]
    int64 result = values[0] as int64
}
