/*
 * tests/functional/positive/positive_include_once.cw
 *
 * Includes the same source twice and verifies it is processed only once.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "../include_parts/once.cw"
include "../include_parts/once.cw"

start {
    IncludedOnce value = IncludedOnce()
    print(value.answer())
}
