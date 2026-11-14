# Verifies inherited fields and overridden methods through a three-level class hierarchy.
class Node {
    public:
    int64 value

    Node(int64 initial) {
        value = initial
    }
}

class Base {
    public:
    Node item

    Base(Node initial) {
        item = initial
    }

    int64 read() {
        return(item.value)
    }
}

class Child : Base {
    public:
    int64 extra

    Child(Node initial, int64 amount) {
        super Base(initial)
        extra = amount
    }

    int64 combined() {
        return(item.value + extra)
    }

    int64 read() {
        return(item.value + extra)
    }
}

class Grandchild : Child {
    public:
    int64 last

    Grandchild(Node initial, int64 amount, int64 finalAmount) {
        super Child(initial, amount)
        last = finalAmount
    }

    int64 total() {
        return(item.value + extra + last)
    }

    int64 read() {
        return(item.value + extra + last)
    }
}

start {
    Grandchild child = Grandchild(Node(40), 2, 7)
    Base base = child
    Node unrelated = Node(5)
    print(base.read())
    print(child.read())
    print(child.total())
    print(child.item.value)
    print(unrelated.value)
}
