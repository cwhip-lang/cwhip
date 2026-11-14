# Rejects assigning a Counter object reference to a variable declared as int.
class Counter {
    public:
    int64 value
}

start {
    Counter counter = Counter()
    int64 invalid = counter
}
