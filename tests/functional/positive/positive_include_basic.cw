/*
 * tests/functional/positive/positive_include_basic.cw
 *
 * Includes a support file that declares a class, then constructs it and calls
 * its method.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "../include_parts/basic.cw"

start {
    IncludedValue value = IncludedValue()
    print(value.answer())
}
