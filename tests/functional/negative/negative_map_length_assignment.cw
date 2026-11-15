/*
 * tests/functional/negative/negative_map_length_assignment.cw
 *
 * Rejects assigning to the read-only length property of a dict.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    dict values = [:]
    values.length = 1
}
