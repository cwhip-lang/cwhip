# Verifies object fields can be updated by methods and then read through both methods and direct member access.
class Counter {
    public:
    int64 value

    Counter(int64 initial) {
        value = initial
    }

    int64 add(int64 amount) {
        value = value + amount
        return(value)
    }

    int64 get() {
        return(value)
    }
}

start {
    Counter counter = null
    counter = Counter(40)
    print(counter.add(2))
    print(counter.get())
    print(counter.value)
}
