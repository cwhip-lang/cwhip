/*
 * tests/functional/positive/positive_stdlib_async_process.cw
 *
 * Checks stdlib async process.
 *
 * Created: 2026-10-06
 * Author: chuck
 *
 * Changelog:
 *   2026-10-06  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import process as P
import system as Sys
import time as T

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
 * Collector is a class, used as a fixture by this test.
 *
 * Drains every event until the single completion event, keeping bytes
 * lossless.
 */
class Collector {
    public:
    buffer out
    buffer err
    String outText
    String errText
    int64 completions
    int64 events
    P.OutputDecoder outDecoder
    P.OutputDecoder errDecoder

    /*
     * Constructs a Collector and stores outDecoder, errDecoder, out, err.
     *
     * Takes no parameters.
     *
     * Returns the constructed Collector.
     */
    Collector() {
        outDecoder = P.OutputDecoder()
        errDecoder = P.OutputDecoder()
        out = buffer[]
        err = buffer[]
        outText = ""
        errText = ""
        completions = 0
        events = 0
    }

    /*
     * Adds the Collector state.
     *
     * Parameters:
     *   target — buffer target.
     *   chunk — buffer chunk.
     *
     * Does not return a value.
     */
    void add(buffer target, buffer chunk) {
        int64 index = 0
        while (index < chunk.length) {
            target.append(chunk[index])
            index = index + 1
        }
    }

    /*
     * Handles drain for this Collector.
     *
     * Parameters:
     *   child — P.AsyncProcess child.
     *
     * Does not return a value.
     */
    void drain(P.AsyncProcess child) {

        bool done = false
        while (!done) {

            P.ProcessEvent event = child.next(10000)
            if (event == null) {
                print("unexpected timeout")
                done = true
            }
            else {
                events = events + 1
                if (event.isStdout()) {
                    add(out, event.data())
                    outText.append(outDecoder.decode(event.data()))
                }
                if (event.isStderr()) {
                    add(err, event.data())
                    errText.append(errDecoder.decode(event.data()))
                }
                if (event.isCompleted()) {
                    completions = completions + 1
                    outText.append(outDecoder.finish())
                    errText.append(errDecoder.finish())
                    done = true
                }
            }

        }

    }
}

/*
 * Counter is a class, used as a fixture by this test.
 *
 * Counts byte totals only, for output much larger than a pipe's capacity.
 */
class Counter {
    public:
    int64 outBytes
    int64 errBytes
    int64 outChunks

    /*
     * Handles drain for this Counter.
     *
     * Parameters:
     *   child — P.AsyncProcess child.
     *
     * Does not return a value.
     */
    void drain(P.AsyncProcess child) {
        outBytes = 0
        errBytes = 0
        outChunks = 0

        bool done = false
        while (!done) {

            P.ProcessEvent event = child.next(10000)
            if (event == null) {
                done = true
            }
            else {
                if (event.isStdout()) {
                    outBytes = outBytes + event.data().length
                    outChunks = outChunks + 1
                }
                if (event.isStderr()) {
                    errBytes = errBytes + event.data().length
                }
                if (event.isCompleted()) {
                    done = true
                }
            }

        }

    }
}

/*
 * Ticker is a class derived from Thread, used as a fixture by this test.
 *
 * Its methods include constructor, run.
 */
class Ticker : Thread {
    public:
    int64 ticks
    bool stop

    /*
     * Constructs a Ticker and stores ticks, stop.
     *
     * Takes no parameters.
     *
     * Returns the constructed Ticker.
     */
    Ticker() {
        ticks = 0
        stop = false
    }

    /*
     * Handles run for this Ticker.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        while (!stop) {
            ticks = ticks + 1
            T.Clock().sleepMilliseconds(5u)
        }
    }
}

/*
 * BlockedReader is a class derived from Thread, used as a fixture by this
 * test.
 *
 * Its methods include constructor, run.
 */
class BlockedReader : Thread {
    public:
    P.AsyncProcess child
    bool returned
    bool useWait

    /*
     * Constructs a BlockedReader and stores child, returned, useWait.
     *
     * Parameters:
     *   target — P.AsyncProcess target.
     *   waitInstead — bool wait instead.
     *
     * Returns the constructed BlockedReader.
     */
    BlockedReader(P.AsyncProcess target, bool waitInstead) {
        child = target
        returned = false
        useWait = waitInstead
    }

    /*
     * Handles run for this BlockedReader.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        if (useWait) {
            child.wait(-1)
        }
        else {
            child.next(-1)
            child.next(-1)
        }
        returned = true
    }
}

/*
 * Closer is a class derived from Thread, used as a fixture by this test.
 *
 * Its methods include constructor, run.
 */
class Closer : Thread {
    public:
    P.AsyncProcess child

    /*
     * Constructs a Closer and stores child.
     *
     * Parameters:
     *   target — P.AsyncProcess target.
     *
     * Returns the constructed Closer.
     */
    Closer(P.AsyncProcess target) {
        child = target
    }

    /*
     * Handles run for this Closer.
     *
     * Takes no parameters.
     *
     * Does not return a value.
     */
    void run() {
        child.close()
    }
}

start {
    # argv is passed verbatim: spaces and shell metacharacters are not
    # interpreted.
    P.AsyncProcess quoted = P.AsyncProcess("/usr/bin/printf",
        ["[%s]", "a b", "$(echo x)", ";|&<>", "'q'", "*", ""])
    print(quoted.started())
    Collector quotedOutput = Collector()
    quotedOutput.drain(quoted)
    print(quotedOutput.outText.equals("[a b][$(echo x)][;|&<>]['q'][*][]"))
    print(quotedOutput.errText.length == 0)
    print(quotedOutput.completions == 1)
    print(quoted.state() == P.AsyncProcess.EXITED)
    print(quoted.exitCode() == 0)
    print(quoted.signal() == 0)
    print(quoted.error().length == 0)
    print(quoted.next(0) == null)
    print(quoted.next(50) == null)
    print(quoted.finished())
    quoted.close()
    quoted.close()
    print(quoted.state() == P.AsyncProcess.EXITED)

    # Interleaved writes stay separated and ordered within each stream.
    P.AsyncProcess mixed = P.AsyncProcess("/bin/sh", ["-c",
        "i=0; while [ $i -lt 40 ]; do printf \"o$i,\"; printf \"e$i,\" >&2; i=$((i+1)); done; exit 4"])
    Collector mixedOutput = Collector()
    mixedOutput.drain(mixed)
    String expectedOut = ""
    String expectedErr = ""
    int64 index = 0
    while (index < 40) {
        expectedOut.append(format("o{},", index))
        expectedErr.append(format("e{},", index))
        index = index + 1
    }
    print(mixedOutput.outText.equals(expectedOut))
    print(mixedOutput.errText.equals(expectedErr))
    print(mixed.state() == P.AsyncProcess.EXITED)
    print(mixed.exitCode() == 4)
    mixed.close()

    # Both streams far exceed pipe capacity; neither may deadlock the child.
    P.AsyncProcess large = P.AsyncProcess("/bin/sh", ["-c",
        "head -c 1500000 /dev/zero; head -c 900000 /dev/zero >&2; head -c 300000 /dev/zero"])
    Counter largeOutput = Counter()
    largeOutput.drain(large)
    print(largeOutput.outBytes == 1800000)
    print(largeOutput.errBytes == 900000)
    print(largeOutput.outChunks > 1)
    print(large.exitCode() == 0)
    large.close()

    # Binary output is delivered byte-for-byte, including NUL and non-UTF-8
    # bytes.
    P.AsyncProcess binary = P.AsyncProcess("/usr/bin/printf", ["\\000\\377\\200A\\n"])
    Collector binaryOutput = Collector()
    binaryOutput.drain(binary)
    print(binaryOutput.out.length == 5)
    print(binaryOutput.out[0] == 0u)
    print(binaryOutput.out[1] == 255u)
    print(binaryOutput.out[2] == 128u)
    print(binaryOutput.out[3] == 65u)
    print(binaryOutput.outText.length == 9)
    print(binaryOutput.outText[0] == 0u)
    print(binaryOutput.outText.endsWith("��A\n"))
    binary.close()

    # Incremental decoding keeps characters split across chunk boundaries.
    P.OutputDecoder decoder = P.OutputDecoder()
    String joined = decoder.decode(buffer[104, 0xC3])
    print(decoder.pending() == 1)
    joined.append(decoder.decode(buffer[0xA9, 0xE2, 0x82]))
    print(decoder.pending() == 2)
    joined.append(decoder.decode(buffer[0xAC, 0xF0]))
    joined.append(decoder.finish())
    print(joined.equals("hé€�"))
    print(decoder.pending() == 0)
    print(decoder.decode(buffer[0xED, 0xA0, 0x80, 0xFF]).equals("����"))
    print(decoder.decode(null).length == 0)

    # Signalled completion.
    P.AsyncProcess signalled = P.AsyncProcess("/bin/sh", ["-c", "kill -9 $$"])
    print(signalled.wait(10000))
    print(signalled.state() == P.AsyncProcess.SIGNALED)
    print(signalled.signal() == 9)
    print(signalled.exitCode() == -1)
    signalled.close()

    # Missing executable: an explicit launch failure, still completed once.
    P.AsyncProcess missing = P.AsyncProcess("/definitely/not/a/cwhip-command", ["x"])
    print(missing.started() == false)
    print(Sys.System().lastError().length > 0)
    print(missing.state() == P.AsyncProcess.LAUNCH_FAILED)
    print(missing.error().startsWith(
            "cannot start '/definitely/not/a/cwhip-command'"))
    print(missing.finished())
    P.ProcessEvent failedEvent = missing.next(-1)
    print(failedEvent.isCompleted())
    print(failedEvent.data() == null)
    print(missing.next(-1) == null)
    print(missing.cancel(0) == false)
    missing.close()
    missing.close()
    print(missing.state() == P.AsyncProcess.LAUNCH_FAILED)

    # Working directory support and a rejected directory.
    P.AsyncProcess located = P.AsyncProcess("/bin/pwd", [], "/")
    Collector locatedOutput = Collector()
    locatedOutput.drain(located)
    print(locatedOutput.outText.equals("/\n"))
    located.close()
    P.AsyncProcess badDirectory = P.AsyncProcess("/bin/pwd", [], "/definitely/not/a/cwhip-directory")
    print(badDirectory.state() == P.AsyncProcess.LAUNCH_FAILED)
    print(badDirectory.error().startsWith("cannot use working directory"))
    badDirectory.close()

    # Standard input is /dev/null, so a reader sees EOF instead of hanging.
    P.AsyncProcess reader = P.AsyncProcess("/bin/cat", [])
    print(reader.wait(10000))
    print(reader.exitCode() == 0)
    reader.close()

    # wait() never discards buffered output.
    P.AsyncProcess buffered = P.AsyncProcess("/usr/bin/printf", ["kept"])
    print(buffered.wait(-1))
    Collector bufferedOutput = Collector()
    bufferedOutput.drain(buffered)
    print(bufferedOutput.outText.equals("kept"))
    buffered.close()

    # Graceful cancellation with SIGTERM.
    P.AsyncProcess sleeper = P.AsyncProcess("/bin/sleep", ["30"])
    print(sleeper.wait(100) == false)
    print(sleeper.state() == P.AsyncProcess.RUNNING)
    print(sleeper.cancel(5000))
    print(sleeper.wait(10000))
    print(sleeper.state() == P.AsyncProcess.CANCELLED)
    print(sleeper.signal() == 15)
    print(sleeper.cancel(0) == false)
    sleeper.close()

    # A child ignoring SIGTERM is killed after the grace period.
    uint64 before = T.Clock().monotonicMilliseconds()
    P.AsyncProcess stubborn = P.AsyncProcess("/bin/sh", ["-c",
        "trap '' TERM; echo ready; sleep 30"])
    P.ProcessEvent ready = stubborn.next(10000)
    print(ready.isStdout())
    print(stubborn.cancel(300))
    print(stubborn.wait(10000))
    uint64 elapsed = T.Clock().monotonicMilliseconds() - before
    print(stubborn.state() == P.AsyncProcess.CANCELLED)
    print(stubborn.signal() == 9)
    print(elapsed >= 300u)
    print(stubborn.cancel(-1) == false)
    stubborn.close()

    # A descendant holding the output pipe delays completion until cancel.
    P.AsyncProcess orphaning = P.AsyncProcess("/bin/sh", ["-c", "sleep 1 & echo started"])
    print(orphaning.wait(300) == false)
    print(orphaning.cancel(0))
    print(orphaning.wait(10000))
    print(orphaning.state() == P.AsyncProcess.EXITED)
    print(orphaning.exitCode() == 0)
    orphaning.close()

    # Close kills a running child; all later operations are safe.
    P.AsyncProcess abandoned = P.AsyncProcess("/bin/sleep", ["30"])
    abandoned.close()
    print(abandoned.state() == P.AsyncProcess.CANCELLED)
    print(abandoned.signal() == 9)
    print(abandoned.next(-1) == null)
    print(abandoned.wait(-1))
    print(abandoned.cancel(0) == false)
    abandoned.close()

    # Other Cwhip threads progress while this thread blocks in next/wait.
    Ticker ticker = Ticker()
    handle tickerThread = ticker.launch()
    P.AsyncProcess slow = P.AsyncProcess("/bin/sh", ["-c", "sleep 0.3; printf done"])
    Collector slowOutput = Collector()
    slowOutput.drain(slow)
    int64 afterNext = ticker.ticks
    P.AsyncProcess slower = P.AsyncProcess("/bin/sleep", ["0.3"])
    slower.wait(-1)
    ticker.stop = true
    ticker.join(tickerThread)
    print(slowOutput.outText.equals("done"))
    print(afterNext > 5)
    print(ticker.ticks > afterNext + 5)
    slow.close()
    slower.close()

    # Closing while other threads are blocked in next() and wait() wakes them.
    P.AsyncProcess contended = P.AsyncProcess("/bin/sleep", ["30"])
    BlockedReader nextReader = BlockedReader(contended, false)
    BlockedReader waitReader = BlockedReader(contended, true)
    handle nextThread = nextReader.launch()
    handle waitThread = waitReader.launch()
    T.Clock().sleepMilliseconds(100u)
    Closer otherCloser = Closer(contended)
    handle closerThread = otherCloser.launch()
    contended.close()
    otherCloser.join(closerThread)
    nextReader.join(nextThread)
    waitReader.join(waitThread)
    print(nextReader.returned)
    print(waitReader.returned)
    print(contended.state() == P.AsyncProcess.CANCELLED)

    # The existing synchronous API is unchanged.
    P.Process legacy = P.Process("/usr/bin/printf", ["legacy"])
    print(legacy.wait())
    print(legacy.stdout().equals("legacy"))
    legacy.close()
}
