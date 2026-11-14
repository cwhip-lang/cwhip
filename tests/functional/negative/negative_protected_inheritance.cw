# Rejects exposing a protected base field through an external qualified access.
class Base {
    public:
    int64 value
}

class ProtectedChild : protected Base {
}

start {
    ProtectedChild child = ProtectedChild()
    print(child.Base.value)
}
