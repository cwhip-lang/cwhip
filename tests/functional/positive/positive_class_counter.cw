/*
 * tests/functional/positive/positive_class_counter.cw
 *
 * Verifies object fields can be updated by methods and then read through both
 * methods and direct member access.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Its methods include constructor, add, get.
 */
class Counter {
    public:
    int64 value

    /*
     * Constructs a Counter and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Counter.
     */
    Counter(int64 initial) {
        value = initial
    }

    /*
     * Returns value + amount.
     *
     * Parameters:
     *   amount — int64 amount.
     *
     * Returns int64.
     */
    int64 add(int64 amount) {
        value = value + amount
        return(value)
    }

    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 get() {
        return(value)
    }
}

start {
    Counter counter = null
    counter = Counter(40)
    print(counter.add(2))
    print(counter.get())
    print(counter.value)
}
