# Checks parenthesized return expressions and an empty return in an out-of-line void method.
class Foo {
    public:
    int64 compute(int64 x)
    void announce()
}

int64 Foo.compute(int64 x) {
    return(x * 2)
}

void Foo.announce() {
    return()
}

start {
    Foo foo = Foo()
    print(foo.compute(5))
    foo.announce()
    print(1)
}
