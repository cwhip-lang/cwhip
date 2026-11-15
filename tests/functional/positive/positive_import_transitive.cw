/*
 * tests/functional/positive/positive_import_transitive.cw
 *
 * Checks a module can re-export a dependency that the importing program uses
 * transitively.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import wrapper as Wrap

start {
    print(Wrap().answer())
}
