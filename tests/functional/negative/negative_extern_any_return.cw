# Rejects declared any types in native method return values.
class Native {
    public:
    any dynamicValue(int64 value)
}

any Native.dynamicValue(int64 value) from "some_symbol"

start {
    print(1)
}
