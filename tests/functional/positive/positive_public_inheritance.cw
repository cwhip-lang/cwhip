/*
 * tests/functional/positive/positive_public_inheritance.cw
 *
 * Exercises public base access and confirms protected/private base members
 * remain usable inside derived classes.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Base is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Base {
    public:
    int64 value
}

/*
 * PublicChild is a class derived from Base, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class PublicChild : public Base {
}

/*
 * ProtectedChild is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include readValue.
 */
class ProtectedChild : protected Base {
    public:
    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 readValue() {
        return(value)
    }
}

/*
 * PrivateChild is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include readValue.
 */
class PrivateChild : private Base {
    public:
    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 readValue() {
        return(value)
    }
}

/*
 * ProtectedGrandchild is a class derived from ProtectedChild, used as a
 * fixture by this test.
 *
 * Its methods include readAgain.
 */
class ProtectedGrandchild : public ProtectedChild {
    public:
    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 readAgain() {
        return(value)
    }
}

start {
    PublicChild child = PublicChild()
    child.value = 42
    print(child.value)

    ProtectedChild protectedChild = ProtectedChild()
    print(protectedChild.readValue())

    PrivateChild privateChild = PrivateChild()
    print(privateChild.readValue())

    ProtectedGrandchild protectedGrandchild = ProtectedGrandchild()
    print(protectedGrandchild.readAgain())

}
