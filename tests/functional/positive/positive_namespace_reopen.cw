/*
 * tests/functional/positive/positive_namespace_reopen.cw
 *
 * Reopens a namespace to add classes and verifies declarations share one
 * namespace.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Shared {

    /*
     * First is a class, used as a fixture by this test.
     *
     * Its methods include value.
     */
    class First {
        public:
        /*
         * Returns 20.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 value() {
            return(20)
        }
    }
}

namespace Shared {

    /*
     * Second is a class, used as a fixture by this test.
     *
     * Its methods include value.
     */
    class Second {
        public:
        /*
         * Returns 22.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 value() {
            return(22)
        }
    }

    /*
     * Factory is a class, used as a fixture by this test.
     *
     * Its methods include create.
     */
    class Factory {
        public:
        /*
         * Returns First().
         *
         * Takes no parameters.
         *
         * Returns First.
         */
        First create() {
            return(First())
        }
    }
}

start {
    Shared.Factory factory = Shared.Factory()
    Shared.First first = factory.create()
    Shared.Second second = Shared.Second()
    print(first.value() + second.value())
}
