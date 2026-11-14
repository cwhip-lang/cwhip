# Dotted forms are no longer valid base-initializer syntax.
class Base {
    public:
    Base() {
    }
}

class Child : Base {
    public:
    Child() {
        super.Base()
    }
}

start {
}
