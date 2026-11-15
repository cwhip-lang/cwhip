/*
 * tests/functional/positive/positive_transitive_virtual_bases.cw
 *
 * Exercises a transitive virtual-base diamond, shared state,
 * construction/destruction order, failure cleanup, and GC.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
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
 * Common is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Common {
    public:
    Payload item
    int64 marker

    /*
     * Constructs a Common and stores marker.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Common.
     */
    Common(int64 initial) {
        marker = initial
        print("Common+")
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("Common-")
    }
}

/*
 * Ancestor is a class derived from Common, used as a fixture by this test.
 *
 * Its methods include constructor, read, baseRead.
 */
class Ancestor : Common {
    public:
    int64 value

    /*
     * Constructs a Ancestor and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Ancestor.
     */
    Ancestor(int64 initial) {
        super Common(initial + 1)
        value = initial
        print("Ancestor+")
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
    int64 baseRead() {
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
        print("Ancestor-")
    }
}

/*
 * Root is a class derived from Ancestor, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Root : virtual Ancestor {
    public:
    int64 rootValue

    /*
     * Constructs a Root and stores rootValue.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Root.
     */
    Root(int64 initial) {
        rootValue = initial
        print("Root+")
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
     * Parameters:
     *   rootInitial — int64 root initial.
     *   ancestorInitial — int64 ancestor initial.
     *
     * Returns the constructed Diamond.
     */
    Diamond(int64 rootInitial, int64 ancestorInitial) {
        super virtual Ancestor(ancestorInitial)
        super virtual Root(rootInitial)
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
 * FailedAncestor is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class FailedAncestor {
    public:
    /*
     * Constructs a FailedAncestor.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed FailedAncestor.
     */
    FailedAncestor(int64 initial) {
        raise(Exception("transitive initialization failed"))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("wrong FailedAncestor destroy")
    }
}

/*
 * FailedSide is a class derived from FailedAncestor, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class FailedSide : virtual FailedAncestor {
    public:
    /*
     * Constructs a FailedSide.
     *
     * Takes no parameters.
     *
     * Returns the constructed FailedSide.
     */
    FailedSide() {
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
        super virtual FailedAncestor(1)
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
        print("wrong FailedDiamond destroy")
    }
}

/*
 * Maker is a class, used as a fixture by this test.
 *
 * Its methods include release.
 */
class Maker {
    public:
    /*
     * Handles release for this Maker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void release() {
        Diamond temporary = Diamond(11, 3)
    }
}

start {
    Diamond diamond = Diamond(40, 7)
    Root root = diamond
    Ancestor ancestor = diamond
    Common common = diamond
    print(diamond.Left.Root.Ancestor.value)
    print(diamond.Right.Root.Ancestor.value)
    diamond.Left.Root.Ancestor.Common.item = Payload(50)
    Payload trigger = Payload(9)
    print(diamond.Right.Root.Ancestor.Common.item.value)
    print(common.marker)
    print(common.item.value)
    print(diamond.baseRead())
    print(root.read())
    print(ancestor.read())
    print(diamond.Left.Root.rootValue)
    diamond.destroy()

    try {
        FailedDiamond failed = FailedDiamond()
    }
    except() as message {
        print(message)
    }

    Maker maker = Maker()
    maker.release()
    print("before collection")
    inline { cwhip_gc_collect(); }
    Payload collector = Payload(12)
    print("after collection")
}
