# Fails to link when a native method names a C symbol that does not exist.
class Native {
    public:
    int64 missing(int64 value)
}

int64 Native.missing(int64 value) from "cwhip_symbol_that_does_not_exist"

start {
    print(Native().missing(1))
}
