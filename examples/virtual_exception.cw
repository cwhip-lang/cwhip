/*
 * examples/virtual_exception.cw
 *
 * This contrived example shows how the proper handler is reached when there is
 * a diamond shaped inheritance.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * ExceptionBase is a class derived from Exception, used by this example.
 *
 * Its methods include constructor.
 */
class ExceptionBase: Exception { 

    public:
    /*
     * Constructs a ExceptionBase.
     *
     * Parameters:
     *   val — strg val.
     *
     * Returns the constructed ExceptionBase.
     */
    ExceptionBase(strg val) {
        super Exception(val)
    }

}

/*
 * LeftException is a class derived from ExceptionBase, used by this example.
 *
 * Its methods include constructor.
 */
class LeftException: virtual ExceptionBase {

    public:
    /*
     * Constructs a LeftException.
     *
     * Takes no parameters.
     *
     * Returns the constructed LeftException.
     */
    LeftException() {
        #super virtual ExceptionBase(val)
    }
}

/*
 * RightException is a class derived from ExceptionBase, used by this example.
 *
 * Its methods include constructor.
 */
class RightException: virtual ExceptionBase {

    public:
    /*
     * Constructs a RightException.
     *
     * Takes no parameters.
     *
     * Returns the constructed RightException.
     */
    RightException() {
        # super virtual ExceptionBase(val)
    }
}

/*
 * ChildException is a class derived from LeftException, RightException, used
 * by this example.
 *
 * Its methods include constructor.
 */
class ChildException: LeftException, RightException {

    public:
    /*
     * Constructs a ChildException.
     *
     * Parameters:
     *   val — strg val.
     *
     * Returns the constructed ChildException.
     */
    ChildException(strg val) {
        super virtual ExceptionBase(val)
        super LeftException()
        super RightException()
    }
}

/*
 * Thrower is a class, used by this example.
 *
 * Its methods include throw.
 */
class Thrower {

    public:
    /*
     * Handles throw for this Thrower. Raises Exception when the call is not
     * valid (this is the string).
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void throw() {
        raise(ChildException("this is the string"))
    }
}

start {

    try {
        Thrower t()
        t.throw()
    }
    except(ChildException) as child {
        print(child.message)
        print("Child was caught")
    }
    except(RightException) as right {
        print(right.message)
        print("Right was caught")
    }
    except(LeftException) as left {
        print(left.message)
        print("Left was caught")
    }
    finally {
        print("Finally block")
    }

    print("after the exception handlers")

}
