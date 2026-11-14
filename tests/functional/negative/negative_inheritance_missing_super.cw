# Rejects a derived constructor that does not initialize its direct base first.
class Base {
    public:
    Base() {}
}

class Child : Base {
    public:
    Child() {}
}

start {}
