# Rejects ordinary super Base syntax for a virtual base, which requires super virtual.
class Root {
}

class Left : virtual Root {
    public:
    Left() {
        super Root()
    }
}

start {
}
