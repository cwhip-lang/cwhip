/*
 * tests/functional/negative/negative_handle_length.cw
 *
 * Rejects built-in member access on an opaque handle.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    handle resource = null
    int64 size = resource.length
}
