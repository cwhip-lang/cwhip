# Each overload binds to its own out-of-line definition: the declaration,
# the definition, and the emitted symbol are all keyed by parameter types,
# not just the method name.
class Calc {
    public:
    int64 scale(int64 v)
    int64 scale(int64 v, int64 by)
}

int64 Calc.scale(int64 v) {
    return(v * 2)
}

int64 Calc.scale(int64 v, int64 by) {
    return(v * by)
}

start {
    Calc c = Calc()
    print(c.scale(5))
    print(c.scale(5, 3))
}
