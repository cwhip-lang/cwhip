/*
 * tests/functional/positive/positive_constructor_exceptions.cw
 *
 * Exercises exceptions raised from direct constructors, typed handlers, base
 * constructors, and failed partial objects.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * OtherException is a class derived from Exception, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class OtherException : Exception {
    public:
    /*
     * Constructs a OtherException.
     *
     * Parameters:
     *   msg — strg msg.
     *
     * Returns the constructed OtherException.
     */
    OtherException(strg msg) {
        super Exception(msg)
    }
}

/*
 * TypedFailure is a class derived from Exception, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class TypedFailure : Exception {
    public:
    /*
     * Constructs a TypedFailure.
     *
     * Parameters:
     *   msg — strg msg.
     *
     * Returns the constructed TypedFailure.
     */
    TypedFailure(strg msg) {
        super Exception(msg)
    }
}

/*
 * GenericFailure is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class GenericFailure {
    public:
    /*
     * Constructs a GenericFailure.
     *
     * Takes no parameters.
     *
     * Returns the constructed GenericFailure.
     */
    GenericFailure() {
        raise(Exception("generic constructor failure"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("invalid generic partial finalizer")
    }
}

/*
 * TypedThrower is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class TypedThrower {
    public:
    /*
     * Constructs a TypedThrower.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed TypedThrower.
     */
    TypedThrower(int64 value) {
        raise(TypedFailure("typed constructor failure"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("invalid typed partial finalizer")
    }
}

/*
 * FailingBase is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class FailingBase {
    public:
    /*
     * Constructs a FailingBase.
     *
     * Takes no parameters.
     *
     * Returns the constructed FailingBase.
     */
    FailingBase() {
        raise(OtherException("base constructor failure"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("invalid base partial finalizer")
    }
}

/*
 * DerivedFromFailingBase is a class derived from FailingBase, used as a
 * fixture by this test.
 *
 * Its methods include constructor.
 */
class DerivedFromFailingBase : FailingBase {
    public:
    /*
     * Constructs a DerivedFromFailingBase.
     *
     * Takes no parameters.
     *
     * Returns the constructed DerivedFromFailingBase.
     */
    DerivedFromFailingBase() {
        super FailingBase()
        print("invalid derived constructor continuation")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("invalid derived partial finalizer")
    }
}
start {
    print("before constructor exceptions")

    try {
        GenericFailure direct()
        print("invalid direct continuation")
    }
    except(OtherException) {
        print("invalid typed handler for generic failure")
    }
    except() {
        print("caught direct constructor raise")
    }

    try {
        TypedThrower typed(1)
    }
    except(OtherException) {
        print("invalid other handler")
    }
    except(TypedFailure) as caught {
        print(caught.message)
    }
    except() {
        print("invalid typed fallback")
    }

    try {
        DerivedFromFailingBase derived()
    }
    except(OtherException) as caught {
        print(caught.message)
    }
    except() {
        print("invalid base fallback")
    }

    try {
        GenericFailure assigned = GenericFailure()
    }
    except() as message {
        print(message)
    }

    print("after constructor exceptions")
}
