/*
 * tests/functional/positive/positive_single_inheritance.cw
 *
 * Verifies inherited fields and overridden methods through a three-level class
 * hierarchy.
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
 * Its methods include constructor.
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
}

/*
 * Base is a class, used as a fixture by this test.
 *
 * Its methods include constructor, read.
 */
class Base {
    public:
    Node item

    /*
     * Constructs a Base and stores item.
     *
     * Parameters:
     *   initial — Node initial.
     *
     * Returns the constructed Base.
     */
    Base(Node initial) {
        item = initial
    }

    /*
     * Returns item.value.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(item.value)
    }
}

/*
 * Child is a class derived from Base, used as a fixture by this test.
 *
 * Its methods include constructor, combined, read.
 */
class Child : Base {
    public:
    int64 extra

    /*
     * Constructs a Child and stores extra.
     *
     * Parameters:
     *   initial — Node initial.
     *   amount — int64 amount.
     *
     * Returns the constructed Child.
     */
    Child(Node initial, int64 amount) {
        super Base(initial)
        extra = amount
    }

    /*
     * Returns item.value + extra.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 combined() {
        return(item.value + extra)
    }

    /*
     * Returns item.value + extra.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 read() {
        return(item.value + extra)
    }
}

/*
 * Grandchild is a class derived from Child, used as a fixture by this test.
 *
 * Its methods include constructor, total, read.
 */
class Grandchild : Child {
    public:
    int64 last

    /*
     * Constructs a Grandchild and stores last.
     *
     * Parameters:
     *   initial — Node initial.
     *   amount — int64 amount.
     *   finalAmount — int64 final amount.
     *
     * Returns the constructed Grandchild.
     */
    Grandchild(Node initial, int64 amount, int64 finalAmount) {
        super Child(initial, amount)
        last = finalAmount
    }

    /*
     * Returns item.value + extra + last.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 total() {
        return(item.value + extra + last)
    }

    /*
     * Returns item.value + extra + last.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
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
