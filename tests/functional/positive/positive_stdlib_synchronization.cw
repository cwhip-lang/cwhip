/*
 * tests/functional/positive/positive_stdlib_synchronization.cw
 *
 * Checks stdlib synchronization.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import synchronization as Sync

/*
 * Thread is a class, used as a fixture by this test.
 *
 * Its methods include launch, join.
 */
class Thread {
    public:
    /*
     * Handles launch for this Thread by calling the native function
     * cwhip_thread_start.
     *
     * Takes no parameters.
     *
     * Returns handle.
     */
    handle launch()

    /*
     * Handles join for this Thread by calling the native function
     * cwhip_thread_join.
     *
     * Parameters:
     *   worker — handle worker.
     *
     * Does not return a value.
     */
    void join(handle worker)
}

handle Thread.launch() from "cwhip_thread_start"
void Thread.join(handle worker) from "cwhip_thread_join"

/*
 * SharedState is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class SharedState {
    public:
    Sync.Mutex mutex
    Sync.Condition condition
    bool ready

    /*
     * Constructs a SharedState and stores mutex, condition, ready.
     *
     * Takes no parameters.
     *
     * Returns the constructed SharedState.
     */
    SharedState() {
        mutex = Sync.Mutex()
        condition = Sync.Condition()
        ready = false
    }
}

/*
 * SignalWorker is a class derived from Thread, used as a fixture by this test.
 *
 * Its methods include constructor, run.
 */
class SignalWorker : Thread {
    public:
    SharedState shared

    /*
     * Constructs a SignalWorker and stores shared.
     *
     * Parameters:
     *   state — SharedState state.
     *
     * Returns the constructed SignalWorker.
     */
    SignalWorker(SharedState state) {
        shared = state
    }

    /*
     * Handles run for this SignalWorker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        shared.mutex.lock()
        shared.ready = true
        shared.condition.signal()
        shared.mutex.unlock()
    }
}

start {
    SharedState shared = SharedState()
    SignalWorker worker = SignalWorker(shared)
    handle thread = worker.launch()

    shared.mutex.lock()
    while (shared.ready == false) {
        shared.condition.wait(shared.mutex)
    }
    shared.mutex.unlock()
    worker.join(thread)
    print(shared.ready)

    Sync.Semaphore semaphore = Sync.Semaphore(0)
    semaphore.signal()
    semaphore.wait()
    print(true)
    semaphore.close()
    print(shared.condition.close())
    print(shared.mutex.close())
}
