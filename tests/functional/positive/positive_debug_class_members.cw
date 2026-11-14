# Class member DWARF for locals and watches in cdbg.
class Point {
    public:
    int64 x
    int64 y
    Point(int64 nx, int64 ny) {
        x = nx
        y = ny
    }
}

class Base {
    public:
    int64 b
}

class Derived : Base {
    public:
    int64 d
    Derived(int64 nb, int64 nd) {
        b = nb
        d = nd
    }
}

start {
    Point point = Point(3, 4)
    Derived derived = Derived(1, 2)
    print(point.x)
    print(derived.d)
}
