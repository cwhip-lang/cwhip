/*
 * tests/functional/negative/negative_namespace_statement.cw
 *
 * Rejects an executable print statement in a namespace body.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Hidden {
    print(42)
}
