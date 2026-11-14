# A const local with no initializer is still uninitialized until a store.
start {
    const int64 value
    print(value)
}
