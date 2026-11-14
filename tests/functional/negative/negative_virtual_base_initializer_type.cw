# Rejects passing a string to a virtual base constructor that requires an integer.
class Root {
    public:
    Root(int64 value) {
    }
}

class Leaf : virtual Root {
    public:
    Leaf() {
        super virtual Root("wrong")
    }
}

start {
    Leaf leaf = Leaf()
}
