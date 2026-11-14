import system as sys

class Box {
    public:
    String value

    Box(String text) { value = text }
    Box(int64 number) { value = "int" }
    Box(bool flag) { value = "bool" }

    String label() { return(value)}
    void set(String text) { value = text }
    void set(int64 number) { value = "int" }

    Box rebuild() { return(Box(sys.FileSystem().basename("/m/method.txt")))}
}

class Pair {
    public:
    Box inner

    Pair(Box box) { inner = box }
}

class Derived : Box {
    public:
    Derived() { super Box(sys.FileSystem().basename("/d/derived.txt")) }
}

class AliasError : Exception {
    public:
    AliasError() { super Exception(sys.FileSystem().basename("/e/base.txt")) }
}

start {
    bool opened = false
    try {
        sys.File missing("/definitely/not/a/cwhip/dir/file.txt", "r")
        opened = missing.isOpen()
    } except(Exception) {
        opened = false
    }
    print(opened)

    try {
        raise(Exception(sys.System().lastError()))
    } except() as message {
        print(message.length > 0)
    }

    Exception direct = Exception(sys.FileSystem().basename("/x/direct.txt"))
    print(direct.message)

    Box box = Box(sys.FileSystem().basename("/b/box.txt"))
    print(box.label())

    Box declared(sys.FileSystem().extension("/b/declared.cw"))
    print(declared.label())

    Pair pair = Pair(Box(sys.FileSystem().basename("/p/nested.txt")))
    print(pair.inner.label())

    box.set(sys.FileSystem().basename("/s/overload.txt"))
    print(box.label())

    print(box.rebuild().label())
    print(Derived().label())
    print(AliasError().message)

    list files = [sys.FileSystem()]
    Box typed = Box(files[0] is sys.FileSystem)
    print(typed.label())
}
