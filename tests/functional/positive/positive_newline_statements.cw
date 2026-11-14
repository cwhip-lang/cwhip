# Checks newline-delimited statements work without semicolons and comments preserve statement boundaries.
class Base {
    public:
    int64 value
    Base(int64 initial) {
        value = initial
    }
}

class Child : Base {
    public:
    Child(int64 initial) {
        super Base(initial)
    }

    int64 read() {
        return(value)
    }
}

start {
    # Cwhip-style line comment
    Child child = Child(40)
    child.value = child.read() + 2
    # Hash line comment
    print(child.value)
    // C++-style line comment
    /* Block comment
       retaining its line boundary */
}
