# Covers heterogeneous maps, aliases, string keys, nested collections, typed extraction, and retained references.
class Node {
    public:
    int64 value
    Node(int64 initial) {
        value = initial
    }
    int64 read() {
        return(value)
    }
}

class Catalog {
    public:
    dict content
    Catalog(dict initial) {
        content = initial
    }
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
    } except() as error {
        print(error)
    }
}
