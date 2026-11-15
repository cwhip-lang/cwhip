/*
 * tests/functional/negative/negative_transitive_virtual_base_initializer_o
 * rder.cw
 *
 * Rejects virtual-base initializers ordered differently from the transitive
 * construction order.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Ancestor is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Ancestor {
    public:
    /*
     * Constructs a Ancestor.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Ancestor.
     */
    Ancestor(int64 value) {
    }
}

/*
 * Root is a class derived from Ancestor, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Root : virtual Ancestor {
    public:
    /*
     * Constructs a Root.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Root.
     */
    Root(int64 value) {
    }
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Left : virtual Root {
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Right : virtual Root {
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
     * Takes no parameters.
     *
     * Returns the constructed Diamond.
     */
    Diamond() {
        super virtual Root(2)
        super virtual Ancestor(1)
        super Left()
        super Right()
    }
}

start {
}
