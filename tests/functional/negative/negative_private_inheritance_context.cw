# Rejects accessing a privately inherited field from a further-derived class.
class Base {
    public:
    int64 value
}

class PrivateChild : private Base {
}

class Grandchild : public PrivateChild {
    public:
    int64 readValue() {
        return(value)
    }
}

start {
}
