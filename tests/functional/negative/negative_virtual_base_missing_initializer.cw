# Rejects a most-derived constructor that omits a required virtual-base initializer.
class Root {
    public:
    Root(int64 value) {
    }
}

class Leaf : virtual Root {
    public:
    Leaf() {
    }
}

start {
    Leaf leaf = Leaf()
}
