/*
 * tests/functional/positive/positive_direct_constructor_declarations.cw
 *
 * Checks direct constructor declarations.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Choice is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Choice {
    public:
    int64 selected

    /*
     * Constructs a Choice and stores selected.
     *
     * Takes no parameters.
     *
     * Returns the constructed Choice.
     */
    Choice() {
        selected = 0
    }

    /*
     * Constructs a Choice and stores selected.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Choice.
     */
    Choice(int64 value) {
        selected = value
    }

    /*
     * Constructs a Choice and stores selected.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns the constructed Choice.
     */
    Choice(strg value) {
        selected = 3
    }

    /*
     * Returns the stored selected.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(selected)
    }
}

/*
 * Ticker is a class, used as a fixture by this test.
 *
 * Its methods include next, read.
 */
class Ticker {
    public:
    int64 count

    /*
     * Handles next for this Ticker.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 next() {
        count += 1
        return(count)
    }

    /*
     * Returns the stored count.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(count)
    }
}

/*
 * Pair is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Pair {
    public:
    int64 value

    /*
     * Constructs a Pair and stores value.
     *
     * Parameters:
     *   first — int64 first.
     *   second — int64 second.
     *
     * Returns the constructed Pair.
     */
    Pair(int64 first, int64 second) {
        value = first * 10 + second
    }

    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(value)
    }
}

/*
 * Maker is a class, used as a fixture by this test.
 *
 * Its methods include make, forward, pass.
 */
class Maker {
    public:
    /*
     * Handles make for this Maker.
     *
     * Takes no parameters.
     *
     * Returns Choice.
     */
    Choice make() {
        Choice local(8)
        return(local)
    }

    /*
     * Returns Choice(13).
     *
     * Takes no parameters.
     *
     * Returns Choice.
     */
    Choice forward() {
        return(Choice(13))
    }

    /*
     * Returns the stored value.
     *
     * Parameters:
     *   value — Choice value.
     *
     * Returns Choice.
     */
    Choice pass(Choice value) {
        return(value)
    }
}

namespace Geometry {

    /*
     * Point is a class, used as a fixture by this test.
     *
     * Its methods include constructor.
     */
    class Point {
        public:
        int64 x

        /*
         * Constructs a Point and stores x.
         *
         * Parameters:
         *   initial — int64 initial.
         *
         * Returns the constructed Point.
         */
        Point(int64 initial) {
            x = initial
        }
    }
}

/*
 * Base is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Base {
}

/*
 * Derived is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Derived : Base {
    public:
    /*
     * Constructs a Derived.
     *
     * Takes no parameters.
     *
     * Returns the constructed Derived.
     */
    Derived() {
        super Base()
    }
}

start {
    Choice empty()
    Choice integer(5)
    Choice text("selected by type")
    print(empty.read())
    print(integer.read())
    print(text.read())

    Ticker ticker()
    Pair pair(ticker.next(), ticker.next())
    print(pair.read())
    print(ticker.read())

    {
        Choice nested(9)
        print(nested.read())
    }

    Maker maker()
    Choice fromMethod = maker.make()
    Choice fromArgument = maker.pass(Choice(6))
    Choice fromReturn = maker.forward()
    print(fromMethod.read())
    print(fromArgument.read())
    print(fromReturn.read())

    Base existingInitializer = Derived()
    print(existingInitializer is Derived)

    Geometry.Point point(11)
    print(point.x)
}
