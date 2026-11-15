/*
 * tests/functional/positive/positive_array_resize.cw — Checks array resize.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
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
 * Grower is a class, used as a fixture by this test.
 *
 * Its methods include grow.
 */
class Grower {
    public:
    /*
     * Handles grow for this Grower.
     *
     * Parameters:
     *   values — list values.
     *
     * Returns int64.
     */
    int64 grow(list values) {
        values.resize(12)
        return(7)
    }
}

start {
    list values = [1, "two"]
    list alias = values
    values.append([3])
    print(alias.length)
    list nested = alias[2]
    print(nested[0])
    alias.resize(5)
    print(values.length)
    print(values[4])
    values[4] = 42
    alias.resize(1)
    print(values.length)
    values.resize(5)
    print(values[4])
    values.append("last")
    print(alias[5])
    list copy = values[0:2]
    alias.resize(1)
    print(copy.length)
    print(values.length)
    Grower grower = Grower()
    values[0] = grower.grow(values)
    print(values.length)
    print(values[0])
    try {
        values.resize(-1)
    }
    except() as error {
        print(error)
    }
    list refs = []
    refs.append(Node(55))
    int64 churn = 0
    while (churn < 20) {
        Node unused = Node(churn)
        churn = churn + 1
    }
    Node retained = refs[0]
    print(retained.read())
}
