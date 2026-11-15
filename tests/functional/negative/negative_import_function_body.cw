/*
 * tests/functional/negative/negative_import_function_body.cw
 *
 * Rejects an import declaration inside the start function body.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    import network as Net
}
