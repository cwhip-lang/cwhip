/*
 * tests/functional/positive/positive_namespace_qualified_call.cw
 *
 * Constructs a class by its fully qualified name and calls its method.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Foo {

    /*
     * Bar is a class, used as a fixture by this test.
     *
     * Its methods include method.
     */
    class Bar {
        public:
        /*
         * Returns 42.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 method() {
            return(42)
        }
    }
}

start {
    print(Foo.Bar().method())
}
