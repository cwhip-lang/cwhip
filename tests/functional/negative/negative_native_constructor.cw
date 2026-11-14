class NativeCtor {
    public:
    NativeCtor(int64 value)
}

NativeCtor NativeCtor.NativeCtor(int64 value) from "native_ctor"

start {
    NativeCtor value = NativeCtor(1)
}
