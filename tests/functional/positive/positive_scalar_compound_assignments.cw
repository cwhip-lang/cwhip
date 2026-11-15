/*
 * tests/functional/positive/positive_scalar_compound_assignments.cw
 *
 * Exercises scalar compound arithmetic, field targets, and one-time receiver
 * evaluation.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Box is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Box {
    public:
    int64 value

    /*
     * Constructs a Box.
     *
     * Takes no parameters.
     *
     * Returns the constructed Box.
     */
    Box() {
    }
}

/*
 * Factory is a class, used as a fixture by this test.
 *
 * Its methods include constructor, get.
 */
class Factory {
    public:
    Box box
    int64 calls

    /*
     * Constructs a Factory and stores box.
     *
     * Parameters:
     *   value — Box value.
     *
     * Returns the constructed Factory.
     */
    Factory(Box value) {
        box = value
    }

    /*
     * Returns the Factory state.
     *
     * Takes no parameters.
     *
     * Returns Box.
     */
    Box get() {
        calls += 1
        return(box)
    }
}

start {
    int64 signed = 10
    signed += 5
    signed -= 2
    signed *= 3
    signed /= 2
    signed %= 4
    print(signed)

    uint64 count = 20u
    count += 5u
    count -= 5u
    count *= 2u
    count /= 4u
    count %= 3u
    print(count)

    fp64 measure = 5.0
    measure += 1.5
    measure -= 0.5
    measure *= 2.0
    measure /= 3.0
    print(measure)

    Box box = Box()
    box.value = 2
    Factory factory = Factory(box)
    factory.get().value += 3
    print(box.value)
    print(factory.calls)

    int64 wrapped = 9223372036854775807
    try {
        wrapped += 1
    }
    except() as error {
        print(error)
    }
    print(wrapped)
}
