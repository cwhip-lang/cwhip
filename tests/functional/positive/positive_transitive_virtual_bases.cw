# Exercises a transitive virtual-base diamond, shared state, construction/destruction order, failure cleanup, and GC.
class Payload {
    public:
    int64 value

    Payload(int64 initial) {
        value = initial
    }
}

class Common {
    public:
    Payload item
    int64 marker

    Common(int64 initial) {
        marker = initial
        print("Common+")
    }

    destroy {
        print("Common-")
    }
}

class Ancestor : Common {
    public:
    int64 value

    Ancestor(int64 initial) {
        super Common(initial + 1)
        value = initial
        print("Ancestor+")
    }

    int64 read() {
        return(value)
    }

    int64 baseRead() {
        return(value)
    }

    destroy {
        print("Ancestor-")
    }
}

class Root : virtual Ancestor {
    public:
    int64 rootValue

    Root(int64 initial) {
        rootValue = initial
        print("Root+")
    }

    destroy {
        print("Root-")
    }
}

class Left : virtual Root {
    public:
    Left() {
        print("Left+")
    }

    destroy {
        print("Left-")
    }
}

class Right : virtual Root {
    public:
    Right() {
        print("Right+")
    }

    destroy {
        print("Right-")
    }
}

class Diamond : Left, Right {
    public:
    Diamond(int64 rootInitial, int64 ancestorInitial) {
        super virtual Ancestor(ancestorInitial)
        super virtual Root(rootInitial)
        super Left()
        super Right()
        print("Diamond+")
    }

    int64 read() {
        return(77)
    }

    destroy {
        print("Diamond-")
    }
}

class FailedAncestor {
    public:
    FailedAncestor(int64 initial) {
        raise(Exception("transitive initialization failed"))
    }

    destroy {
        print("wrong FailedAncestor destroy")
    }
}

class FailedSide : virtual FailedAncestor {
    public:
    FailedSide() {
    }
}

class FailedDiamond : FailedSide {
    public:
    FailedDiamond() {
        super virtual FailedAncestor(1)
        super FailedSide()
    }

    destroy {
        print("wrong FailedDiamond destroy")
    }
}

class Maker {
    public:
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
    } except() as message {
        print(message)
    }

    Maker maker = Maker()
    maker.release()
    print("before collection")
    inline { cwhip_gc_collect(); }
    Payload collector = Payload(12)
    print("after collection")
}
