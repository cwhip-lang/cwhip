# The class being constructed directly must initialize a non-defaultable
# virtual base even though its intermediate base supplies an initializer.
class A {
    public:
    A(int64 value) {
    }
}

class B : virtual A {
    public:
    B() {
        super virtual A(1)
    }
}

class C : B {
    public:
    C() {
        super B()
    }
}

start {
    C value = C()
}
