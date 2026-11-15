/*
 * tests/functional/negative/negative_virtual_base_initializer_arity.cw
 *
 * Rejects a virtual-base initializer that omits the base constructor's
 * required argument.
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
        super virtual Root()
    }
}

start {
    Leaf leaf = Leaf()
}
