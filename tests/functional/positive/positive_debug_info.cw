class Number {
    public:
    int64 double(int64 value) {
        int64 doubled = value * 2
        return(doubled)
    }
}
start {
    int64 debugger_local = 42
    print(debugger_local)
    Number number = Number()
    int64 answer = number.double(21)
    answer = answer + 1
    answer = answer + 1
}
