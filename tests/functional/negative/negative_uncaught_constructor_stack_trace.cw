/*
 * tests/functional/negative/negative_uncaught_constructor_stack_trace.cw
 *
 * Constructor failures include the constructor and its Cwhip caller.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Maker is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Maker {
    public:
    /*
     * Constructs a Maker.
     *
     * Takes no parameters.
     *
     * Returns the constructed Maker.
     */
    Maker() {
        raise(Exception("constructor trace sentinel"))
    }
}
start {
    print("begin")
    Maker maker = Maker()
}
