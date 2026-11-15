/*
 * tests/functional/modules/packages/greeting/1.2.0/greeting.cw — greeting.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Greeter is a class, used as a fixture by this test.
 *
 * Its methods include constructor, answer.
 */
class Greeter {
    public:
    /*
     * Constructs a Greeter.
     *
     * Takes no parameters.
     *
     * Returns the constructed Greeter.
     */
    Greeter() {
    }

    /*
     * Returns 42.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 answer() {
        return(42)
    }
}
