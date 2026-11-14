# Covers construction and conversion through secondary bases, qualified subobjects, dispatch, and destructor failures.
class Payload {
    public:
    int64 value

    Payload(int64 initial) {
        value = initial
    }
}

class Root {
    public:
    int64 value

    Root(int64 initial) {
        value = initial
    }

    int64 read() {
        return(value)
    }

    int64 readValue() {
        return(value)
    }

    destroy {
        print(value)
    }
}

class Left : Root {
    public:
    Left(int64 initial) {
        super Root(initial)
    }

    destroy {
        print("Left")
    }
}

class Right : Root {
    public:
    Payload payload

    Right(int64 initial) {
        super Root(initial)
        payload = Payload(initial + 20)
    }

    destroy {
        print("Right")
        raise(Exception("secondary destructor failure"))
    }
}

class Diamond : Left, Right {
    public:
    Diamond(int64 left, int64 right) {
        super Left(left)
        super Right(right)
    }

    int64 read() {
        return(77)
    }

    int64 sum() {
        return(77)
    }

    destroy {
        print("Diamond")
    }
}

class Reader {
    public:
    int64 readRoot(Root root) {
        return(root.read())
    }
}

class Factory {
    public:
    Root fromRight(Right right) {
        return(right)
    }
}

class FailingSide {
    public:
    FailingSide() {
        raise(Exception("secondary constructor failure"))
    }

    destroy {
        print("must not destroy failed object")
    }
}

class Failing : Root, FailingSide {
    public:
    Failing() {
        super Root(0)
        super FailingSide()
    }

    destroy {
        print("must not destroy failed object")
    }
}

start {
    Diamond diamond = Diamond(4, 8)
    Left leftView = diamond
    Right rightView = diamond
    Root leftRoot = leftView
    Root rightRoot = rightView
    Reader reader = Reader()
    Factory factory = Factory()
    print(leftRoot.read())
    print(rightRoot.read())
    print(diamond.Right.Root.read())
    print(reader.readRoot(rightView))
    print(factory.fromRight(rightView).read())
    print(leftRoot.readValue())
    print(rightRoot.readValue())
    print(diamond.Left.Root.value + diamond.Right.Root.value)
    print(diamond.Right.payload.value)
    Payload trigger = Payload(99)
    print(rightView.payload.value)
    print(diamond.sum())
    try {
        rightView.destroy()
    } except() as failure {
        print(failure)
    }
    try {
        Failing failed = Failing()
    } except() as constructorFailure {
        print(constructorFailure)
    }
}
