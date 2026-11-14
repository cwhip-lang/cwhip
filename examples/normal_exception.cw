/*
    Demonstrate normal exception handling.
*/

class ExceptionClass: Exception {

    public:
    ExceptionClass(strg val) {
        super Exception(val)
    }
}

class Thrower {

    public:
    void throw(strg val) {
        raise(ExceptionClass(val))
    }
}

start {

    try {
        Thrower t()
        t.throw("error message")
    }
    except(ExceptionClass) as msg {
        print("catch exception class")
        print(msg.message)
    }
    except() as msg {
        print("catch anything else")
        print(msg)
    }
    finally {
        print("finally clause")
    }
}