/*
 * tests/functional/negative/negative_include_in_function_body.cw
 *
 * Rejects an include directive inside a function body.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    include "missing.cw"
}
