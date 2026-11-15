/*
 * tests/functional/positive/positive_integer_control_flow.cw
 *
 * Exercises integer comparison, modulo, branching, assignment, and repeated
 * loop execution.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int64 counter = 0
    int64 total = 0
    while (counter < 5) {
        counter = counter + 1
        if (counter % 2 == 0) {
            total = total + counter
        }
        else {
            total = total + 1
        }
    }
    print(total)
}
