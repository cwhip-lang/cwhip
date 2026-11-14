# Rejects an any-typed method return value.
class Holder {
    public:
    any value() { return(1)}
}

start {
    print(1)
}
