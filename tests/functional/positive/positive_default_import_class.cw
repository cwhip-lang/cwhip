/*
 * tests/functional/positive/positive_default_import_class.cw
 *
 * Checks default import class.
 *
 * Created: 2026-10-05
 * Author: chuck
 *
 * Changelog:
 *   2026-10-05  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import greeting
import greeting as Hello

start {
    print(Greeter().answer())
    print(Hello().answer())
}
