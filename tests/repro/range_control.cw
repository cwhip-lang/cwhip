/*
 * tests/repro/range_control.cw
 *
 * Curated range snapshot, membership, and null-range failure cases.
 * Standalone: cwhip tests/repro/range_control.cw -o /tmp/range_control &&
 * /tmp/range_control Exhaustive width/edge coverage remains in
 * tests/test_range_execution.py.
 *
 * Created: 2026-10-30
 * Author: chuck
 *
 * Changelog:
 *   2026-10-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Worker is a class, used as a fixture by this test.
 *
 * Its methods include endpoint, identity, early.
 */
class Worker {
    public:
    range<int64> saved
    int64 calls

    /*
     * Handles endpoint for this Worker.
     *
     * Parameters:
     *   n — int64 input value.
     *
     * Returns int64.
     */
    int64 endpoint(int64 n) {
        calls += 1
        print(n)
        return(n)
    }

    /*
     * Returns r.
     *
     * Parameters:
     *   r — range<int64> input value.
     *
     * Returns range<int64>.
     */
    range<int64> identity(range<int64> r) {
        saved = r
        return(saved)
    }

    /*
     * Handles early for this Worker.
     *
     * Parameters:
     *   r — range<int64> input value.
     *
     * Returns int64.
     */
    int64 early(range<int64> r) {
        for (i in r) {
            try {
                return(i)
            }
            finally {
                print("return/")
            }
        }
        return(0)
    }
}
start {
    Worker w = Worker()
    int64 first = 1
    int64 last = 3
    range<int64> snapshot = w.identity(w.endpoint(first)..w.endpoint(last))
    print("/\n")
    first = 9
    last = 8
    range<int64> updated = first..last
    for (i in snapshot) {
        print(i)
    }
    print("/")
    for (i in updated) {
        print(i)
    }
    print("/{}\n", w.calls)
    print("{}\n", 2 in snapshot)
    print("{}\n", 8 in snapshot)
    print("{}\n", 8 in updated)
    print("{}\n", type(snapshot) == range<int64>)
    print("{}\n", w.early(snapshot))
    range<int64> nothing = null
    try {
        for (i in nothing) {
            print("BAD")
        }
    }
    except(Exception) {
        print("null-loop\n")
    }
    try {
        print(1 in nothing)
    }
    except(Exception) {
        print("null-membership\n")
    }
}
