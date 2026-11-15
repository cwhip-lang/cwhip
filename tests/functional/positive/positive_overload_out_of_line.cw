/*
 * tests/functional/positive/positive_overload_out_of_line.cw
 *
 * Each overload binds to its own out-of-line definition: the declaration, the
 * definition, and the emitted symbol are all keyed by parameter types, not
 * just the method name.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Calc is a class, used as a fixture by this test.
 *
 * Its methods include scale.
 */
class Calc {
    public:
    /*
     * Handles scale for this Calc.
     *
     * Parameters:
     *   v — int64 input value.
     *
     * Returns int64.
     */
    int64 scale(int64 v)

    /*
     * Handles scale for this Calc.
     *
     * Parameters:
     *   v — int64 input value.
     *   by — int64 input value.
     *
     * Returns int64.
     */
    int64 scale(int64 v, int64 by)
}

int64 Calc.scale(int64 v) {
    return(v * 2)
}

int64 Calc.scale(int64 v, int64 by) {
    return(v * by)
}

start {
    Calc c = Calc()
    print(c.scale(5))
    print(c.scale(5, 3))
}
