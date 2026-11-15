/*
 * tests/functional/positive/positive_include_cycle.cw
 *
 * Verifies cyclic source includes terminate and expose declarations from the
 * included cycle.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "../include_parts/cycle_a.cw"

start {
    CycleValue value = CycleValue()
    print(value.answer())
}
