/*
 * tests/functional/negative/negative_incompatible_override.cw
 *
 * Rejects an override that changes the inherited method return type.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Base is a class, used as a fixture by this test.
 *
 * Its methods include constructor, value.
 */
class Base {
    public:
    /*
     * Constructs a Base.
     *
     * Takes no parameters.
     *
     * Returns the constructed Base.
     */
    Base() {
    }

    /*
     * Returns the stored input.
     *
     * Parameters:
     *   input — int64 input.
     *
     * Returns int64.
     */
    int64 value(int64 input) {
        return(input)
    }
}

/*
 * Child is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include constructor, value.
 */
class Child : Base {
    public:
    /*
     * Constructs a Child.
     *
     * Takes no parameters.
     *
     * Returns the constructed Child.
     */
    Child() {
        super Base()
    }

    /*
     * Returns "wrong".
     *
     * Parameters:
     *   input — int64 input.
     *
     * Returns strg.
     */
    strg value(int64 input) {
        return("wrong")
    }
}

start {
}
