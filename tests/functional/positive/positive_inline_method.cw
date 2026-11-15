/*
 * tests/functional/positive/positive_inline_method.cw
 *
 * Uses an inline C block inside a method to update a captured parameter before
 * returning it.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Calculator is a class, used as a fixture by this test.
 *
 * Its methods include adjust.
 */
class Calculator {
    public:
    /*
     * Runs inline C while handling adjust.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 adjust(int64 value) {
        inline (int64 value) {
            *value += 2;
        }
        return(value)
    }
}

start {
    print(Calculator().adjust(40))
}
