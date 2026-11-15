/*
 * tests/functional/negative/negative_ambiguous_overload.cw
 *
 * Rejects an ambiguous overloaded call. 'null' is assignable to any class
 * type, so a bare null argument matches both class-typed overloads and the
 * call cannot be resolved.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Left is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Left {
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
 * Right is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Right {
    public:
    /*
     * Constructs a Right.
     *
     * Takes no parameters.
     *
     * Returns the constructed Right.
     */
    Right() {
    }
}

/*
 * Chooser is a class, used as a fixture by this test.
 *
 * Its methods include constructor, pick.
 */
class Chooser {
    public:
    /*
     * Constructs a Chooser.
     *
     * Takes no parameters.
     *
     * Returns the constructed Chooser.
     */
    Chooser() {
    }

    /*
     * Returns 1.
     *
     * Parameters:
     *   value — Left value.
     *
     * Returns int64.
     */
    int64 pick(Left value) {
        return(1)
    }

    /*
     * Returns 2.
     *
     * Parameters:
     *   value — Right value.
     *
     * Returns int64.
     */
    int64 pick(Right value) {
        return(2)
    }
}

start {
    Chooser c = Chooser()
    print(c.pick(null))
}
