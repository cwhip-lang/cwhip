/*
 * tests/functional/positive/positive_start_return_nested.cw
 *
 * Checks start return nested.
 *
 * Created: 2026-11-02
 * Author: chuck
 *
 * Changelog:
 *   2026-11-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

start {
    int32 value = 0
    while (value < 10) {
        value = value + 1
        if (value == 3) {
            print("leaving")
            return(40 + value)
        }
    }
    print("not reached")
}
