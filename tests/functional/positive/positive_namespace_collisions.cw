/*
 * tests/functional/positive/positive_namespace_collisions.cw
 *
 * Uses same-named classes in sibling namespaces and verifies their qualified
 * identities remain distinct.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Branch {
    namespace Left {

        /*
         * Item is a class, used as a fixture by this test.
         *
         * Its methods include value.
         */
        class Item {
            public:
            /*
             * Returns 10.
             *
             * Takes no parameters.
             *
             * Returns int64.
             */
            int64 value() {
                return(10)
            }
        }
    }
}

namespace Branch {
    namespace Right {

        /*
         * Item is a class, used as a fixture by this test.
         *
         * Its methods include value.
         */
        class Item {
            public:
            /*
             * Returns 32.
             *
             * Takes no parameters.
             *
             * Returns int64.
             */
            int64 value() {
                return(32)
            }
        }
    }
}

start {
    Branch.Left.Item left = Branch.Left.Item()
    Branch.Right.Item right = Branch.Right.Item()
    print(left.value() + right.value())
}
