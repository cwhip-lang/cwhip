/*
 * tests/functional/positive/positive_object_casts.cw — Checks object casts.
 *
 * Created: 2026-10-04
 * Author: chuck
 *
 * Changelog:
 *   2026-10-04  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Foo is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read, with.
 */
class Foo {
    public:
    int64 value

    /*
     * Constructs a Foo and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Foo.
     */
    Foo(int64 initial) {
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
     * Returns value + extra.
     *
     * Parameters:
     *   extra — int64 extra.
     *
     * Returns int64.
     */
    int64 with(int64 extra) {
        return(value + extra)
    }
}

/*
 * Bar is a class derived from Foo, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Bar : Foo {
    public:
    /*
     * Constructs a Bar.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Bar.
     */
    Bar(int64 initial) {
        super Foo(initial)
    }

    /*
     * Returns value + 100.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(value + 100)
    }
}

/*
 * Other is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Other {
}

/*
 * First is a class, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class First {
    public: int64 marker
}

/*
 * Secondary is a class derived from First, Foo, used as a fixture by this
 * test.
 *
 * Its methods include constructor.
 */
class Secondary : First, Foo {
    public:
    /*
     * Constructs a Secondary.
     *
     * Takes no parameters.
     *
     * Returns the constructed Secondary.
     */
    Secondary() {
        super First()
        super Foo(23)
    }
}

/*
 * Left is a class derived from Foo, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Left : virtual Foo {
}

/*
 * Right is a class derived from Foo, used as a fixture by this test.
 *
 * It groups the data used by the surrounding program.
 */
class Right : virtual Foo {
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * Its methods include constructor.
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
        super virtual Foo(31)
        super Left()
        super Right()
    }
}

/*
 * NonvirtualLeft is a class derived from Foo, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class NonvirtualLeft : Foo {
    public:
    /*
     * Constructs a NonvirtualLeft.
     *
     * Takes no parameters.
     *
     * Returns the constructed NonvirtualLeft.
     */
    NonvirtualLeft() {
        super Foo(1)
    }
}

/*
 * NonvirtualRight is a class derived from Foo, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class NonvirtualRight : Foo {
    public:
    /*
     * Constructs a NonvirtualRight.
     *
     * Takes no parameters.
     *
     * Returns the constructed NonvirtualRight.
     */
    NonvirtualRight() {
        super Foo(2)
    }
}

/*
 * Ambiguous is a class derived from NonvirtualLeft, NonvirtualRight, used as a
 * fixture by this test.
 *
 * Its methods include constructor.
 */
class Ambiguous : NonvirtualLeft, NonvirtualRight {
    public:
    /*
     * Constructs a Ambiguous.
     *
     * Takes no parameters.
     *
     * Returns the constructed Ambiguous.
     */
    Ambiguous() {
        super NonvirtualLeft()
        super NonvirtualRight()
    }
}

/*
 * Factory is a class, used as a fixture by this test.
 *
 * Its methods include make, index, collect.
 */
class Factory {
    public:
    int64 calls

    /*
     * Handles make for this Factory.
     *
     * Takes no parameters.
     *
     * Returns Foo.
     */
    Foo make() {
        calls += 1
        return(Bar(calls))
    }

    /*
     * Handles index for this Factory.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 index() {
        calls += 1
        return(0)
    }

    /*
     * Runs inline C while handling collect.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 collect() {
        inline { cwhip_gc_collect(); }
        return(1)
    }
}
namespace model {

    /*
     * Named is a class, used as a fixture by this test.
     *
     * Its methods include read.
     */
    class Named {

        /*
         * Returns 47.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        public: int64 read() {
            return(47)
        }
    }
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
        }
        except(Exception) {
            print("type mismatch caught")
        }
    }
    try {
        Foo bad = Other() as Foo
    }
    except(Exception) {
        print("unrelated reference caught")
    }
    try {
        Bar bad = Foo(1) as Bar
    }
    except(Exception) {
        print("failed downcast caught")
    }
    try {
        Foo bad = Ambiguous() as Foo
    }
    except(Exception) {
        print("ambiguous base caught")
    }
    list handles = []
    handle opaque = null
    handles = [opaque]
    try {
        Foo bad = handles[0] as Foo
    }
    except(Exception) {
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
