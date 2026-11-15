/*
 * tests/functional/negative/negative_import_namespace_body.cw
 *
 * Rejects an import declaration nested inside a namespace body.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Hidden {
    import network as Net
}

start {}
