/*
 * tests/functional/negative/negative_ambiguous_constructor.cw
 *
 * Rejects ambiguous constructor.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * First is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class First {
}

/*
 * Second is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Second {
}

/*
 * Ambiguous is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Ambiguous {
    public:
    /*
     * Constructs a Ambiguous.
     *
     * Parameters:
     *   value — First value.
     *
     * Returns the constructed Ambiguous.
     */
    Ambiguous(First value) {
    }

    /*
     * Constructs a Ambiguous.
     *
     * Parameters:
     *   value — Second value.
     *
     * Returns the constructed Ambiguous.
     */
    Ambiguous(Second value) {
    }
}

start {
    Ambiguous value = Ambiguous(null)
}
