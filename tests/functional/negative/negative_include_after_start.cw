/*
 * tests/functional/negative/negative_include_after_start.cw
 *
 * Rejects an include directive placed after the top-level start block.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
}

include "../include_parts/empty.cw"
