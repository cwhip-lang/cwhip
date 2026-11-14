class FirstBase {
    public:
    int64 bar
    int64 foo
    FirstBase() {
        bar = 24
        foo = 123
    }
    int64 method(int64 n) { return(foo + n)}
    int64 method(bool n) { if (n) { return(foo)} else { return(0)} }
}

class SecondBase {
    public:
    int64 foo
    SecondBase() { foo = 42 }
    int64 method(int64 n) { return(foo + n)}
}

class Child: public FirstBase, private SecondBase {
    public:
    Child() {
        super FirstBase()
        super SecondBase()
        print(format("first foo is {}", FirstBase.foo))
        print(format("second foo is {}", SecondBase.foo))
    }
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
    destroy {
        print("in the Child destructor")
        print(FirstBase.foo)
        print(SecondBase.foo)
    }
}

class Root {
    public:
    int64 value
    uint64 bits
    fp64 fraction
    Root() {
        value = 3
        bits = 10
        fraction = 1.5
    }
    int64 read() { return(value)}
}
class Left: Root { public: Left() { super Root() } }
class Right: Root { public: Right() { super Root() } }
class Diamond: Left, Right {
    public:
    Diamond() {
        super Left()
        super Right()
    }
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

class VirtualLeft: virtual Root {}
class VirtualRight: virtual Root {}
class Shared: VirtualLeft, VirtualRight {
    public:
    void change() {
        VirtualLeft.Root.value += 6
        print(VirtualRight.Root.read())
    }
}

class DispatchBase {
    public:
    int64 read() { return(11)}
}
class Padding { public: int64 unused }
class DispatchChild: Padding, DispatchBase {
    public:
    int64 read() { return(99)}
    int64 qualified() { return(DispatchBase.read())}
}

class Object {
    public:
    int64 foo
    Object() { foo = 88 }
    int64 method() { return(foo)}
}
class FieldCollision: FirstBase {
    public:
    Object FirstBase
    FieldCollision() {
        super FirstBase()
        FirstBase = Object()
    }
    void check() {
        print(FirstBase.foo)
        print(FirstBase.method())
    }
}
class LocalCollision: FirstBase {
    public:
    LocalCollision() { super FirstBase() }
    void check(Object FirstBase) {
        FirstBase.foo += 1
        print(FirstBase.method())
    }
}

namespace N {
    class Base {
        public:
        int64 value
        Base() { value = 17 }
        int64 read() { return(value)}
    }
    class Derived: Base {
        public:
        Derived() { super Base() }
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
