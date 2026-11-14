# Keeps a linked object graph and nested object reference alive while allocation triggers collection.
class Node {
    public:
    int64 value
    Node next

    Node(int64 initial) {
        value = initial
    }

    void setNext(Node child) {
        next = child
    }
}

class Pair {
    public:
    Node child

    Pair(Node value) {
        child = value
    }
}

start {
    Node head = Node(0)
    Node tail = head
    int64 index = 1
    while (index <= 64) {
        tail.setNext(Node(index))
        tail = tail.next
        index = index + 1
    }
    print(head.next.value)
    print(tail.value)

    Pair pair = Pair(Node(77))
    print(pair.child.value)
}
