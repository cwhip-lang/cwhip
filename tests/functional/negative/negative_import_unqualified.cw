/*
 * tests/functional/negative/negative_import_unqualified.cw
 *
 * Rejects using an imported module class without qualifying it through its
 * alias.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import network as Net

start {
    Network.Http.Client()
}
