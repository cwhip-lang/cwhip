# Rejects reusing one C symbol for native methods with incompatible ABI signatures.
class Native {
    public:
    int64 integerValue(int64 value)
    strg stringValue(strg value)
}

int64 Native.integerValue(int64 value) from "same_c_symbol"
strg Native.stringValue(strg value) from "same_c_symbol"

start {
    print(1)
}
