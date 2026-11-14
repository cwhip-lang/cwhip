/*
    Unhandled exception prints call stack trace.
 */

class OtherException: Exception {

    public:
    OtherException(strg msg) {
        super Exception(msg)
    }
}

class SomeClass {

    public:
    SomeClass() {
        raise(Exception("This would be the error message"))
    }
}

start { 
    
    try {
        print("before the exception")
        SomeClass c()
    }
    except(OtherException) {
        print("handle other exception")
    }
    finally {
        print("seen whether the exception is handled or not")
    }

    print("should not see this")
}
