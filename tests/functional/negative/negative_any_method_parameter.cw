# Rejects an any-typed method parameter.
class Holder {
    public:
    int64 use(any value) { return(1)}
}

start {
    print(1)
}
