# Rejects defining a namespaced class method from a different namespace scope.
namespace A {
    class Foo {
        public:
        int64 compute()
    }
}

namespace B {
    int64 A.Foo.compute() {
        return(99)
    }
}

start {
    print(A.Foo().compute())
}
