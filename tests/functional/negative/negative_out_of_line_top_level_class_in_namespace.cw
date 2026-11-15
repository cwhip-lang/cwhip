/*
 * tests/functional/negative/negative_out_of_line_top_level_class_in_namesp
 * ace.cw
 *
 * Rejects defining a top-level class method from inside a namespace.
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
 * Its methods include compute.
 */
class Foo {
    public:
    /*
     * Handles compute for this Foo.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 compute()
}

namespace Other {
    int64 Foo.compute() {
        return(99)
    }
}

start {
    print(Foo().compute())
}
