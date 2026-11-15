/*
 * tests/functional/positive/positive_import_namespace.cw
 *
 * Verifies an imported namespace alias supports qualified nested-class
 * construction and calls.
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
    Net.Http.Client client()
    print(client.get("/"))
}
