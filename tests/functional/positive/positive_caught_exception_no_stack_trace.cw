/*
 * tests/functional/positive/positive_caught_exception_no_stack_trace.cw
 *
 * A caught exception must not print an uncaught stack trace.
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
     * valid (caught sentinel).
     *
     * Parameters:
     *   self — Worker self.
     *
     * Does not return a value.
     */
    void inner(Worker self) {
        raise(Exception("caught sentinel"))
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
    try {
        worker.outer(worker)
    }
    except() {
        print("caught")
    }
}
