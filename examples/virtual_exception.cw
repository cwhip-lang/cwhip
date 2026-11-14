/*
    This contrived example shows how the proper handler is reached when there 
    is a diamond shaped inheritance.
 */

class ExceptionBase: Exception { 

    public:
    ExceptionBase(strg val) {
        super Exception(val)
    }

}

class LeftException: virtual ExceptionBase {

    public:
    LeftException() {
        #super virtual ExceptionBase(val)
    }
}

class RightException: virtual ExceptionBase {

    public:
    RightException() {
        # super virtual ExceptionBase(val)
    }
}

class ChildException: LeftException, RightException {

    public:
    ChildException(strg val) {
        super virtual ExceptionBase(val)
        super LeftException()
        super RightException()
    }
}

class Thrower {

    public:
    void throw() {
        raise(ChildException("this is the string"))
    }
}

start {

    try {
        Thrower t()
        t.throw()
    }
    except(ChildException) as child {
        print(child.message)
        print("Child was caught")
    }
    except(RightException) as right {
        print(right.message)
        print("Right was caught")
    }
    except(LeftException) as left {
        print(left.message)
        print("Left was caught")
    }
    finally {
        print("Finally block")
    }

    print("after the exception handlers")

}