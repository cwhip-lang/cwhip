/*
 * tests/functional/positive/positive_multiple_inheritance.cw
 *
 * Exercises independent base subobjects and qualified field access in a
 * non-virtual diamond.
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
 * Root is a class, used as a fixture by this test.
 *
 * Its methods include read.
 */
class Root {
    public:
    Node item
    int64 value

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
 * Left is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include sum.
 */
class Left : Root {
    public:
    int64 left

    /*
     * Returns value + left.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 sum() {
        return(value + left)
    }
}

/*
 * Right is a class derived from Root, used as a fixture by this test.
 *
 * Its methods include sumRight.
 */
class Right : Root {
    public:
    int64 right

    /*
     * Returns value + right.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 sumRight() {
        return(value + right)
    }
}

/*
 * Diamond is a class derived from Left, Right, used as a fixture by this test.
 *
 * Its methods include sum.
 */
class Diamond : Left, Right {
    public:
    int64 extra

    /*
     * Returns left + extra.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 sum() {
        return(left + extra)
    }
}

start {
    Diamond diamond = Diamond()
    diamond.Left.Root.item = Node(10)
    diamond.Right.Root.item = Node(20)
    diamond.Left.Root.value = 10
    diamond.Right.Root.value = 20
    diamond.Left.left = 2
    diamond.Right.right = 3
    diamond.extra = 5

    Left leftView = diamond
    print(leftView.sum())
    print(diamond.Left.sum())
    print(diamond.Left.Root.item.value)
    print(diamond.Right.Root.item.value)
    print(diamond.Right.right)
}
