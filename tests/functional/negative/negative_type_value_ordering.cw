/*
 * tests/functional/negative/negative_type_value_ordering.cw
 *
 * Rejects type value ordering.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    bool result = type(1) < type(2)
}
