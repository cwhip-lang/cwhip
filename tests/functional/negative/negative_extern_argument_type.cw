# Rejects passing a string to a native-bound method parameter declared as int.
class Native {
    public:
    int64 absolute(int64 value)
}

int64 Native.absolute(int64 value) from "cwhip_method_demo_abs"

start {
    strg text = "not an integer"
    print(Native().absolute(text))
}
