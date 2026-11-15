/*
 * tests/functional/negative/negative_virtual_base_missing_initializer.cw
 *
 * Rejects a most-derived constructor that omits a required virtual-base
 * initializer.
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
 * Leaf is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Leaf : virtual Root {
    public:
    /*
     * Constructs a Leaf.
     *
     * Takes no parameters.
     *
     * Returns the constructed Leaf.
     */
    Leaf() {
    }
}

start {
    Leaf leaf = Leaf()
}
