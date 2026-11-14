# Exercises method overloading: several same-named methods distinguished by
# parameter type, resolved by exact argument-type match and dispatched
# through type-encoded mangled symbols. Also checks that an overload set
# survives inheritance -- a derived class may override one overload while
# inheriting its siblings, and may add a new overload of its own -- and that
# all of them dispatch correctly through a base-typed reference.
class Formatter {
    public:
    Formatter() {}

    int64 describe() {
        return(1)
    }

    int64 describe(int64 value) {
        return(value + 10)
    }

    int64 describe(fp64 value) {
        return(2)
    }

    int64 describe(strg value) {
        return(3)
    }

    int64 describe(int64 first, int64 second) {
        return(first + second)
    }
}

class LoudFormatter : Formatter {
    public:
    LoudFormatter() {
        super Formatter()
    }

    # Overrides exactly one member of the inherited overload set; the
    # zero-argument, float, string, and two-int overloads are inherited.
    int64 describe(int64 value) {
        return(value + 100)
    }

    # Adds a brand new overload that the base class does not declare.
    int64 describe(bool value) {
        return(55)
    }
}

start {
    Formatter plain = Formatter()
    print(plain.describe())
    print(plain.describe(int64(5)))
    print(plain.describe(fp64(1.5)))
    print(plain.describe("text"))
    print(plain.describe(int64(3), int64(4)))

    LoudFormatter loud = LoudFormatter()
    print(loud.describe())
    print(loud.describe(int64(5)))
    print(loud.describe(fp64(1.5)))
    print(loud.describe(true))
    print(loud.describe(int64(3), int64(4)))

    # Virtual dispatch through a base-typed reference must still reach the
    # derived override for the int overload, and the inherited
    # implementations for the others.
    Formatter view = loud
    print(view.describe())
    print(view.describe(int64(5)))
    print(view.describe(int64(3), int64(4)))
}
