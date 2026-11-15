/*
 * tests/functional/negative/negative_namespace_unresolved.cw
 *
 * Rejects construction through a qualified class name absent from the declared
 * namespace.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Known {

    /*
     * Present is a class, used as a fixture by this test.
     *
     * It groups the data used by the surrounding program.
     */
    class Present {
    }
}

start {
    Known.Missing item = Known.Missing()
}
