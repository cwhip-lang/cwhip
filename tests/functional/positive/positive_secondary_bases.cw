/*
 * tests/functional/positive/positive_secondary_bases.cw
 *
 * Covers construction and conversion through secondary bases, qualified
 * subobjects, dispatch, and destructor failures.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Payload is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Payload {
    public:
    int64 value

    /*
     * Constructs a Payload and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Payload.
     */
    Payload(int64 initial) {
        value = initial
    }
}

/*
 * Root is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read, readValue.
 */
class Root {
    public:
    int64 value

    /*
     * Constructs a Root and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Root.
     */
    Root(int64 initial) {
        value = initial
    }

    /*
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(value)
    }

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

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print(value)
    }
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Left : Root {
    public:
    /*
     * Constructs a Left.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Left.
     */
    Left(int64 initial) {
        super Root(initial)
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Left")
    }
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Right : Root {
    public:
    Payload payload

    /*
     * Constructs a Right and stores payload.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Right.
     */
    Right(int64 initial) {
        super Root(initial)
        payload = Payload(initial + 20)
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Right")
        raise(Exception("secondary destructor failure"))
    }
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * Its methods include constructor, read, sum.
 */
class Diamond : Left, Right {
    public:
    /*
     * Constructs a Diamond.
     *
     * Parameters:
     *   left — int64 left.
     *   right — int64 right.
     *
     * Returns the constructed Diamond.
     */
    Diamond(int64 left, int64 right) {
        super Left(left)
        super Right(right)
    }

    /*
     * Returns 77.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(77)
    }

    /*
     * Returns 77.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 sum() {
        return(77)
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Diamond")
    }
}

/*
 * Reader is a class, used as a fixture by this test.
 *
 * Its methods include readRoot.
 */
class Reader {
    public:
    /*
     * Returns root.read().
     *
     * Parameters:
     *   root — Root root.
     *
     * Returns int64.
     */
    int64 readRoot(Root root) {
        return(root.read())
    }
}

/*
 * Factory is a class, used as a fixture by this test.
 *
 * Its methods include fromRight.
 */
class Factory {
    public:
    /*
     * Returns the stored right.
     *
     * Parameters:
     *   right — Right right.
     *
     * Returns Root.
     */
    Root fromRight(Right right) {
        return(right)
    }
}

/*
 * FailingSide is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class FailingSide {
    public:
    /*
     * Constructs a FailingSide.
     *
     * Takes no parameters.
     *
     * Returns the constructed FailingSide.
     */
    FailingSide() {
        raise(Exception("secondary constructor failure"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("must not destroy failed object")
    }
}

/*
 * Failing is a class derived from Root, FailingSide, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class Failing : Root, FailingSide {
    public:
    /*
     * Constructs a Failing.
     *
     * Takes no parameters.
     *
     * Returns the constructed Failing.
     */
    Failing() {
        super Root(0)
        super FailingSide()
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("must not destroy failed object")
    }
}

start {
    Diamond diamond = Diamond(4, 8)
    Left leftView = diamond
    Right rightView = diamond
    Root leftRoot = leftView
    Root rightRoot = rightView
    Reader reader = Reader()
    Factory factory = Factory()
    print(leftRoot.read())
    print(rightRoot.read())
    print(diamond.Right.Root.read())
    print(reader.readRoot(rightView))
    print(factory.fromRight(rightView).read())
    print(leftRoot.readValue())
    print(rightRoot.readValue())
    print(diamond.Left.Root.value + diamond.Right.Root.value)
    print(diamond.Right.payload.value)
    Payload trigger = Payload(99)
    print(rightView.payload.value)
    print(diamond.sum())
    try {
        rightView.destroy()
    }
    except() as failure {
        print(failure)
    }
    try {
        Failing failed = Failing()
    }
    except() as constructorFailure {
        print(constructorFailure)
    }
}
