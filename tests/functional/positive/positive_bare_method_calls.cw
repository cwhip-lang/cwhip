class Counter {
    public:
    int64 value

    void step() {
        value = value + 1
    }

    void run() {
        step()
        print(value)
    }

    int64 sum(int64 n) {
        if (n == 0) {
            return(0)
        }
        return(n + sum(n - 1))
    }
}

start {
    Counter counter = Counter()
    counter.run()
    print(counter.sum(4))
}
