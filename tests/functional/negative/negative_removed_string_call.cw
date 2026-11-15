/*
 * tests/functional/negative/negative_removed_string_call.cw
 *
 * Rejects removed string call.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    strg text = "{}"(42)
    print(text)
}
