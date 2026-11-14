# Rejects method lookup when virtual and non-virtual ancestor subobjects are ambiguous.
class Ancestor {
    public:
    int64 read() {
        return(1)
    }
}

class VirtualPath : virtual Ancestor {
}

class OrdinaryPath : Ancestor {
}

class Diamond : VirtualPath, OrdinaryPath {
}

start {
    Diamond diamond = Diamond()
    print(diamond.read())
}
