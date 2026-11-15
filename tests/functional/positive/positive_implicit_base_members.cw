/*
 * tests/functional/positive/positive_implicit_base_members.cw
 *
 * Checks implicit base members.
 *
 * Created: 2026-10-02
 * Author: chuck
 *
 * Changelog:
 *   2026-10-02  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * FirstBase is a class, used as a fixture by this test.
 *
 * Its methods include constructor, method.
 */
class FirstBase {
    public:
    int64 bar
    int64 foo

    /*
     * Constructs a FirstBase and stores bar, foo.
     *
     * Takes no parameters.
     *
     * Returns the constructed FirstBase.
     */
    FirstBase() {
        bar = 24
        foo = 123
    }

    /*
     * Returns foo + n.
     *
     * Parameters:
     *   n — int64 input value.
     *
     * Returns int64.
     */
    int64 method(int64 n) {
        return(foo + n)
    }

    /*
     * Handles method for this FirstBase.
     *
     * Parameters:
     *   n — bool input value.
     *
     * Returns int64.
     */
    int64 method(bool n) {
        if (n) {
            return(foo)
        }
        else {
            return(0)
        }
    }
}

/*
 * SecondBase is a class, used as a fixture by this test.
 *
 * Its methods include constructor, method.
 */
class SecondBase {
    public:
    int64 foo

    /*
     * Constructs a SecondBase and stores foo.
     *
     * Takes no parameters.
     *
     * Returns the constructed SecondBase.
     */
    SecondBase() {
        foo = 42
    }

    /*
     * Returns foo + n.
     *
     * Parameters:
     *   n — int64 input value.
     *
     * Returns int64.
     */
    int64 method(int64 n) {
        return(foo + n)
    }
}

/*
 * Child is a class derived from FirstBase, SecondBase, used as a fixture by
 * this test.
 *
 * Its methods include constructor, change.
 */
class Child: public FirstBase, private SecondBase {
    public:
    /*
     * Constructs a Child.
     *
     * Takes no parameters.
     *
     * Returns the constructed Child.
     */
    Child() {
        super FirstBase()
        super SecondBase()
        print(format("first foo is {}", FirstBase.foo))
        print(format("second foo is {}", SecondBase.foo))
    }

    /*
     * Handles change for this Child.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void change() {
        FirstBase.foo = 10
        FirstBase.foo += 5
        FirstBase.foo -= 2
        FirstBase.foo *= 4
        FirstBase.foo /= 2
        FirstBase.foo %= 7
        SecondBase.foo += FirstBase.foo
        print(FirstBase.method(1))
        print(FirstBase.method(true))
        print(SecondBase.method(1))
    }

    /*
     * Destroys this object and runs the cleanup owned by the instance.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    destroy {
        print("in the Child destructor")
        print(FirstBase.foo)
        print(SecondBase.foo)
    }
}

/*
 * Root is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Root {
    public:
    int64 value
    uint64 bits
    fp64 fraction

    /*
     * Constructs a Root and stores value, bits, fraction.
     *
     * Takes no parameters.
     *
     * Returns the constructed Root.
     */
    Root() {
        value = 3
        bits = 10
        fraction = 1.5
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
}

/*
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Left: Root {

    /*
     * Constructs a Left.
     *
     * Takes no parameters.
     *
     * Returns the constructed Left.
     */
    public: Left() {
        super Root()
    }
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Right: Root {

    /*
     * Constructs a Right.
     *
     * Takes no parameters.
     *
     * Returns the constructed Right.
     */
    public: Right() {
        super Root()
    }
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * Its methods include constructor, change.
 */
class Diamond: Left, Right {
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
    }

    /*
     * Handles change for this Diamond.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void change() {
        Left.Root.value = 20
        Right.Root.value += 4
        Left.Root.bits += 2u
        Left.Root.bits %= 5u
        Left.Root.fraction *= 2.0
        print(Left.Root.read())
        print(Right.Root.read())
        print(Left.Root.bits)
        print(Left.Root.fraction)
    }
}

/*
 * VirtualLeft is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class VirtualLeft: virtual Root {
}

/*
 * VirtualRight is a class derived from Root, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class VirtualRight: virtual Root {
}

/*
 * Shared is a class derived from VirtualLeft, VirtualRight, used as a fixture
 * by this test.
 *
 * Its methods include change.
 */
class Shared: VirtualLeft, VirtualRight {
    public:
    /*
     * Handles change for this Shared.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void change() {
        VirtualLeft.Root.value += 6
        print(VirtualRight.Root.read())
    }
}

/*
 * DispatchBase is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class DispatchBase {
    public:
    /*
     * Returns 11.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(11)
    }
}

/*
 * Padding is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Padding {
    public: int64 unused
}

/*
 * DispatchChild is a class derived from Padding, DispatchBase, used as a
 * fixture by this test.
 *
 * Its methods include read, qualified.
 */
class DispatchChild: Padding, DispatchBase {
    public:
    /*
     * Returns 99.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(99)
    }

    /*
     * Returns DispatchBase.read().
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 qualified() {
        return(DispatchBase.read())
    }
}

/*
 * Object is a class, used as a fixture by this test.
 *
 * Its methods include constructor, method.
 */
class Object {
    public:
    int64 foo

    /*
     * Constructs a Object and stores foo.
     *
     * Takes no parameters.
     *
     * Returns the constructed Object.
     */
    Object() {
        foo = 88
    }

    /*
     * Returns the stored foo.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 method() {
        return(foo)
    }
}

/*
 * FieldCollision is a class derived from FirstBase, used as a fixture by this
 * test.
 *
 * Its methods include constructor, check.
 */
class FieldCollision: FirstBase {
    public:
    Object FirstBase

    /*
     * Constructs a FieldCollision and stores FirstBase.
     *
     * Takes no parameters.
     *
     * Returns the constructed FieldCollision.
     */
    FieldCollision() {
        super FirstBase()
        FirstBase = Object()
    }

    /*
     * Handles check for this FieldCollision.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void check() {
        print(FirstBase.foo)
        print(FirstBase.method())
    }
}

/*
 * LocalCollision is a class derived from FirstBase, used as a fixture by this
 * test.
 *
 * Its methods include constructor, check.
 */
class LocalCollision: FirstBase {
    public:
    /*
     * Constructs a LocalCollision.
     *
     * Takes no parameters.
     *
     * Returns the constructed LocalCollision.
     */
    LocalCollision() {
        super FirstBase()
    }

    /*
     * Handles check for this LocalCollision.
     *
     * Parameters:
     *   FirstBase — Object first base.
     *
     * Does not return a value.
     */
    void check(Object FirstBase) {
        FirstBase.foo += 1
        print(FirstBase.method())
    }
}

namespace N {

    /*
     * Base is a class, used as a fixture by this test.
     *
     * Its methods include constructor, read.
     */
    class Base {
        public:
        int64 value

        /*
         * Constructs a Base and stores value.
         *
         * Takes no parameters.
         *
         * Returns the constructed Base.
         */
        Base() {
            value = 17
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
    }

    /*
     * Derived is a class derived from Base, used as a fixture by this test.
     *
     * Its methods include constructor, check.
     */
    class Derived: Base {
        public:
        /*
         * Constructs a Derived.
         *
         * Takes no parameters.
         *
         * Returns the constructed Derived.
         */
        Derived() {
            super Base()
        }

        /*
         * Handles check for this Derived.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void check() {
            Base.value += 1
            print(N.Base.value)
            print(Base.read())
            Base other = N.Base()
            print(other.read())
            type name = N.Base
            print(name == N.Base)
        }
    }
}

start {
    Child f = Child()
    print(f.bar)
    print(f.FirstBase.method(0))
    f.change()
    f.destroy()
    Diamond diamond = Diamond()
    diamond.change()
    print(diamond.Left.Root.value)
    print(diamond.Right.Root.read())
    Shared shared = Shared()
    shared.change()
    print(shared.VirtualLeft.Root.value)
    DispatchChild dispatch = DispatchChild()
    print(dispatch.qualified())
    print(dispatch.DispatchBase.read())
    FieldCollision field = FieldCollision()
    field.check()
    LocalCollision local = LocalCollision()
    local.check(Object())
    N.Derived namespaced = N.Derived()
    namespaced.check()
}
