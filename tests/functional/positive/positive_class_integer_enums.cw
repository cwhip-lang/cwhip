/*
 * tests/functional/positive/positive_class_integer_enums.cw
 *
 * Checks class integer enums.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Values is a class, used as a fixture by this test.
 *
 * Its methods include read, echo.
 */
class Values {
    public:
    enum {
        FIRST = 123,
        NEXT,
        DOUBLE = FIRST * 2,
        MINIMUM = -0x8000000000000000,
        MAXIMUM = 0x7fffffffffffffff,
        SAME_VALUE = 123,
    }

    /*
     * Returns the stored FIRST.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(FIRST)
    }

    /*
     * Returns the stored value.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 echo(int64 value) {
        return(value)
    }
}

/*
 * Child is a class derived from Values, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Child : Values {
}

/*
 * Probe is a class, used as a fixture by this test.
 *
 * Its methods include constructor, next.
 */
class Probe {
    public:
    Values value
    int64 calls

    /*
     * Constructs a Probe and stores value, calls.
     *
     * Parameters:
     *   initial — Values initial.
     *
     * Returns the constructed Probe.
     */
    Probe(Values initial) {
        value = initial
        calls = 0
    }

    /*
     * Handles next for this Probe.
     *
     * Takes no parameters.
     *
     * Returns Values.
     */
    Values next() {
        calls += 1
        return(value)
    }
}

namespace Named {

    /*
     * Item is a class, used as a fixture by this test.
     *
     * It groups the data used by the surrounding program.
     */
    class Item {
        public:
        enum {
            VALUE = 50
        }
    }
}

start {
    Values values = Values()
    print(values.FIRST)
    print(Values.NEXT)
    print(values.DOUBLE)
    print(values.MINIMUM)
    print(values.MAXIMUM)
    print(values.SAME_VALUE)
    print(values.read())
    print(values.echo(Values.NEXT))

    Child child = Child()
    print(child.NEXT)
    print(child.Values.FIRST)
    print(Named.Item.VALUE)

    Probe probe = Probe(values)
    print(probe.next().FIRST)
    print(probe.calls)

    Values absent = null
    print(absent.FIRST)

    list valuesList = [Values.FIRST, values.NEXT]
    print(valuesList[0])
    print(valuesList[1])
    print(int64(Values.FIRST))
}
