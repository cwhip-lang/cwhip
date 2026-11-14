/*
    This example demonstrates constructors and destructors.
*/

class FirstBase {

    public:
    int64 bar
    int64 foo

    FirstBase(int64 n) {
        print("in the FirstBase constructor")
        init()
        foo = n
    }

    FirstBase() {
        print("in the FirstBase constructor")
        init()
        foo = 123
    }

    void modify() {
        foo += 123
    }

    destroy {
        print("in the FirstBase destructor")
    }

    private:
    void init() {
        bar = 24
    }
}

class SecondBase {

    public:
    int64 foo
    SecondBase() {
        print("in the SecondBase constructor")
        foo = 42
    }

    destroy {
        print("in the SecondBase destructor")
    }
}

class Child: public FirstBase, private SecondBase {

    public:
    Child() {
        super FirstBase()
        super SecondBase()
        print("\nin the Child constructor")
        print(format("first foo is {}", FirstBase.foo))
        print(format("second foo is {}", SecondBase.foo))
        print("end child constructor\n")
    }

    destroy {
        print("in the Child destructor")
    }
}

start {

    Child f()
    print(format("first base bar is {}", f.bar))
    f.modify()

    # correct, not private, value is chosen
    print(format("first base foo is {}\n", f.foo))

    # compiler error due to second being private to child
    # print(format("{}", f.SecondBase.foo))

    f.destroy()
}