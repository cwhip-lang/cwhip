/*
 * tests/functional/cli/include/relative/relative.cw — relative.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "search_target.cw"
start {
    SearchTarget target = SearchTarget()
    print(target.answer())
}
