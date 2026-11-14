# Rejects virtual-base initializers ordered differently from the transitive construction order.
class Ancestor {
    public:
    Ancestor(int64 value) {
    }
}

class Root : virtual Ancestor {
    public:
    Root(int64 value) {
    }
}

class Left : virtual Root {
}

class Right : virtual Root {
}

class Diamond : Left, Right {
    public:
    Diamond() {
        super virtual Root(2)
        super virtual Ancestor(1)
        super Left()
        super Right()
    }
}

start {
}
