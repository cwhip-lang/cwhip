/*
 * tests/benchmarks/gc_throughput.cw
 *
 * Allocation-heavy GC benchmark. Compile with bin/cwhip -o bench
 * gc_throughput.cw.
 *
 * Created: 2026-10-13
 * Author: chuck
 *
 * Changelog:
 *   2026-10-13  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Tree is a class, used as a fixture by this test.
 *
 * Its methods include constructor, count.
 */
class Tree {
    public:
    Tree left
    Tree right

    /*
     * Constructs a Tree and stores left, right.
     *
     * Parameters:
     *   depth — int64 depth.
     *
     * Returns the constructed Tree.
     */
    Tree(int64 depth) {
        if (depth > 0) {
            left = Tree(depth - 1)
            right = Tree(depth - 1)
        }
    }

    /*
     * Handles count for this Tree.
     *
     * Takes no parameters.
     *
     * Returns int64.
     */
    int64 count() {
        if (left == null) {
            return(1)
        }
        return(1 + left.count() + right.count())
    }
}

start {

    int64 total = 0
    int64 round = 0
    while (round < 40) {
        Tree tree = Tree(12 + round % 5)
        total = total + tree.count()
        strg text = ""
        list values = []
        int64 index = 0
        while (index < 2000) {
            text.append(format("{}", index))
            values.append(index)
            index = index + 1
        }
        round = round + 1
    }

    print(total)
}
