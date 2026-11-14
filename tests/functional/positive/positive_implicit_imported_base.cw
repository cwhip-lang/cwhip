import greeting as Parent

class Derived: Parent {
    public:
    Derived() {
        super Parent()
        print(Parent.answer())
    }
    int64 read() { return(Parent.answer())}
}

start {
    Derived value = Derived()
    print(value.read())
}
