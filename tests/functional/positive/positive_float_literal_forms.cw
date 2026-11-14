# float literals accept the same lexical shapes strtod() accepts: leading-dot
# (".5"), trailing-dot ("5."), digit.digit, and each of those with a decimal
# exponent. A bare "0" with no dot/exponent remains an int literal.
class App {
    public:
    App() {}
    destroy {}
    void run() {
        fp64 leadingDot = .5
        fp64 trailingDot = 5.
        fp64 digitDotDigit = 3.14
        fp64 exponentOnly = 1e3
        fp64 leadingDotExponent = .5e2
        fp64 trailingDotExponent = 5.e2
        int64 bareZero = 0

        print(format("{}", leadingDot))
        print(format("{}", trailingDot))
        print(format("{}", digitDotDigit))
        print(format("{}", exponentOnly))
        print(format("{}", leadingDotExponent))
        print(format("{}", trailingDotExponent))
        print(format("{}", bareZero))
    }
}

start {
    App a = App()
    a.run()
}
