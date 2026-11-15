/*
 * tests/functional/negative/negative_virtual_base_initializer_order.cw
 *
 * Rejects placing a virtual-base initializer after a direct-base initializer.
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
    }
}

/*
 * Leaf is a class derived from Left, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Leaf : Left {
    public:
    /*
     * Constructs a Leaf.
     *
     * Takes no parameters.
     *
     * Returns the constructed Leaf.
     */
    Leaf() {
        super Left()
        super virtual Root(1)
    }
}

start {
}
