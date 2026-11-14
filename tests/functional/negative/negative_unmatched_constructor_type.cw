class OnlyInt {
    public:
    OnlyInt(int64 value) {}
}

start {
    OnlyInt value = OnlyInt("wrong")
}
