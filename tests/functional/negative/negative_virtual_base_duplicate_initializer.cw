# Rejects initializing the same virtual base twice in one constructor.
class Root {
    public:
    Root(int64 value) {
    }
}

class Leaf : virtual Root {
    public:
    Leaf() {
        super virtual Root(1)
        super virtual Root(2)
    }
}

start {
}
