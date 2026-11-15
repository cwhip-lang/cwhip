/*
 * tests/functional/positive/positive_method_overloads.cw
 *
 * Exercises method overloading: several same-named methods distinguished by
 * parameter type, resolved by exact argument-type match and dispatched through
 * type-encoded mangled symbols. Also checks that an overload set survives
 * inheritance -- a derived class may override one overload while inheriting
 * its siblings, and may add a new overload of its own -- and that all of them
 * dispatch correctly through a base-typed reference.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Formatter is a class, used as a fixture by this test.
 *
 * Its methods include constructor, describe.
 */
class Formatter {
    public:
    /*
     * Constructs a Formatter.
     *
     * Takes no parameters.
     *
     * Returns the constructed Formatter.
     */
    Formatter() {
    }

    /*
     * Returns 1.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 describe() {
        return(1)
    }

    /*
     * Returns value + 10.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 describe(int64 value) {
        return(value + 10)
    }

    /*
     * Returns 2.
     *
     * Parameters:
     *   value — fp64 value.
     *
     * Returns int64.
     */
    int64 describe(fp64 value) {
        return(2)
    }

    /*
     * Returns 3.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns int64.
     */
    int64 describe(strg value) {
        return(3)
    }

    /*
     * Returns first + second.
     *
     * Parameters:
     *   first — int64 first.
     *   second — int64 second.
     *
     * Returns int64.
     */
    int64 describe(int64 first, int64 second) {
        return(first + second)
    }
}

/*
 * LoudFormatter is a class derived from Formatter, used as a fixture by this
 * test.
 *
 * Its methods include constructor, describe.
 */
class LoudFormatter : Formatter {
    public:
    /*
     * Constructs a LoudFormatter.
     *
     * Takes no parameters.
     *
     * Returns the constructed LoudFormatter.
     */
    LoudFormatter() {
        super Formatter()
    }

    /*
     * Overrides exactly one member of the inherited overload set; the
     * zero-argument, float, string, and two-int overloads are inherited.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns int64.
     */
    int64 describe(int64 value) {
        return(value + 100)
    }

    /*
     * Adds a brand new overload that the base class does not declare.
     *
     * Parameters:
     *   value — bool value.
     *
     * Returns int64.
     */
    int64 describe(bool value) {
        return(55)
    }
}

start {
    Formatter plain = Formatter()
    print(plain.describe())
    print(plain.describe(int64(5)))
    print(plain.describe(fp64(1.5)))
    print(plain.describe("text"))
    print(plain.describe(int64(3), int64(4)))

    LoudFormatter loud = LoudFormatter()
    print(loud.describe())
    print(loud.describe(int64(5)))
    print(loud.describe(fp64(1.5)))
    print(loud.describe(true))
    print(loud.describe(int64(3), int64(4)))

    # Virtual dispatch through a base-typed reference must still reach the
    # derived override for the int overload, and the inherited
    # implementations for the others.
    Formatter view = loud
    print(view.describe())
    print(view.describe(int64(5)))
    print(view.describe(int64(3), int64(4)))
}
