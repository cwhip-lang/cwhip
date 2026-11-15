/*
 * tests/functional/positive/positive_debug_info.cw — Checks debug info.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Number is a class, used as a fixture by this test.
 *
 * Its methods include double.
 */
class Number {
    public:
    /*
     * Handles double for this Number.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 double(int64 value) {
        int64 doubled = value * 2
        return(doubled)
    }
}
start {
    int64 debugger_local = 42
    print(debugger_local)
    Number number = Number()
    int64 answer = number.double(21)
    answer = answer + 1
    answer = answer + 1
}
