/*
 * tests/functional/positive/positive_namespace_single.cw
 *
 * Defines and uses a class inside one namespace with a qualified constructor
 * call.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Orchard {

    /*
     * Apple is a class, used as a fixture by this test.
     *
     * Its methods include constructor, sweetness.
     */
    class Apple {
        public:
        /*
         * Constructs a Apple.
         *
         * Takes no parameters.
         *
         * Returns the constructed Apple.
         */
        Apple() {
        }

        /*
         * Returns 42.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 sweetness() {
            return(42)
        }
    }
}

start {
    Orchard.Apple apple = Orchard.Apple()
    print(apple.sweetness())
}
