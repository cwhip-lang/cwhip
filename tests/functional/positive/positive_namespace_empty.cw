/*
 * tests/functional/positive/positive_namespace_empty.cw
 *
 * Checks empty namespaces are accepted alongside nested namespace-qualified
 * class construction.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Empty {
}

namespace Outer {
    namespace Inner {

        /*
         * Item is a class, used as a fixture by this test.
         *
         * It groups the data used by the surrounding program.
         */
        class Item {
        }
    }
}

start {
    Outer.Inner.Item item = Outer.Inner.Item()
    print(42)
}
