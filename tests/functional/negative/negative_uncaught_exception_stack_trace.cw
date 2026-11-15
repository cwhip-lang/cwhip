/*
 * tests/functional/negative/negative_uncaught_exception_stack_trace.cw
 *
 * Uncaught explicit exceptions retain Cwhip method frames from innermost to
 * start.
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
 * Its methods include inner, outer.
 */
class Worker {
    public:
    /*
     * Handles inner for this Worker. Raises Exception when the call is not
     * valid (trace sentinel).
     *
     * Parameters:
     *   self — Worker self.
     *
     * Does not return a value.
     */
    void inner(Worker self) {
        raise(Exception("trace sentinel"))
    }

    /*
     * Handles outer for this Worker.
     *
     * Parameters:
     *   self — Worker self.
     *
     * Does not return a value.
     */
    void outer(Worker self) {
        self.inner(self)
    }
}
start {
    Worker worker = Worker()
    print("begin")
    worker.outer(worker)
}
