/*
 * tests/functional/positive/positive_newline_statements.cw
 *
 * Checks newline-delimited statements work without semicolons and comments
 * preserve statement boundaries.
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
 * Its methods include constructor.
 */
class Base {
    public:
    int64 value

    /*
     * Constructs a Base and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Base.
     */
    Base(int64 initial) {
        value = initial
    }
}

/*
 * Child is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Child : Base {
    public:
    /*
     * Constructs a Child.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Child.
     */
    Child(int64 initial) {
        super Base(initial)
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

start {
    # Cwhip-style line comment
    Child child = Child(40)
    child.value = child.read() + 2
    # Hash line comment
    print(child.value)
    // C++-style line comment
    /* Block comment
       retaining its line boundary */
}
