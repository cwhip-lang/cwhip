/*
    Re-raise an exception after it was already caught.
 */

class Foo {

    public:
    Foo() {
        raise(Exception("this is the string"))
    }
}

class Bar : Foo {

    public:
    Bar() {
        try {
            super Foo()
        }
        except() {
            print("caught the first time")
            raise()
        }
    }
}

start {

    try {
        Bar b()
    }
    except() as e {
        print(e)
        print("caught the second time")
    }
}
