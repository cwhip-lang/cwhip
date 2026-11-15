/*
 * examples/unhandled_exception.cw
 *
 * Unhandled exception prints call stack trace.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * OtherException is a class derived from Exception, used by this example.
 *
 * Its methods include constructor.
 */
class OtherException: Exception {

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
 * SomeClass is a class, used by this example.
 *
 * Its methods include constructor.
 */
class SomeClass {

    public:
    /*
     * Constructs a SomeClass.
     *
     * Takes no parameters.
     *
     * Returns the constructed SomeClass.
     */
    SomeClass() {
        raise(Exception("This would be the error message"))
    }
}

start { 
    
    try {
        print("before the exception")
        SomeClass c()
    }
    except(OtherException) {
        print("handle other exception")
    }
    finally {
        print("seen whether the exception is handled or not")
    }

    print("should not see this")
}
