/*
 * tests/functional/negative/negative_aliased_import_canonical_constructor_
 * argument.cw
 *
 * Rejects aliased import canonical constructor argument.
 *
 * Created: 2026-10-12
 * Author: chuck
 *
 * Changelog:
 *   2026-10-12  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import system as sys

start {
    Exception error = Exception(System.System().lastError())
}
