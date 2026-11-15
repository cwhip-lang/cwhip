/*
 * tests/functional/positive/positive_gc_object_graph.cw
 *
 * Keeps a linked object graph and nested object reference alive while
 * allocation triggers collection.
 *
 * Created: 2026-09-28
 * Author: chuck
 *
 * Changelog:
 *   2026-09-28  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Node is a class, used as a fixture by this test.
 *
 * Its methods include constructor, setNext.
 */
class Node {
    public:
    int64 value
    Node next

    /*
     * Constructs a Node and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Node.
     */
    Node(int64 initial) {
        value = initial
    }

    /*
     * Stores child in next.
     *
     * Parameters:
     *   child — Node child.
     *
     * Does not return a value.
     */
    void setNext(Node child) {
        next = child
    }
}

/*
 * Pair is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Pair {
    public:
    Node child

    /*
     * Constructs a Pair and stores child.
     *
     * Parameters:
     *   value — Node value.
     *
     * Returns the constructed Pair.
     */
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
