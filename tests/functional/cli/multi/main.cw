/*
 * tests/functional/cli/multi/main.cw — main.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    Shared.Helper helper = Shared.Helper()
    print(helper.get() + 2)
}
