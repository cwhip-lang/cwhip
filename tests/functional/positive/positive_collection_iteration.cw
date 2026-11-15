/*
 * tests/functional/positive/positive_collection_iteration.cw
 *
 * Exercises dict lookup and membership, key/value iteration, list iteration,
 * and collection-held object references.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Node is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Node {
    public:
    int64 value

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
     * Returns the stored value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(value)
    }
}

start {
    strg selected = "dynamic"
    dict table = ["first": Node(10), selected: Node(20), "third": Node(30)]
    print(table.length)
    print(table.contains(selected))
    print(table.contains("absent"))
    table[selected] = Node(22)
    print(table.length)
    Node selectedValue = table[selected]
    print(selectedValue.read())

    int64 seen = 0
    for (key, value in table) {
        print(key)
        Node current = value
        print(current.read())
        table["added"] = Node(99)
        seen = seen + 1
    }
    print(seen)
    print(table.length)

    list mixed = [1, "two", Node(3), table]
    for (item in mixed) {
        print(item)
    }

    list references = [Node(42)]
    for (item in references) {
        Node retained = item
        Node churn = Node(100)
        print(retained.read())
        print(churn.read())
    }
}
