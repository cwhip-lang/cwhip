# Verifies a diamond shares one virtual base and cleans up correctly when virtual-base construction fails.
class Payload {
    public:
    int64 value

    Payload(int64 initial) {
        value = initial
    }
}

class Root {
    public:
    Payload item
    int64 value

    Root() {
        print("Root+")
        value = 41
    }

    int64 read() {
        return(value)
    }

    destroy {
        print("Root-")
    }
}

class Left : virtual Root {
    public:
    Left() {
        print("Left+")
    }

    destroy {
        print("Left-")
    }
}

class Right : virtual Root {
    public:
    Right() {
        print("Right+")
    }

    destroy {
        print("Right-")
    }
}

class Diamond : Left, Right {
    public:
    Diamond() {
        super Left()
        super Right()
        print("Diamond+")
    }

    int64 read() {
        return(77)
    }

    destroy {
        print("Diamond-")
    }
}

class FailedRoot {
    public:
    FailedRoot() {
        raise(Exception("virtual initialization failed"))
    }

    destroy {
        print("wrong FailedRoot destroy")
    }
}

class FailedSide : virtual FailedRoot {
    public:
    FailedSide() {
        print("wrong side constructor")
    }
}

class FailedDiamond : FailedSide {
    public:
    FailedDiamond() {
        super FailedSide()
    }

    destroy {
        print("wrong derived destroy")
    }
}

start {
    Diamond diamond = Diamond()
    Root root = diamond
    print(diamond.value)
    print(diamond.Left.Root.value + diamond.Right.Root.value + root.value)
    diamond.Left.Root.item = Payload(50)
    Payload trigger = Payload(9)
    print(diamond.Right.Root.item.value)
    print(root.read())
    print(diamond.Right.Root.read())
    diamond.destroy()

    try {
        FailedDiamond failed = FailedDiamond()
    } except() as message {
        print(message)
    }
}
