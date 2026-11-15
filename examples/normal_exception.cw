/*
 * examples/normal_exception.cw — Demonstrate normal exception handling.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * ExceptionClass is a class derived from Exception, used by this example.
 *
 * Its methods include constructor.
 */
class ExceptionClass: Exception {

    public:
    /*
     * Constructs a ExceptionClass.
     *
     * Parameters:
     *   val — strg val.
     *
     * Returns the constructed ExceptionClass.
     */
    ExceptionClass(strg val) {
        super Exception(val)
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
     * Handles throw for this Thrower.
     *
     * Parameters:
     *   val — strg val.
     *
     * Does not return a value.
     */
    void throw(strg val) {
        raise(ExceptionClass(val))
    }
}

start {

    try {
        Thrower t()
        t.throw("error message")
    }
    except(ExceptionClass) as msg {
        print("catch exception class")
        print(msg.message)
    }
    except() as msg {
        print("catch anything else")
        print(msg)
    }
    finally {
        print("finally clause")
    }
}
