/*
 * tests/functional/positive/positive_implicit_imported_base.cw
 *
 * Checks implicit imported base.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import greeting as Parent

/*
 * Derived is a class derived from Parent, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Derived: Parent {
    public:
    /*
     * Constructs a Derived.
     *
     * Takes no parameters.
     *
     * Returns the constructed Derived.
     */
    Derived() {
        super Parent()
        print(Parent.answer())
    }

    /*
     * Returns Parent.answer().
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(Parent.answer())
    }
}

start {
    Derived value = Derived()
    print(value.read())
}
