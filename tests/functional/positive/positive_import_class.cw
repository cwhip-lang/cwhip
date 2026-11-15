/*
 * tests/functional/positive/positive_import_class.cw
 *
 * Verifies a registered module can import a class and invoke its method.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import greeting as Greeter

start {
    print(Greeter().answer())
}
