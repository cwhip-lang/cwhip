/*
 * tests/functional/negative/negative_buffer_equality.cw
 *
 * Rejects equality between two byte buffers while null comparison remains
 * allowed.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    buffer first = buffer(1)
    buffer second = buffer(1)
    bool same = first == second
}
