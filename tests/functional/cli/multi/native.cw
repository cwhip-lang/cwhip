class Native {
    public:
    int64 get()
}
int64 Native.get() from "cwhip_multi_external_value"
start {
    Native native = Native()
    print(native.get())
}
