/*
 * tests/functional/positive/positive_control_flow.cw
 *
 * Verifies case-insensitive keywords, conditional branches, formatted strings,
 * and while-loop execution.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

START {
    int64 count = 3
    strg label = "count: {}"
    IF (count >= 2) {
        print(label)
    }
    ELSE {
        print("small")
    }
    while (count > 0) {
        count = count - 1
    }
}
