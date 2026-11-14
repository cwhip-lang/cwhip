# Rejects a virtual-base initializer that omits the base constructor's required argument.
class Root {
    public:
    Root(int64 value) {
    }
}

class Leaf : virtual Root {
    public:
    Leaf() {
        super virtual Root()
    }
}

start {
    Leaf leaf = Leaf()
}
