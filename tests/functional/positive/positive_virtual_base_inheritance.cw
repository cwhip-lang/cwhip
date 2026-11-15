/*
 * tests/functional/positive/positive_virtual_base_inheritance.cw
 *
 * Verifies a diamond shares one virtual base and cleans up correctly when
 * virtual-base construction fails.
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
 * Its methods include constructor, read.
 */
class Root {
    public:
    Payload item
    int64 value

    /*
     * Constructs a Root and stores value.
     *
     * Takes no parameters.
     *
     * Returns the constructed Root.
     */
    Root() {
        print("Root+")
        value = 41
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
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Root-")
    }
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Left : virtual Root {
    public:
    /*
     * Constructs a Left.
     *
     * Takes no parameters.
     *
     * Returns the constructed Left.
     */
    Left() {
        print("Left+")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Left-")
    }
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Right : virtual Root {
    public:
    /*
     * Constructs a Right.
     *
     * Takes no parameters.
     *
     * Returns the constructed Right.
     */
    Right() {
        print("Right+")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Right-")
    }
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Diamond : Left, Right {
    public:
    /*
     * Constructs a Diamond.
     *
     * Takes no parameters.
     *
     * Returns the constructed Diamond.
     */
    Diamond() {
        super Left()
        super Right()
        print("Diamond+")
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
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Diamond-")
    }
}

/*
 * FailedRoot is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class FailedRoot {
    public:
    /*
     * Constructs a FailedRoot.
     *
     * Takes no parameters.
     *
     * Returns the constructed FailedRoot.
     */
    FailedRoot() {
        raise(Exception("virtual initialization failed"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("wrong FailedRoot destroy")
    }
}

/*
 * FailedSide is a class derived from FailedRoot, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class FailedSide : virtual FailedRoot {
    public:
    /*
     * Constructs a FailedSide.
     *
     * Takes no parameters.
     *
     * Returns the constructed FailedSide.
     */
    FailedSide() {
        print("wrong side constructor")
    }
}

/*
 * FailedDiamond is a class derived from FailedSide, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class FailedDiamond : FailedSide {
    public:
    /*
     * Constructs a FailedDiamond.
     *
     * Takes no parameters.
     *
     * Returns the constructed FailedDiamond.
     */
    FailedDiamond() {
        super FailedSide()
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("wrong derived destroy")
    }
}

start {
    Diamond diamond = Diamond()
    Root root = diamond
    print(diamond.value)
    print(diamond.Left.Root.value + diamond.Right.Root.value + root.value)
    diamond.Left.Root.item = Payload(50)
    Payload trigger = Payload(9)
    print(diamond.Right.Root.item.value)
    print(root.read())
    print(diamond.Right.Root.read())
    diamond.destroy()

    try {
        FailedDiamond failed = FailedDiamond()
    }
    except() as message {
        print(message)
    }
}
