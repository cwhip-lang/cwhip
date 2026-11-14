class Values {
    public:
    enum {
        FIRST = 123,
        NEXT,
        DOUBLE = FIRST * 2,
        MINIMUM = -0x8000000000000000,
        MAXIMUM = 0x7fffffffffffffff,
        SAME_VALUE = 123,
    }

    int64 read() {
        return(FIRST)
    }

    int64 echo(int64 value) {
        return(value)
    }
}

class Child : Values {}

class Probe {
    public:
    Values value
    int64 calls

    Probe(Values initial) {
        value = initial
        calls = 0
    }

    Values next() {
        calls += 1
        return(value)
    }
}

namespace Named {
    class Item {
        public:
        enum { VALUE = 50 }
    }
}

start {
    Values values = Values()
    print(values.FIRST)
    print(Values.NEXT)
    print(values.DOUBLE)
    print(values.MINIMUM)
    print(values.MAXIMUM)
    print(values.SAME_VALUE)
    print(values.read())
    print(values.echo(Values.NEXT))

    Child child = Child()
    print(child.NEXT)
    print(child.Values.FIRST)
    print(Named.Item.VALUE)

    Probe probe = Probe(values)
    print(probe.next().FIRST)
    print(probe.calls)

    Values absent = null
    print(absent.FIRST)

    list valuesList = [Values.FIRST, values.NEXT]
    print(valuesList[0])
    print(valuesList[1])
    print(int64(Values.FIRST))
}
