class Bounds {
    public:
    int64 calls
    int64 capture(int64 value) {
        calls += 1
        print("capture {}\n", value)
        return(value)
    }
}
start {
    Bounds bounds = Bounds()
    int64 first = 2
    int64 last = 4
    range<int64> saved = bounds.capture(first)..bounds.capture(last)
    for (i in saved) {
        print("{} ", i)
        last = 8 // A normal write: it does not extend the captured interval.
        // i is read-only; copy it to a local if a calculation needs mutation.
    }
    print("\ncaptures: {}, source last: {}\n", bounds.calls, last)
    print("new range: {}\n", first..last)
    // Every inclusive range is nonempty; guard count > 0 before 0..count-1.
    print("0..-1 visits: ")
    for (i in 0..-1) { print("{} ", i) }
    print("\n")
}
