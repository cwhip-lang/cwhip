/*
 * tests/functional/negative/negative_imported_class_integer_enum_access.cw
 *
 * Rejects imported class integer enum access.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import enum_values as Values

start {
    print(Values.SECRET)
}
