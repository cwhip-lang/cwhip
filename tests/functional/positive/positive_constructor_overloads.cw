class RootTag {
    public:
    RootTag() {}
}

class DerivedTag : RootTag {
    public:
    DerivedTag() {
        super RootTag()
    }
}

class Pick {
    public:
    Pick() {
        print("zero")
    }

    Pick(int64 value) {
        print("int")
    }

    Pick(int64 first, int64 second) {
        print("two")
    }

    Pick(strg value) {
        print("string")
    }

    Pick(RootTag value) {
        print("root")
    }

    Pick(DerivedTag value) {
        print("derived")
    }
}

class BaseOnly {
    public:
    BaseOnly(RootTag value) {
        print("base-only")
    }
}

class MethodChoice {
    public:
    int64 choose(RootTag value) {
        return(1)
    }

    int64 choose(DerivedTag value) {
        return(2)
    }
}

class Base {
    public:
    Base(int64 value) {
        print("base int")
    }

    Base(strg value) {
        print("base string")
    }
}

class ChildBase : Base {
    public:
    ChildBase(int64 value) {
        super Base(value)
    }
}

class VirtualRoot {
    public:
    VirtualRoot(int64 value) {
        print("virtual int")
    }

    VirtualRoot(strg value) {
        print("virtual string")
    }
}

class VirtualChild : virtual VirtualRoot {
    public:
    VirtualChild(strg value) {
        super virtual VirtualRoot(value)
    }
}

class Empty {}

start {
    Pick zero = Pick()
    Pick integer = Pick(1)
    Pick pair = Pick(1, 2)
    Pick text = Pick("value")

    RootTag root = RootTag()
    DerivedTag child = DerivedTag()
    Pick rootChoice = Pick(root)
    Pick childChoice = Pick(child)
    BaseOnly baseOnly = BaseOnly(child)

    MethodChoice methods = MethodChoice()
    print(methods.choose(child))

    ChildBase base = ChildBase(8)
    VirtualChild virtualChild = VirtualChild("value")
    Empty empty = Empty()
}
