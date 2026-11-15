/*
 * tests/functional/negative/negative_include_in_namespace_body.cw
 *
 * Rejects an include directive inside a namespace body.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Invalid {
    include "missing.cw"
}

start {}
