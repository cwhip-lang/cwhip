/*
 * tests/functional/negative/negative_include_start.cw
 *
 * Rejects an included source file that declares its own top-level start block.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "../include_parts/with_start.cw"

start {
}
