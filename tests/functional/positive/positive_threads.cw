/*
 * tests/functional/positive/positive_threads.cw
 *
 * Exercises the pthread-backed Thread/Semaphore runtime bindings: spawning OS
 * threads that run a user-declared `run()` method (found by name in the
 * object's own class metadata), joining them, and using a counting semaphore
 * both as a simple event and as a mutex protecting a shared counter updated
 * concurrently from two threads. All prints happen on the main thread only,
 * after join()/wait() barriers, so output is deterministic regardless of OS
 * thread scheduling.
 *
 * Created: 2026-09-29
 * Author: chuck
 *
 * Changelog:
 *   2026-09-29  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

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
 * Semaphore is a class, used as a fixture by this test.
 *
 * Its methods include create, wait, signal, release.
 */
class Semaphore {
    public:
    /*
     * Creates the Semaphore state by calling the native function
     * cwhip_semaphore_create.
     *
     * Parameters:
     *   initialCount — int64 initial count.
     *
     * Returns handle.
     */
    handle create(int64 initialCount)

    /*
     * Handles wait for this Semaphore by calling the native function
     * cwhip_semaphore_wait.
     *
     * Parameters:
     *   sem — handle sem.
     *
     * Does not return a value.
     */
    void wait(handle sem)

    /*
     * Handles signal for this Semaphore by calling the native function
     * cwhip_semaphore_signal.
     *
     * Parameters:
     *   sem — handle sem.
     *
     * Does not return a value.
     */
    void signal(handle sem)

    /*
     * Handles release for this Semaphore by calling the native function
     * cwhip_semaphore_release.
     *
     * Parameters:
     *   sem — handle sem.
     *
     * Does not return a value.
     */
    void release(handle sem)
}

handle Semaphore.create(int64 initialCount) from "cwhip_semaphore_create"
void Semaphore.wait(handle sem) from "cwhip_semaphore_wait"
void Semaphore.signal(handle sem) from "cwhip_semaphore_signal"
void Semaphore.release(handle sem) from "cwhip_semaphore_release"

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Counter {
    public:
    int64 value

    /*
     * Constructs a Counter and stores value.
     *
     * Parameters:
     *   initial — int64 initial.
     *
     * Returns the constructed Counter.
     */
    Counter(int64 initial) {
        value = initial
    }
}

/*
 * Doubler is a class derived from Thread, used as a fixture by this test.
 *
 * Its methods include constructor, run.
 */
class Doubler : Thread {
    public:
    int64 input
    int64 result

    /*
     * Constructs a Doubler and stores input, result.
     *
     * Parameters:
     *   value — int64 value.
     *
     * Returns the constructed Doubler.
     */
    Doubler(int64 value) {
        input = value
        result = 0
    }

    /*
     * Stores input * 2 in result.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        result = input * 2
    }
}

/*
 * Incrementer is a class derived from Thread, used as a fixture by this test.
 *
 * Its methods include constructor, run.
 */
class Incrementer : Thread {
    public:
    Counter shared
    handle mutex
    handle done

    /*
     * Constructs a Incrementer and stores shared, mutex, done.
     *
     * Parameters:
     *   target — Counter target.
     *   lock — handle lock.
     *   finished — handle finished.
     *
     * Returns the constructed Incrementer.
     */
    Incrementer(Counter target, handle lock, handle finished) {
        shared = target
        mutex = lock
        done = finished
    }

    /*
     * Handles run for this Incrementer.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        Semaphore sem = Semaphore()
        int64 i = 0
        while (i < 400) {
            sem.wait(mutex)
            shared.value = shared.value + 1
            sem.signal(mutex)
            i = i + 1
        }
        sem.signal(done)
    }
}

start {
    Doubler d1 = Doubler(21)
    Doubler d2 = Doubler(4)
    handle t1 = d1.launch()
    handle t2 = d2.launch()
    d1.join(t1)
    d2.join(t2)
    print(d1.result)
    print(d2.result)

    Semaphore sem = Semaphore()
    handle mutex = sem.create(1)
    handle done = sem.create(0)
    Counter total = Counter(0)

    Incrementer a = Incrementer(total, mutex, done)
    Incrementer b = Incrementer(total, mutex, done)
    handle ta = a.launch()
    handle tb = b.launch()

    sem.wait(done)
    sem.wait(done)
    a.join(ta)
    b.join(tb)

    print(total.value)
}
