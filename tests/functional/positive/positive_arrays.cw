# Exercises heterogeneous list values, mutation, slicing, list aliases, typed extraction, retained references, and bounds exceptions.
class Node {
    public:
    int64 value
    Node(int64 initial) {
        value = initial
    }
}

class Holder {
    public:
    list nodes
    Holder(list initial) {
        nodes = initial
    }
    list copyNodes(list source) {
        return(source[0:2])
    }
}

start {
    // Arrays (and their 'list' keyword alias) are heterogeneous bags: one
    // literal can freely mix ints, strings, and class references.
    list items = [int64(10), "twenty", int64(30), "forty"]
    print(items.length)
    print(items[1])
    items[1] = "twenty-five"
    print(items[1])
    items[1] = 25
    print(items[1])

    list middle = items[1:3]
    print(middle.length)
    print(middle[0])
    middle[0] = 99
    print(items[1])
    print(middle[0])
    list empty = items[2:2]
    print(empty.length)
    list emptyLiteral = []
    print(emptyLiteral.length)
    list alias = items
    alias[0] = int64(11)
    print(items[0])

    list words = ["one", "two"]
    print(words[1])

    list nodes = [Node(7), Node(8)]
    Holder holder = Holder(nodes)
    list copiedNodes = holder.copyNodes(holder.nodes)
    nodes = []
    int64 counter = 0
    while (counter < 40) {
        Node discarded = Node(counter)
        counter = counter + 1
    }
    // holder.nodes[0] is 'any'; extract it into a Node-typed variable before
    // accessing its fields (dynamic values have no members of their own).
    Node firstNode = holder.nodes[0]
    Node secondNode = holder.nodes[1]
    Node firstCopied = copiedNodes[0]
    print(firstNode.value)
    print(secondNode.value)
    print(firstCopied.value)

    // Reading an element directly into a concrete type is a runtime-checked,
    // type-safe extraction.
    int64 extracted = items[0]
    print(extracted)

    list mixed = [1, "two", Node(3), null]
    print(mixed[0])
    print(mixed[1])
    print(mixed[2])
    print(mixed[3])

    try {
        print(items[-5])
    } except() as error {
        print(error)
    }
    list invalid = items[3:2]
    print(invalid.length)
}
