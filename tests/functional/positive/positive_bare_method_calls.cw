/*
 * tests/functional/positive/positive_bare_method_calls.cw
 *
 * Checks bare method calls.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Its methods include step, run, sum.
 */
class Counter {
    public:
    int64 value

    /*
     * Stores value + 1 in value.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void step() {
        value = value + 1
    }

    /*
     * Handles run for this Counter.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        step()
        print(value)
    }

    /*
     * Handles sum for this Counter.
     *
     * Parameters:
     *   n — int64 input value.
     *
     * Returns int64.
     */
    int64 sum(int64 n) {
        if (n == 0) {
            return(0)
        }
        return(n + sum(n - 1))
    }
}

start {
    Counter counter = Counter()
    counter.run()
    print(counter.sum(4))
}
