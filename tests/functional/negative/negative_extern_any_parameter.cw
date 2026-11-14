# Rejects declared any types in native method parameters.
class Native {
    public:
    int64 use(any value)
}

int64 Native.use(any value) from "some_symbol"

start {
    print(1)
}
