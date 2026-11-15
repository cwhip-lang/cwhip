/*
 * tests/functional/negative/negative_raise_in_function.cw
 *
 * Rejects raise in function.
 *
 * Created: 2026-09-30
 * Author: chuck
 *
 * Changelog:
 *   2026-09-30  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

/*
 * Worker is a class, used as a fixture by this test.
 *
 * Its methods include fail.
 */
class Worker {
    public:
    /*
     * Handles fail for this Worker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void fail() {
        raise()
    }
}
start {
    Worker worker = Worker()
    try {
        raise(Exception("original"))
    }
    except() {
        worker.fail()
    }
}
