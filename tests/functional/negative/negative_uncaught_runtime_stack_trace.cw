/*
 * tests/functional/negative/negative_uncaught_runtime_stack_trace.cw
 *
 * Runtime failures in nested methods report the active Cwhip call frames.
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
 * Its methods include inner, middle, outer.
 */
class Worker {
    public:
    /*
     * Returns 8 / 0.
     *
     * Parameters:
     *   self — Worker self.
     *
     * Returns int64.
     */
    int64 inner(Worker self) {
        return(8 / 0)
    }

    /*
     * Returns self.inner(self).
     *
     * Parameters:
     *   self — Worker self.
     *
     * Returns int64.
     */
    int64 middle(Worker self) {
        return(self.inner(self))
    }

    /*
     * Returns self.middle(self).
     *
     * Parameters:
     *   self — Worker self.
     *
     * Returns int64.
     */
    int64 outer(Worker self) {
        return(self.middle(self))
    }
}
start {
    Worker worker = Worker()
    print("begin")
    print(worker.outer(worker))
}
