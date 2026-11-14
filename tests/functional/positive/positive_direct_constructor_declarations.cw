class Choice {
    public:
    int64 selected

    Choice() {
        selected = 0
    }

    Choice(int64 value) {
        selected = value
    }

    Choice(strg value) {
        selected = 3
    }

    int64 read() {
        return(selected)
    }
}

class Ticker {
    public:
    int64 count

    int64 next() {
        count += 1
        return(count)
    }

    int64 read() {
        return(count)
    }
}

class Pair {
    public:
    int64 value

    Pair(int64 first, int64 second) {
        value = first * 10 + second
    }

    int64 read() {
        return(value)
    }
}

class Maker {
    public:
    Choice make() {
        Choice local(8)
        return(local)
    }

    Choice forward() {
        return(Choice(13))
    }

    Choice pass(Choice value) {
        return(value)
    }
}

namespace Geometry {
    class Point {
        public:
        int64 x

        Point(int64 initial) {
            x = initial
        }
    }
}

class Base {}

class Derived : Base {
    public:
    Derived() {
        super Base()
    }
}

start {
    Choice empty()
    Choice integer(5)
    Choice text("selected by type")
    print(empty.read())
    print(integer.read())
    print(text.read())

    Ticker ticker()
    Pair pair(ticker.next(), ticker.next())
    print(pair.read())
    print(ticker.read())

    {
        Choice nested(9)
        print(nested.read())
    }

    Maker maker()
    Choice fromMethod = maker.make()
    Choice fromArgument = maker.pass(Choice(6))
    Choice fromReturn = maker.forward()
    print(fromMethod.read())
    print(fromArgument.read())
    print(fromReturn.read())

    Base existingInitializer = Derived()
    print(existingInitializer is Derived)

    Geometry.Point point(11)
    print(point.x)
}
