# Rejects defining a top-level class method from inside a namespace.
class Foo {
    public:
    int64 compute()
}

namespace Other {
    int64 Foo.compute() {
        return(99)
    }
}

start {
    print(Foo().compute())
}
