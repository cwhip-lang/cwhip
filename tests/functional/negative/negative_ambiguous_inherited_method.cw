# Rejects an unqualified method call when two bases declare the same method.
class First {
    public:
    int64 value() {
        return(1)
    }
}

class Second {
    public:
    int64 value() {
        return(2)
    }
}

class Joined : First, Second {
}

start {
    Joined joined = Joined()
    print(joined.value())
}
