# Rejects a call whose argument types match no overload. Cwhip has no
# implicit conversions, so overload resolution is an exact-match rule: a
# bool argument does not silently select the int or float overload.
class Printer {
    public:
    Printer() {}

    int64 show(int64 value) {
        return(value)
    }

    int64 show(fp64 value) {
        return(2)
    }
}

start {
    Printer p = Printer()
    bool flag = true
    print(p.show(flag))
}
