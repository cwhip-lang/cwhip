/*
 * tests/functional/positive/positive_object_identity.cw
 *
 * Checks object identity.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Base is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Base {
}

/*
 * Child is a class derived from Base, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Child : Base {
}

start {
    Base first = Base()
    Base same = first
    Base second = Base()
    print(first == same)
    print(first != same)
    print(first == second)
    print(first != second)

    Child derived = Child()
    Base baseView = derived
    Base sameBaseView = derived
    print(derived == baseView)
    print(derived != baseView)
    print(baseView == sameBaseView)

    Base nullBase = null
    Child nullChild = null
    print(nullBase == null)
    print(nullBase != null)
    print(baseView == null)
    print(baseView != null)
    print(nullBase == nullChild)
    print(nullBase != nullChild)
}
