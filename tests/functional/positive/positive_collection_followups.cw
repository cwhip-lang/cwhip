# Covers ordered dict slices and removal, mutation during iteration, list iteration, and nested collection references.
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
