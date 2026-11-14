# Exercises public base access and confirms protected/private base members remain usable inside derived classes.
class Base {
    public:
    int64 value
}

class PublicChild : public Base {
}

class ProtectedChild : protected Base {
    public:
    int64 readValue() {
        return(value)
    }
}

class PrivateChild : private Base {
    public:
    int64 readValue() {
        return(value)
    }
}

class ProtectedGrandchild : public ProtectedChild {
    public:
    int64 readAgain() {
        return(value)
    }
}

start {
    PublicChild child = PublicChild()
    child.value = 42
    print(child.value)

    ProtectedChild protectedChild = ProtectedChild()
    print(protectedChild.readValue())

    PrivateChild privateChild = PrivateChild()
    print(privateChild.readValue())

    ProtectedGrandchild protectedGrandchild = ProtectedGrandchild()
    print(protectedGrandchild.readAgain())

}
