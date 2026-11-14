# Rejects providing two out-of-line native definitions for the same declared method.
class Native {
    public:
    int64 absolute(int64 value)
}

int64 Native.absolute(int64 value) from "cwhip_method_demo_abs"
int64 Native.absolute(int64 value) from "cwhip_method_demo_abs"

start {
    print(1)
}
