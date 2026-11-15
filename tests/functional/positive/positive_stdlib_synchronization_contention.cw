/*
 * tests/functional/positive/positive_stdlib_synchronization_contention.cw
 *
 * Checks stdlib synchronization contention.
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
 * Counter is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class Counter {
    public:
    Sync.Mutex mutex
    int64 value

    /*
     * Constructs a Counter and stores mutex, value.
     *
     * Takes no parameters.
     *
     * Returns the constructed Counter.
     */
    Counter() {
        mutex = Sync.Mutex()
        value = 0
    }
}

/*
 * CounterWorker is a class derived from Thread, used as a fixture by this
 * test.
 *
 * Its methods include constructor, run.
 */
class CounterWorker : Thread {
    public:
    Counter counter

    /*
     * Constructs a CounterWorker and stores counter.
     *
     * Parameters:
     *   shared — Counter shared.
     *
     * Returns the constructed CounterWorker.
     */
    CounterWorker(Counter shared) {
        counter = shared
    }

    /*
     * Handles run for this CounterWorker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        int64 index = 0
        while (index < 2000) {
            counter.mutex.lock()
            int64 current = counter.value
            counter.value = current + 1
            counter.mutex.unlock()
            index = index + 1
        }
    }
}

/*
 * PingPong is a class, used as a fixture by this test.
 *
 * Its methods include constructor.
 */
class PingPong {
    public:
    Sync.Mutex mutex
    Sync.Condition turnChanged
    int64 turn
    int64 exchanges

    /*
     * Constructs a PingPong and stores mutex, turnChanged, turn, exchanges.
     *
     * Takes no parameters.
     *
     * Returns the constructed PingPong.
     */
    PingPong() {
        mutex = Sync.Mutex()
        turnChanged = Sync.Condition()
        turn = 0
        exchanges = 0
    }
}

/*
 * PingPongWorker is a class derived from Thread, used as a fixture by this
 * test.
 *
 * Its methods include constructor, run.
 */
class PingPongWorker : Thread {
    public:
    PingPong shared
    int64 mine
    int64 theirs

    /*
     * Constructs a PingPongWorker and stores shared, mine, theirs.
     *
     * Parameters:
     *   state — PingPong state.
     *   myTurn — int64 my turn.
     *   otherTurn — int64 other turn.
     *
     * Returns the constructed PingPongWorker.
     */
    PingPongWorker(PingPong state, int64 myTurn, int64 otherTurn) {
        shared = state
        mine = myTurn
        theirs = otherTurn
    }

    /*
     * Handles run for this PingPongWorker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {

        int64 round = 0
        while (round < 100) {
            shared.mutex.lock()
            while (shared.turn != mine) {
                shared.turnChanged.wait(shared.mutex)
            }
            shared.exchanges = shared.exchanges + 1
            shared.turn = theirs
            shared.turnChanged.broadcast()
            shared.mutex.unlock()
            round = round + 1
        }

    }
}

/*
 * HoldWorker is a class derived from Thread, used as a fixture by this test.
 *
 * Its methods include constructor, run.
 */
class HoldWorker : Thread {
    public:
    Sync.Mutex mutex
    Sync.Semaphore holding
    Sync.Semaphore proceed

    /*
     * Constructs a HoldWorker and stores mutex, holding, proceed.
     *
     * Parameters:
     *   shared — Sync.Mutex shared.
     *   held — Sync.Semaphore held.
     *   go — Sync.Semaphore input value.
     *
     * Returns the constructed HoldWorker.
     */
    HoldWorker(Sync.Mutex shared, Sync.Semaphore held, Sync.Semaphore go) {
        mutex = shared
        holding = held
        proceed = go
    }

    /*
     * Handles run for this HoldWorker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        mutex.lock()
        holding.signal()
        proceed.wait()
        mutex.unlock()
    }
}

start {
    Counter counter = Counter()
    CounterWorker first = CounterWorker(counter)
    CounterWorker second = CounterWorker(counter)
    handle firstThread = first.launch()
    handle secondThread = second.launch()
    first.join(firstThread)
    second.join(secondThread)
    print(counter.value)
    print(counter.mutex.close())

    PingPong game = PingPong()
    PingPongWorker ping = PingPongWorker(game, 0, 1)
    PingPongWorker pong = PingPongWorker(game, 1, 0)
    handle pingThread = ping.launch()
    handle pongThread = pong.launch()
    ping.join(pingThread)
    pong.join(pongThread)
    print(game.exchanges)
    print(game.turn)
    print(game.turnChanged.close())
    print(game.mutex.close())

    Sync.Mutex shared = Sync.Mutex()
    Sync.Semaphore held = Sync.Semaphore(0)
    Sync.Semaphore go = Sync.Semaphore(0)
    HoldWorker holder = HoldWorker(shared, held, go)
    handle holderThread = holder.launch()
    held.wait()
    print(shared.unlock())
    print(shared.close())
    go.signal()
    shared.lock()
    print(shared.lock())
    print(shared.unlock())
    print(shared.unlock())
    holder.join(holderThread)
    print(shared.close())
    held.close()
    go.close()
}
