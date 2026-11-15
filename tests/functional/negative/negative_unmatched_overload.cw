/*
 * tests/functional/negative/negative_unmatched_overload.cw
 *
 * Rejects a call whose argument types match no overload. Cwhip has no implicit
 * conversions, so overload resolution is an exact-match rule: a bool argument
 * does not silently select the int or float overload.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Printer is a class, used as a fixture by this test.
 *
 * Its methods include constructor, show.
 */
class Printer {
    public:
    /*
     * Constructs a Printer.
     *
     * Takes no parameters.
     *
     * Returns the constructed Printer.
     */
    Printer() {
    }

    /*
     * Returns the stored value.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 show(int64 value) {
        return(value)
    }

    /*
     * Returns 2.
     *
     * Parameters:
     *   value — fp64 value.
     *
     * Returns int64.
     */
    int64 show(fp64 value) {
        return(2)
    }
}

start {
    Printer p = Printer()
    bool flag = true
    print(p.show(flag))
}
