/*
 * tests/functional/positive/positive_debug_class_members.cw
 *
 * Class member DWARF for locals and watches in cdbg.
 *
 * Created: 2026-10-29
 * Author: chuck
 *
 * Changelog:
 *   2026-10-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Point is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Point {
    public:
    int64 x
    int64 y

    /*
     * Constructs a Point and stores x, y.
     *
     * Parameters:
     *   nx — int64 input value.
     *   ny — int64 input value.
     *
     * Returns the constructed Point.
     */
    Point(int64 nx, int64 ny) {
        x = nx
        y = ny
    }
}

/*
 * Base is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Base {
    public:
    int64 b
}

/*
 * Derived is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Derived : Base {
    public:
    int64 d

    /*
     * Constructs a Derived and stores b, d.
     *
     * Parameters:
     *   nb — int64 input value.
     *   nd — int64 input value.
     *
     * Returns the constructed Derived.
     */
    Derived(int64 nb, int64 nd) {
        b = nb
        d = nd
    }
}

start {
    Point point = Point(3, 4)
    Derived derived = Derived(1, 2)
    print(point.x)
    print(derived.d)
}
