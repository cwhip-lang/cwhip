/*
 * tests/functional/positive/positive_return_parentheses.cw
 *
 * Checks parenthesized return expressions and an empty return in an
 * out-of-line void method.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Foo is a class, used as a fixture by this test.
 *
 * Its methods include compute, announce.
 */
class Foo {
    public:
    /*
     * Handles compute for this Foo.
     *
     * Parameters:
     *   x — int64 input value.
     *
     * Returns int64.
     */
    int64 compute(int64 x)

    /*
     * Handles announce for this Foo.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void announce()
}

int64 Foo.compute(int64 x) {
    return(x * 2)
}

void Foo.announce() {
    return()
}

start {
    Foo foo = Foo()
    print(foo.compute(5))
    foo.announce()
    print(1)
}
