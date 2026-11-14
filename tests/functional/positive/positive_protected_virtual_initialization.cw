class Ancestor {
    public:
    Ancestor() { print("ancestor") }
    destroy { print("ancestor destroyed") }
}
class Root : virtual Ancestor {
    public:
    int64 value
    Root(int64 initial) {
        print("root")
        if (initial < 0) { raise(Exception("virtual failure")) }
        value = initial
    }
    destroy { print("root destroyed") }
}
class Left : virtual Root {
    public:
    Left() { print("left") }
}
class Right : virtual Root {
    public:
    Right() { print("right") }
}
class Diamond : Left, Right {
    public:
    Diamond(int64 initial)
}
Diamond Diamond.Diamond(int64 initial) {
    try {
        super virtual Root(initial)
        super Left()
        super Right()
    } except() as message {
        print(message)
        raise()
    } finally { print("virtual cleanup") }
    print("diamond")
}
class DefaultRoot {
    public:
    DefaultRoot() { raise(Exception("automatic virtual failure")) }
    destroy { print("INVALID default root destructor") }
}
class DefaultLeft : virtual DefaultRoot {
    public:
    DefaultLeft() { print("INVALID default left continuation") }
}
class DefaultDiamond : DefaultLeft {
    public:
    DefaultDiamond() {
        try { super DefaultLeft() }
        except() {
            print("automatic virtual caught")
            raise()
        }
    }
}
start {
    try { Diamond failed(-1) }
    except() as message { print(message) }
    try { DefaultDiamond failed() }
    except() as message { print(message) }
    Diamond good(42)
    print(good.Left.Root.value)
    print(good.Right.Root.value)
    good.destroy()
    inline { cwhip_gc_collect(); }
}
