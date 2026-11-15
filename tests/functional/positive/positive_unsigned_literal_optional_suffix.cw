/*
 * tests/functional/positive/positive_unsigned_literal_optional_suffix.cw
 *
 * Exercises the optional 'u' suffix: an unsuffixed integer literal is a valid
 * unsigned literal wherever the context already expects `unsigned`.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Its methods include constructor, get.
 */
class Counter {
    public:
    uint64 value

    /*
     * Constructs a Counter and stores value.
     *
     * Parameters:
     *   initial — uint64 initial.
     *
     * Returns the constructed Counter.
     */
    Counter(uint64 initial) {
        value = initial
    }

    /*
     * Returns 7.
     *
     * Takes no parameters.
     *
     * Returns uint64.
     */
    uint64 get() {
        return(7)
    }
}

start {
    uint64 declared = 5
    print(declared)

    uint64 assigned = 0u
    assigned = 9
    print(assigned)

    uint64 large = 5000000000
    print(large)

    Counter counter = Counter(3)
    print(counter.value)
    print(counter.get())

    int64 plain = 5
    print(plain)
}
