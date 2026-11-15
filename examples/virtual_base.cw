/*
 * examples/virtual_base.cw
 *
 * A Diamond contains one physical Root, not one through Left plus another
 * through Right. Thus diamond.Left.Root.value and diamond.Right.Root.value
 * refer to the same field; the shared Root is also treated as one subobject
 * for ambiguity, upcasts, and destruction. Without virtual, the paths contain
 * distinct Root subobjects, so an unqualified Root member or conversion may be
 * ambiguous. In Cwhip, a shared virtual base is constructed once as part of
 * the most-derived object, before its non-virtual bases. The most-derived
 * constructor supplies arguments for a parameterized virtual base with super
 * virtual Root(args) (or virtual super Root(args)); a zero-argument virtual
 * base may be initialized automatically. The virtual base is destroyed once as
 * well. This is separate from method dispatch, which has its own runtime
 * behavior.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Payload is a class, used by this example.
 *
 * Its methods include constructor, read.
 */
class Payload {

    public:
    /*
     * Constructs a Payload and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Payload.
     */
    Payload(int64 initial) {
        print(format("in Payload ctor ({})", initial))
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
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("in Payload dtor")
    }

    private:
    int64 value
}

/*
 * Root is a class, used by this example.
 *
 * Its methods include constructor, read.
 */
class Root {
    public:
    Payload item

    /*
     * Constructs a Root and stores value.
     *
     * Takes no parameters.
     *
     * Returns the constructed Root.
     */
    Root() {
        print("Root ctor")
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
        print("Root dtor")
    }

    private:
    int64 value
}

/*
 * Left is a class derived from Root, used by this example.
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
        print("Left ctor")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Left dtor")
    }
}

/*
 * Right is a class derived from Root, used by this example.
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
        print("Right ctor")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Right dtor")
    }
}

/*
 * Diamond is a class derived from Left, Right, used by this example.
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
        print("Diamond ctor")
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
        print("Diamond dtor")
    }
}

/*
 * FailedRoot is a class, used by this example.
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
 * FailedSide is a class derived from FailedRoot, used by this example.
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
 * FailedDiamond is a class derived from FailedSide, used by this example.
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
    Diamond diamond()
    Root root = diamond

    # defined in Root
    print(format("read() from diamond: {}", diamond.read()))

    # show that both sides of the diamond can access the value
    print(format("expression with left and right: {}",
            diamond.Left.Root.read()
            + diamond.Right.Root.read()
            + root.read()))

    # construct the Payload
    diamond.Left.Root.item = Payload(50)

    # construct a separate Payload
    Payload trigger = Payload(9)

    # access the Payload value through the Right virtual class
    #print(format("value in right Payload: {}", diamond.Right.Root.item.value))

    # access the correct read()
    print(format("read() from Root: {}", root.read()))
    print(format(
            "read() from Right Payload: {}",
            diamond.Right.Root.item.read()))
    print(format("read() from Left Payload: {}", diamond.Left.Root.item.read()))

    # destroys diamond, left, and right, but not Payload
    diamond.destroy()

    print("\nvirtual exception class:")
    try {
        FailedDiamond failed()
    }
    except() as message {
        print(message)
    }
}
