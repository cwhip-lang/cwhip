# Exercises the optional 'u' suffix: an unsuffixed integer literal is a
# valid unsigned literal wherever the context already expects `unsigned`.
class Counter {
    public:
    uint64 value

    Counter(uint64 initial) {
        value = initial
    }

    uint64 get() {
        return(7)
    }
}

start {
    uint64 declared = 5
    print(declared)

    uint64 assigned = 0u
    assigned = 9
    print(assigned)

    uint64 large = 5000000000
    print(large)

    Counter counter = Counter(3)
    print(counter.value)
    print(counter.get())

    int64 plain = 5
    print(plain)
}
