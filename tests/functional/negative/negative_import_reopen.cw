/*
 * tests/functional/negative/negative_import_reopen.cw
 *
 * Rejects declaring a local namespace that conflicts with an imported alias.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import network as Net

namespace Net {

    /*
     * Local is a class, used as a fixture by this test.
     *
     * It groups the data used by the surrounding program.
     */
    class Local {
    }
}

start {
}
