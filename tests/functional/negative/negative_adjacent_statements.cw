/*
 * tests/functional/negative/negative_adjacent_statements.cw
 *
 * Rejects two statements placed on one line without a newline or other
 * statement boundary.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 first = 1 int64 second = 2
    print(first)
}
