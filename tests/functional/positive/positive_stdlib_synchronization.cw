import synchronization as Sync

class Thread {
    public:
    handle launch()
    void join(handle worker)
}

handle Thread.launch() from "cwhip_thread_start"
void Thread.join(handle worker) from "cwhip_thread_join"

class SharedState {
    public:
    Sync.Mutex mutex
    Sync.Condition condition
    bool ready

    SharedState() {
        mutex = Sync.Mutex()
        condition = Sync.Condition()
        ready = false
    }
}

class SignalWorker : Thread {
    public:
    SharedState shared

    SignalWorker(SharedState state) {
        shared = state
    }

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
