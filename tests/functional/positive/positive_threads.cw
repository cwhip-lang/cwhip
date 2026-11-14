# Exercises the pthread-backed Thread/Semaphore runtime bindings: spawning
# OS threads that run a user-declared `run()` method (found by name in the
# object's own class metadata), joining them, and using a counting
# semaphore both as a simple event and as a mutex protecting a shared
# counter updated concurrently from two threads. All prints happen on the
# main thread only, after join()/wait() barriers, so output is
# deterministic regardless of OS thread scheduling.
class Thread {
    public:
    handle launch()
    void join(handle worker)
}

handle Thread.launch() from "cwhip_thread_start"
void Thread.join(handle worker) from "cwhip_thread_join"

class Semaphore {
    public:
    handle create(int64 initialCount)
    void wait(handle sem)
    void signal(handle sem)
    void release(handle sem)
}

handle Semaphore.create(int64 initialCount) from "cwhip_semaphore_create"
void Semaphore.wait(handle sem) from "cwhip_semaphore_wait"
void Semaphore.signal(handle sem) from "cwhip_semaphore_signal"
void Semaphore.release(handle sem) from "cwhip_semaphore_release"

class Counter {
    public:
    int64 value

    Counter(int64 initial) {
        value = initial
    }
}

class Doubler : Thread {
    public:
    int64 input
    int64 result

    Doubler(int64 value) {
        input = value
        result = 0
    }

    void run() {
        result = input * 2
    }
}

class Incrementer : Thread {
    public:
    Counter shared
    handle mutex
    handle done

    Incrementer(Counter target, handle lock, handle finished) {
        shared = target
        mutex = lock
        done = finished
    }

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
