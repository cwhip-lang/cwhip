/*
 * tests/functional/positive/positive_package_import.cw
 *
 * Checks package import.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import native_math as Math

start {
    Math math = Math()
    print(math.answer())
}
