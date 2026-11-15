/*
 * tests/functional/negative/negative_namespace_start.cw
 *
 * Rejects declaring the program start block inside a namespace.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Hidden {
    start {}
}
