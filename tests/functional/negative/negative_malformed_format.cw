/*
 * tests/functional/negative/negative_malformed_format.cw
 *
 * Rejects a formatted string containing a malformed placeholder name.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    print(format("value: {x-y}", x=1))
}
