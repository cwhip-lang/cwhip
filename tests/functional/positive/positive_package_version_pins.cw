/*
 * tests/functional/positive/positive_package_version_pins.cw
 *
 * Checks package version pins.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import shared as Selected
import alpha as Alpha

start {
    Selected selected = Selected()
    Alpha alpha = Alpha()
    print(selected.version())
    print(alpha.version())
}
