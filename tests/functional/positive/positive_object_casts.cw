class Foo {
    public:
    int64 value
    Foo(int64 initial) { value = initial }
    int64 read() { return(value)}
    int64 with(int64 extra) { return(value + extra)}
}
class Bar : Foo {
    public:
    Bar(int64 initial) { super Foo(initial) }
    int64 read() { return(value + 100)}
}
class Other {}
class First { public: int64 marker }
class Secondary : First, Foo {
    public:
    Secondary() {
        super First()
        super Foo(23)
    }
}
class Left : virtual Foo {}
class Right : virtual Foo {}
class Diamond : Left, Right {
    public:
    Diamond() {
        super virtual Foo(31)
        super Left()
        super Right()
    }
}
class NonvirtualLeft : Foo {
    public:
    NonvirtualLeft() { super Foo(1) }
}
class NonvirtualRight : Foo {
    public:
    NonvirtualRight() { super Foo(2) }
}
class Ambiguous : NonvirtualLeft, NonvirtualRight {
    public:
    Ambiguous() {
        super NonvirtualLeft()
        super NonvirtualRight()
    }
}
class Factory {
    public:
    int64 calls
    Foo make() {
        calls += 1
        return(Bar(calls))
    }
    int64 index() {
        calls += 1
        return(0)
    }
    int64 collect() {
        inline { cwhip_gc_collect(); }
        return(1)
    }
}
namespace model {
    class Named { public: int64 read() { return(47)} }
}
start {
    list values = [Foo(7), Bar(11), null, Other(), 42, "text", [1], ["x": 1], buffer(1)]
    print((values[0] as Foo).read())
    print((values[1] as Foo).read())
    Foo extracted = values[1]
    print(extracted.read())
    Foo empty = values[2] as Foo
    print(empty == null)
    print((null as Foo) == null)
    Foo nullable = null
    print((nullable as Bar) == null)
    Foo base = Bar(13)
    print((base as Bar).read())
    print((base as Foo).read())
    print((Bar(17) as Foo as Bar).read())
    dict mapping = ["foo": Bar(19), "empty": null]
    print((mapping["foo"] as Foo).read())
    print((mapping["empty"] as Foo) == null)
    Factory factory = Factory()
    print((factory.make() as Bar).read())
    print(factory.calls)
    print((values[factory.index()] as Foo).read())
    print(factory.calls)
    print(([Bar(59)][0] as Foo).with(factory.collect()))
    print(([model.Named()][0] as model.Named).read())
    list secondary = [Secondary()]
    print((secondary[0] as Foo).read())
    Foo secondaryBase = secondary[0]
    print(secondaryBase.read())
    print((secondaryBase as Secondary).Foo.read())
    list diamond = [Diamond()]
    print((diamond[0] as Foo).read())
    Foo virtualBase = diamond[0]
    print(virtualBase.read())
    print((virtualBase as Diamond).Left.Foo.read())
    for (item in values) {
        try {
            Foo cast = item as Foo
            print(cast == null)
        } except(Exception) {
            print("type mismatch caught")
        }
    }
    try {
        Foo bad = Other() as Foo
    } except(Exception) {
        print("unrelated reference caught")
    }
    try {
        Bar bad = Foo(1) as Bar
    } except(Exception) {
        print("failed downcast caught")
    }
    try {
        Foo bad = Ambiguous() as Foo
    } except(Exception) {
        print("ambiguous base caught")
    }
    list handles = []
    handle opaque = null
    handles = [opaque]
    try {
        Foo bad = handles[0] as Foo
    } except(Exception) {
        print("handle mismatch caught")
    }
    Foo rooted = ([Bar(53)][0] as Foo)
    inline {
        cwhip_gc_collect();
    }
    list pressure = []
    int64 count = 0
    while (count < 2000) {
        pressure = [Foo(count)]
        count += 1
    }
    print(rooted.read())
}
