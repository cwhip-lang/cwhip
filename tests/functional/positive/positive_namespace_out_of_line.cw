# Defines a declared method out of line within its owning namespace and invokes it.
namespace Remote {
    class Method {
        public:
        int64 value()
    }

    int64 Method.value() {
        return(42)
    }
}

start {
    print(Remote.Method().value())
}
