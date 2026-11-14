# Constructs a class by its fully qualified name and calls its method.
namespace Foo {
    class Bar {
        public:
        int64 method() {
            return(42)
        }
    }
}

start {
    print(Foo.Bar().method())
}
