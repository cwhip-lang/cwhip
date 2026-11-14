/*
    A Diamond contains one physical Root, not one through Left plus another 
    through Right. Thus diamond.Left.Root.value and diamond.Right.Root.value 
    refer to the same field; the shared Root is also treated as one subobject 
    for ambiguity, upcasts, and destruction. Without virtual, the paths 
    contain distinct Root subobjects, so an unqualified Root member or 
    conversion may be ambiguous.

    In Cwhip, a shared virtual base is constructed once as part of the
    most-derived object, before its non-virtual bases. The most-derived
    constructor supplies arguments for a parameterized virtual base with
    super virtual Root(args) (or virtual super Root(args)); a zero-argument
    virtual base may be initialized automatically. The virtual base is
    destroyed once as well. This is separate from method dispatch, which has
    its own runtime behavior.

 */

class Payload {

    public:
    Payload(int64 initial) {
        print(format("in Payload ctor ({})", initial))
        value = initial
    }

    int64 read() {
        return(value)
    }

    destroy {
        print("in Payload dtor")
    }

    private:
    int64 value
}

class Root {
    public:
    Payload item

    Root() {
        print("Root ctor")
        value = 41
    }

    int64 read() {
        return(value)
    }

    destroy {
        print("Root dtor")
    }

    private:
    int64 value
}

class Left : virtual Root {
    public:
    Left() {
        print("Left ctor")
    }

    destroy {
        print("Left dtor")
    }
}

class Right : virtual Root {
    public:
    Right() {
        print("Right ctor")
    }

    destroy {
        print("Right dtor")
    }
}

class Diamond : Left, Right {
    public:
    Diamond() {
        super Left()
        super Right()
        print("Diamond ctor")
    }

    int64 read() {
        return(77)
    }

    destroy {
        print("Diamond dtor")
    }
}

class FailedRoot {
    public:
    FailedRoot() {
        raise(Exception("virtual initialization failed"))
    }

    destroy {
        print("wrong FailedRoot destroy")
    }
}

class FailedSide : virtual FailedRoot {
    public:
    FailedSide() {
        print("wrong side constructor")
    }
}

class FailedDiamond : FailedSide {
    public:
    FailedDiamond() {
        super FailedSide()
    }

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
            diamond.Left.Root.read() + diamond.Right.Root.read() + root.read()))

    # construct the Payload
    diamond.Left.Root.item = Payload(50)

    # construct a separate Payload
    Payload trigger = Payload(9)

    # access the Payload value through the Right virtual class
    #print(format("value in right Payload: {}", diamond.Right.Root.item.value))

    # access the correct read()
    print(format("read() from Root: {}", root.read()))
    print(format("read() from Right Payload: {}", diamond.Right.Root.item.read()))
    print(format("read() from Left Payload: {}", diamond.Left.Root.item.read()))

    # destroys diamond, left, and right, but not Payload
    diamond.destroy()

    print("\nvirtual exception class:")
    try {
        FailedDiamond failed()
    } except() as message {
        print(message)
    }
}
