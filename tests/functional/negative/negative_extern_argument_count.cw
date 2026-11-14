# Rejects a native-bound method call with more arguments than its declaration.
class Native {
    public:
    int64 absolute(int64 value)
}

int64 Native.absolute(int64 value) from "cwhip_method_demo_abs"

start {
    print(Native().absolute(1, 2))
}
