# Rejects constructing a derived class without providing required arguments for its virtual base.
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

start {
    Left left = Left()
}
