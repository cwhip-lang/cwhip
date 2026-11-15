/*
 * tests/functional/positive/positive_collection_followups.cw
 *
 * Covers ordered dict slices and removal, mutation during iteration, list
 * iteration, and nested collection references.
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
    dict table = ["first": 1, "second": 2, "third": 3, "fourth": 4, "fifth": 5]
    dict middle = table[1:4]
    print(middle.length)
    middle["second"] = 20
    print(table["second"])
    print(middle["second"])

    print(table.remove("third"))
    print(table.remove("missing"))
    table["third"] = 30
    int64 seen = 0
    for (value in table) {
        print(value)
        if (seen == 0) {
            table.remove("second")
            table["new"] = 99
        }
        seen = seen + 1
    }
    print(seen)
    print(table.length)

    for (key, value in middle) {
        print(key)
    }

    list items = [10, 20, 30]
    seen = 0
    for (value in items) {
        print(value)
        if (seen == 0) {
            items[1] = 200
        }
        seen = seen + 1
    }
    print(items[1])

    list inner = [Node(77)]
    list nested = [inner, [1, 2]]
    dict graph = ["nested": nested]
    list recovered = graph["nested"]
    list recoveredInner = recovered[0]
    Node retained = recoveredInner[0]
    Node scratch = Node(0)
    int64 churn = 0
    while (churn < 8) {
        scratch = Node(churn)
        churn = churn + 1
    }
    print(retained.read())
}
