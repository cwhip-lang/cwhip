/*
 * tests/functional/positive/positive_runtime_exceptions.cw
 *
 * Exercises exceptions from methods, constructors, destructors, handlers,
 * finally blocks, null access, and division.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Box is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class Box {
    public:
    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
    }

    /*
     * Returns 42.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(42)
    }
}

/*
 * Worker is a class, used as a fixture by this test.
 *
 * Its methods include fail.
 */
class Worker {
    public:
    /*
     * Handles fail for this Worker. Raises Exception when the call is not
     * valid (from method).
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 fail() {
        Box local = Box()
        raise(Exception("from method"))
        return(0)
    }
}

/*
 * ThrowingBox is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class ThrowingBox {
    public:
    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        raise(Exception("from destructor"))
    }

    /*
     * Returns 9.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(9)
    }
}

/*
 * Partial is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Partial {
    public:
    /*
     * Constructs a Partial.
     *
     * Takes no parameters.
     *
     * Returns the constructed Partial.
     */
    Partial() {
        raise(Exception("constructor failed"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("invalid partial finalizer")
    }
}

/*
 * Builder is a class, used as a fixture by this test.
 *
 * Its methods include build.
 */
class Builder {
    public:
    /*
     * Handles build for this Builder.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void build() {
        Partial partial = Partial()
    }
}
start {
    try {
        raise(Exception("requested"))
    }
    except() {
        print("caught raise")
    }
    finally {
        print("finally after exception")
    }

    try {
        print(1)
    }
    finally {
        print("finally after success")
    }

    Worker worker = Worker()
    try {
        worker.fail()
    }
    except() {
        print("caught method raise")
    }

    Builder builder = Builder()
    try {
        builder.build()
    }
    except() {
        print("caught constructor raise")
    }
    Box afterFailure = Box()

    ThrowingBox doomed = ThrowingBox()
    try {
        doomed.destroy()
    }
    except() {
        print("caught destructor raise")
    }
    try {
        print(doomed.read())
    }
    except() {
        print("caught destroyed after destructor raise")
    }

    try {
        try {
            raise(Exception("original"))
        }
        except() {
            raise(Exception("from handler"))
        }
        finally {
            print("finally after handler error")
        }
    }
    except() {
        print("caught handler raise")
    }

    try {
        try {
            print(2)
        }
        finally {
            raise(Exception("from finally"))
        }
    }
    except() {
        print("caught finally raise")
    }

    Box box = Box()
    box.destroy()
    try {
        box.destroy()
    }
    except() {
        print("caught repeated destruction")
    }
    try {
        print(box.read())
    }
    except() {
        print("caught destroyed object")
    }

    Box missing = null
    try {
        print(missing.read())
    }
    except() {
        print("caught null reference")
    }

    try {
        print(42 / 0)
    }
    except() {
        print("caught division by zero")
    }

    try {
        if (true) {
            raise(Exception("first branch"))
        }
        else {
            raise(Exception("second branch"))
        }
    }
    except() {
        print("caught conditional raise")
    }
}
