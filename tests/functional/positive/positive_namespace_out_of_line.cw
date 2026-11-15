/*
 * tests/functional/positive/positive_namespace_out_of_line.cw
 *
 * Defines a declared method out of line within its owning namespace and
 * invokes it.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Remote {

    /*
     * Method is a class, used as a fixture by this test.
     *
     * Its methods include value.
     */
    class Method {
        public:
        /*
         * Handles value for this Method.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 value()
    }

    int64 Method.value() {
        return(42)
    }
}

start {
    print(Remote.Method().value())
}
