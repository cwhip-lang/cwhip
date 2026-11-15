/*
 * tests/functional/positive/positive_member_access.cw
 *
 * Verifies public access, protected subclass access, private self-access, and
 * protected construction.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * AccessBase is a class, used as a fixture by this test.
 *
 * Its methods include publicMethod, protectedMethod, privateMethod,
 * readPrivate, readPrivateMethod.
 */
class AccessBase {
    public:
    int64 publicValue

    /*
     * Returns the stored publicValue.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 publicMethod() {
        return(publicValue)
    }

    protected:
    int64 protectedValue

    /*
     * Returns the stored protectedValue.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 protectedMethod() {
        return(protectedValue)
    }

    private:
    int64 privateValue

    /*
     * Returns the stored privateValue.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 privateMethod() {
        return(privateValue)
    }

    public:
    /*
     * Returns the stored privateValue.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 readPrivate() {
        return(privateValue)
    }

    /*
     * Returns self.privateMethod().
     *
     * Parameters:
     *   self — AccessBase self.
     *
     * Returns int64.
     */
    int64 readPrivateMethod(AccessBase self) {
        return(self.privateMethod())
    }
}

/*
 * AccessChild is a class derived from AccessBase, used as a fixture by this
 * test.
 *
 * Its methods include readProtected.
 */
class AccessChild : public AccessBase {
    public:
    /*
     * Reads protected for this AccessChild.
     *
     * Parameters:
     *   self — AccessChild self.
     *
     * Returns int64.
     */
    int64 readProtected(AccessChild self) {
        self.protectedValue = 7
        return(self.protectedMethod())
    }
}

/*
 * ProtectedCtorBase is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class ProtectedCtorBase {
    protected:
    /*
     * Constructs a ProtectedCtorBase.
     *
     * Takes no parameters.
     *
     * Returns the constructed ProtectedCtorBase.
     */
    ProtectedCtorBase() {
    }
}

/*
 * ProtectedCtorChild is a class derived from ProtectedCtorBase, used as a
 * fixture by this test.
 *
 * Its methods include constructor.
 */
class ProtectedCtorChild : public ProtectedCtorBase {
    public:
    /*
     * Constructs a ProtectedCtorChild.
     *
     * Takes no parameters.
     *
     * Returns the constructed ProtectedCtorChild.
     */
    ProtectedCtorChild() {
        super ProtectedCtorBase()
    }
}

start {
    AccessBase base = AccessBase()
    base.publicValue = 42
    print(base.publicMethod())
    print(base.readPrivate())
    print(base.readPrivateMethod(base))

    AccessChild child = AccessChild()
    print(child.readProtected(child))

    ProtectedCtorChild constructed = ProtectedCtorChild()
    print(1)
}
