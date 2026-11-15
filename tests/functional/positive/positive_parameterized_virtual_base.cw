/*
 * tests/functional/positive/positive_parameterized_virtual_base.cw
 *
 * Passes constructor arguments to one shared virtual base from the
 * most-derived diamond class.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Root is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Root {
    public:
    int64 value

    /*
     * Constructs a Root and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Root.
     */
    Root(int64 initial) {
        value = initial
        print(format("Root:{}", initial))
    }
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Left : virtual Root {
    public:
    /*
     * Constructs a Left.
     *
     * Takes no parameters.
     *
     * Returns the constructed Left.
     */
    Left() {
        print("Left+")
    }
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Right : virtual Root {
    public:
    /*
     * Constructs a Right.
     *
     * Takes no parameters.
     *
     * Returns the constructed Right.
     */
    Right() {
        print("Right+")
    }
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Diamond : Left, Right {
    public:
    /*
     * Constructs a Diamond.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Diamond.
     */
    Diamond(int64 initial) {
        virtual super Root(initial)
        super Left()
        super Right()
        print("Diamond+")
    }
}

start {
    Diamond diamond = Diamond(42)
    print(diamond.Left.Root.value)
    print(diamond.Right.Root.value)
}
