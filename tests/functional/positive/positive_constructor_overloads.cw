/*
 * tests/functional/positive/positive_constructor_overloads.cw
 *
 * Checks constructor overloads.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * RootTag is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class RootTag {
    public:
    /*
     * Constructs a RootTag.
     *
     * Takes no parameters.
     *
     * Returns the constructed RootTag.
     */
    RootTag() {
    }
}

/*
 * DerivedTag is a class derived from RootTag, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class DerivedTag : RootTag {
    public:
    /*
     * Constructs a DerivedTag.
     *
     * Takes no parameters.
     *
     * Returns the constructed DerivedTag.
     */
    DerivedTag() {
        super RootTag()
    }
}

/*
 * Pick is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Pick {
    public:
    /*
     * Constructs a Pick.
     *
     * Takes no parameters.
     *
     * Returns the constructed Pick.
     */
    Pick() {
        print("zero")
    }

    /*
     * Constructs a Pick.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Pick.
     */
    Pick(int64 value) {
        print("int")
    }

    /*
     * Constructs a Pick.
     *
     * Parameters:
     *   first — int64 first.
     *   second — int64 second.
     *
     * Returns the constructed Pick.
     */
    Pick(int64 first, int64 second) {
        print("two")
    }

    /*
     * Constructs a Pick.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns the constructed Pick.
     */
    Pick(strg value) {
        print("string")
    }

    /*
     * Constructs a Pick.
     *
     * Parameters:
     *   value — RootTag value.
     *
     * Returns the constructed Pick.
     */
    Pick(RootTag value) {
        print("root")
    }

    /*
     * Constructs a Pick.
     *
     * Parameters:
     *   value — DerivedTag value.
     *
     * Returns the constructed Pick.
     */
    Pick(DerivedTag value) {
        print("derived")
    }
}

/*
 * BaseOnly is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class BaseOnly {
    public:
    /*
     * Constructs a BaseOnly.
     *
     * Parameters:
     *   value — RootTag value.
     *
     * Returns the constructed BaseOnly.
     */
    BaseOnly(RootTag value) {
        print("base-only")
    }
}

/*
 * MethodChoice is a class, used as a fixture by this test.
 *
 * Its methods include choose.
 */
class MethodChoice {
    public:
    /*
     * Returns 1.
     *
     * Parameters:
     *   value — RootTag value.
     *
     * Returns int64.
     */
    int64 choose(RootTag value) {
        return(1)
    }

    /*
     * Returns 2.
     *
     * Parameters:
     *   value — DerivedTag value.
     *
     * Returns int64.
     */
    int64 choose(DerivedTag value) {
        return(2)
    }
}

/*
 * Base is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Base {
    public:
    /*
     * Constructs a Base.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Base.
     */
    Base(int64 value) {
        print("base int")
    }

    /*
     * Constructs a Base.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns the constructed Base.
     */
    Base(strg value) {
        print("base string")
    }
}

/*
 * ChildBase is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class ChildBase : Base {
    public:
    /*
     * Constructs a ChildBase.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed ChildBase.
     */
    ChildBase(int64 value) {
        super Base(value)
    }
}

/*
 * VirtualRoot is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class VirtualRoot {
    public:
    /*
     * Constructs a VirtualRoot.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed VirtualRoot.
     */
    VirtualRoot(int64 value) {
        print("virtual int")
    }

    /*
     * Constructs a VirtualRoot.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns the constructed VirtualRoot.
     */
    VirtualRoot(strg value) {
        print("virtual string")
    }
}

/*
 * VirtualChild is a class derived from VirtualRoot, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class VirtualChild : virtual VirtualRoot {
    public:
    /*
     * Constructs a VirtualChild.
     *
     * Parameters:
     *   value — strg value.
     *
     * Returns the constructed VirtualChild.
     */
    VirtualChild(strg value) {
        super virtual VirtualRoot(value)
    }
}

/*
 * Empty is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Empty {
}

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
