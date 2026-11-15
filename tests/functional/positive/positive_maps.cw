/*
 * tests/functional/positive/positive_maps.cw
 *
 * Covers heterogeneous maps, aliases, string keys, nested collections, typed
 * extraction, and retained references.
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

/*
 * Catalog is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Catalog {
    public:
    dict content

    /*
     * Constructs a Catalog and stores content.
     *
     * Parameters:
     *   initial — dict initial.
     *
     * Returns the constructed Catalog.
     */
    Catalog(dict initial) {
        content = initial
    }

    /*
     * Returns the stored content.
     *
     * Takes no parameters.
     *
     * Returns dict.
     */
    dict read() {
        return(content)
    }
}

start {
    dict table = ["number": int64(7), "text": "seven", "node": Node(64), "items": [Node(77)], "child": ["value": 9, "node": Node(88)]]
    Catalog catalog = Catalog(table)
    print(table.length)
    print(table["number"])
    int64 number = table["number"]
    strg text = table["text"]
    print(number)
    print(text)

    dict alias = table
    alias["number"] = int64(11)
    print(table["number"])
    dict repeated = ["same": 1, "same": 2]
    print(repeated.length)
    print(repeated["same"])
    dict keySemantics = ["Key": 1, "key": 2, "café": 3]
    print(keySemantics.length)
    print(keySemantics["Key"])
    print(keySemantics["key"])
    print(keySemantics["café"])

    list holder = [table]
    dict fieldMap = catalog.read()
    dict recovered = holder[0]
    dict recoveredAgain = recovered
    Node scratch = Node(0)
    int64 count = 0
    while (count < 8) {
        scratch = Node(count)
        count = count + 1
    }
    Node retainedNode = recoveredAgain["node"]
    print(retainedNode.read())
    dict retainedChild = recoveredAgain["child"]
    print(retainedChild["value"])
    Node retainedChildNode = retainedChild["node"]
    print(retainedChildNode.read())
    list retainedItems = recoveredAgain["items"]
    Node retained = retainedItems[0]
    print(retained.read())

    try {
        dict absent = table["absent"]
    }
    except() as error {
        print(error)
    }
}
