/*
 * tests/functional/negative/negative_ambiguous_inherited_method.cw
 *
 * Rejects an unqualified method call when two bases declare the same method.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * First is a class, used as a fixture by this test.
 *
 * Its methods include value.
 */
class First {
    public:
    /*
     * Returns 1.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 value() {
        return(1)
    }
}

/*
 * Second is a class, used as a fixture by this test.
 *
 * Its methods include value.
 */
class Second {
    public:
    /*
     * Returns 2.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 value() {
        return(2)
    }
}

/*
 * Joined is a class derived from First, Second, used as a fixture by this
 * test.
 *
 * It groups the data used by the surrounding program.
 */
class Joined : First, Second {
}

start {
    Joined joined = Joined()
    print(joined.value())
}
