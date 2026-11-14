# Rejects placing a virtual-base initializer after a direct-base initializer.
class Root {
    public:
    Root(int64 value) {
    }
}

class Left : virtual Root {
    public:
    Left() {
    }
}

class Leaf : Left {
    public:
    Leaf() {
        super Left()
        super virtual Root(1)
    }
}

start {
}
