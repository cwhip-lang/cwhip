import process as P
import time as T

class Thread {
    public:
    handle launch()
    void join(handle worker)
}

handle Thread.launch() from "cwhip_thread_start"
void Thread.join(handle worker) from "cwhip_thread_join"

class Check {
    public:
    int64 failures

    Check() {
        failures = 0
    }

    void that(String label, bool ok) {
        if (ok) {
            print(true)
        } else {
            failures = failures + 1
            print(format("\nFAIL:{}\n", label))
        }
    }
}

# Pulls events until `expected` stdout bytes arrived or the child completed.
class Reader {
    public:
    String out
    String err
    int64 outBytes
    bool completed
    P.OutputDecoder decoder

    Reader() {
        out = ""
        err = ""
        outBytes = 0
        completed = false
        decoder = P.OutputDecoder()
    }

    void take(P.ProcessEvent event) {
        if (event.isStdout()) {
            outBytes = outBytes + event.data().length
            out.append(decoder.decode(event.data()))
        }
        if (event.isStderr()) {
            err.append(P.OutputDecoder().decode(event.data()))
        }
        if (event.isCompleted()) {
            completed = true
            out.append(decoder.finish())
        }
    }

    bool until(P.AsyncProcess child, String expected) {
        while (!completed && !out.contains(expected)) {
            P.ProcessEvent event = child.next(10000)
            if (event == null) {
                return(false)
            }
            take(event)
        }
        return(out.contains(expected))
    }

    bool drain(P.AsyncProcess child) {
        while (!completed) {
            P.ProcessEvent event = child.next(10000)
            if (event == null) {
                return(false)
            }
            take(event)
        }
        return(true)
    }

    # Polls without blocking, like a GTK idle/timeout handler would.
    void poll(P.AsyncProcess child) {
        P.ProcessEvent event = child.next(0)
        while (event != null) {
            take(event)
            event = child.next(0)
        }
    }
}

# Writes numbered lines from another Cwhip thread while the main thread reads.
class LineWriter : Thread {
    public:
    P.AsyncProcess child
    int64 count
    bool ok

    LineWriter(P.AsyncProcess target, int64 lines) {
        child = target
        count = lines
        ok = true
    }

    void run() {
        int64 index = 0
        while (index < count) {
            if (!child.write(format("line{}\n", index))) {
                ok = false
            }
            index = index + 1
        }
        if (!child.closeInput()) {
            ok = false
        }
    }
}

class Counter {
    public:
    int64 bytes
    bool completed

    Counter() {
        bytes = 0
        completed = false
    }

    void take(P.ProcessEvent event) {
        if (event.isStdout()) {
            bytes = bytes + event.data().length
        }
        if (event.isCompleted()) {
            completed = true
        }
    }

    void poll(P.AsyncProcess child, int64 timeoutMilliseconds) {
        P.ProcessEvent event = child.next(timeoutMilliseconds)
        while (event != null) {
            take(event)
            event = child.next(0)
        }
    }

    void drain(P.AsyncProcess child) {
        while (!completed) {
            P.ProcessEvent event = child.next(10000)
            if (event == null) {
                return
            }
            take(event)
        }
    }
}

start {
    Check check = Check()

    # Request/response round trips over a persistent stdin pipe (GDB/MI style).
    P.AsyncProcess shell = P.AsyncProcess("/bin/sh",
        ["-c", "while IFS= read -r line; do printf 'got:%s\\n' \"$line\"; done; echo bye"], null, true)
    check.that("shell started", shell.started())
    check.that("shell interactive", shell.interactive())
    Reader shellOut = Reader()
    check.that("write first", shell.write("-break-insert main\n"))
    check.that("echo first", shellOut.until(shell, "got:-break-insert main\n"))
    check.that("write utf8", shell.write("héllo €\n"))
    check.that("echo utf8", shellOut.until(shell, "got:héllo €\n"))
    check.that("write split1", shell.write("par"))
    check.that("write split2", shell.write("tial\n"))
    check.that("echo split", shellOut.until(shell, "got:partial\n"))
    check.that("empty write", shell.write(""))
    check.that("still running", shell.state() == P.AsyncProcess.RUNNING)
    check.that("no input error", shell.inputError().length == 0)
    check.that("close input", shell.closeInput())
    check.that("close input again", shell.closeInput())
    check.that("drain shell", shellOut.drain(shell))
    check.that("shell transcript", shellOut.out.equals(
        "got:-break-insert main\ngot:héllo €\ngot:partial\nbye\n"))
    check.that("shell exited", shell.state() == P.AsyncProcess.EXITED)
    check.that("shell exit 0", shell.exitCode() == 0)
    check.that("write after closeInput", shell.write("late\n") == false)
    check.that("closeInput message", shell.inputError().contains("closed by closeInput"))
    check.that("pending zero", shell.pendingInput() == 0)
    shell.close()
    check.that("write after close", shell.write("x") == false)
    check.that("closeInput after close", shell.closeInput())
    check.that("cached input error", shell.inputError().contains("closed by closeInput"))

    # Data queued before closeInput is delivered in full before end of file.
    P.AsyncProcess cat = P.AsyncProcess("/bin/cat", [], null, true)
    check.that("cat write", cat.write("queued then closed"))
    check.that("cat closeInput", cat.closeInput())
    Reader catOut = Reader()
    check.that("cat drain", catOut.drain(cat))
    check.that("cat output", catOut.out.equals("queued then closed"))
    check.that("cat exit", cat.exitCode() == 0)
    cat.close()

    # Existing constructors keep stdin at /dev/null and reject writes explicitly.
    P.AsyncProcess plain = P.AsyncProcess("/bin/cat", [])
    check.that("plain eof", plain.wait(10000))
    check.that("plain exit", plain.exitCode() == 0)
    check.that("plain not interactive", plain.interactive() == false)
    check.that("plain write rejected", plain.write("x") == false)
    check.that("plain write message",
        plain.inputError().startsWith("process was not started with interactive input"))
    check.that("plain closeInput rejected", plain.closeInput() == false)
    plain.close()
    P.AsyncProcess optedOut = P.AsyncProcess("/bin/cat", [], "/", false)
    check.that("opted out eof", optedOut.wait(10000))
    check.that("opted out write rejected", optedOut.write("x") == false)
    optedOut.close()

    # Launch failure in interactive mode.
    P.AsyncProcess missing = P.AsyncProcess("/definitely/not/a/cwhip-command", [], null, true)
    check.that("missing not started", missing.started() == false)
    check.that("missing not interactive", missing.interactive() == false)
    check.that("missing write", missing.write("x") == false)
    check.that("missing message", missing.inputError().startsWith("process did not start"))
    check.that("missing closeInput", missing.closeInput() == false)
    missing.close()

    # Streaming far more than the pipe and queue capacity through cat with
    # nonblocking polling only: full queues are reported and retried, partial
    # pipe writes are resumed, and nothing deadlocks or is lost.
    String block = "0123456789abcdef"
    while (block.length < 65536) {
        String copy = block[0..block.length - 1]
        block.append(copy)
    }
    P.AsyncProcess pipe = P.AsyncProcess("/bin/cat", [], null, true)
    Counter pipeOut = Counter()
    int64 sent = 0
    int64 rejected = 0
    int64 blocks = 64
    while (sent < blocks) {
        if (pipe.write(block)) {
            sent = sent + 1
        } else {
            rejected = rejected + 1
            if (!pipe.inputError().startsWith("stdin queue is full")) {
                sent = blocks + 1
            }
            pipeOut.poll(pipe, 5)
        }
    }
    check.that("all blocks queued", sent == blocks)
    check.that("pending bounded", pipe.pendingInput() <= 1048576)
    check.that("pipe closeInput", pipe.closeInput())
    pipeOut.drain(pipe)
    check.that("all bytes echoed", pipeOut.bytes == blocks * 65536)
    check.that("pipe exit", pipe.exitCode() == 0)
    check.that("pipe pending zero", pipe.pendingInput() == 0)
    pipe.close()

    # Backpressure against a child that never reads: the queue is bounded,
    # whole writes are rejected atomically, and oversized writes fail fast.
    P.AsyncProcess stalled = P.AsyncProcess("/bin/sleep", ["30"], null, true)
    int64 accepted = 0
    bool full = false
    while (!full && accepted < 64) {
        if (stalled.write(block)) {
            accepted = accepted + 1
        } else {
            full = true
        }
    }
    check.that("queue fills", full)
    check.that("full message", stalled.inputError().startsWith("stdin queue is full"))
    int64 pending = stalled.pendingInput()
    check.that("pending positive", pending > 0)
    check.that("pending within limit", pending <= 1048576)
    check.that("small write still fits", pending + 1 > 1048576 || stalled.write("z"))
    String oversized = block[0..block.length - 1]
    int64 grow = 0
    while (grow < 5) {
        String piece = oversized[0..oversized.length - 1]
        oversized.append(piece)
        grow = grow + 1
    }
    check.that("oversized rejected", stalled.write(oversized) == false)
    check.that("oversized message", stalled.inputError().startsWith("stdin text exceeds"))
    check.that("stalled still running", stalled.state() == P.AsyncProcess.RUNNING)
    check.that("cancel stalled", stalled.cancel(0))
    check.that("write after cancel", stalled.write("x") == false)
    check.that("cancel message", stalled.inputError().startsWith("process was cancelled"))
    check.that("stalled completes", stalled.wait(10000))
    check.that("stalled cancelled", stalled.state() == P.AsyncProcess.CANCELLED)
    check.that("stalled pending discarded", stalled.pendingInput() == 0)
    check.that("stalled discard reported", stalled.inputError().contains("discarded"))
    stalled.close()

    # Cancellation is reported even after the killed child's broken stdin pipe
    # has been observed: waiting first lets the pump see EPIPE before write.
    P.AsyncProcess killedFull = P.AsyncProcess("/bin/sleep", ["30"], null, true)
    bool killedFullQueued = false
    while (killedFull.write(block)) {
        killedFullQueued = true
    }
    check.that("killed full queued", killedFullQueued && killedFull.pendingInput() > 0)
    check.that("killed full cancel", killedFull.cancel(0))
    check.that("killed full completes", killedFull.wait(10000))
    check.that("killed full message", killedFull.inputError().startsWith("process was cancelled"))
    check.that("killed full discard", killedFull.inputError().contains("discarded"))
    check.that("killed full write", killedFull.write("x") == false)
    check.that("killed full write message",
        killedFull.inputError().startsWith("process was cancelled"))
    check.that("killed full pending", killedFull.pendingInput() == 0)
    killedFull.close()

    P.AsyncProcess killedIdle = P.AsyncProcess("/bin/cat", [], null, true)
    check.that("killed idle cancel", killedIdle.cancel(0))
    check.that("killed idle completes", killedIdle.wait(10000))
    check.that("killed idle cancelled", killedIdle.state() == P.AsyncProcess.CANCELLED)
    check.that("killed idle write", killedIdle.write("x") == false)
    check.that("killed idle message", killedIdle.inputError().startsWith("process was cancelled"))
    check.that("killed idle closeInput", killedIdle.closeInput())
    killedIdle.close()

    # A child that closes its stdin: writes fail with an explicit broken-pipe
    # error and SIGPIPE never terminates this program.
    P.AsyncProcess closer = P.AsyncProcess("/bin/sh", ["-c", "exec 0<&-; echo closed; sleep 30"], null, true)
    Reader closerOut = Reader()
    check.that("closer ready", closerOut.until(closer, "closed\n"))
    bool broken = false
    int64 attempts = 0
    while (!broken && attempts < 400) {
        if (!closer.write("data\n")) {
            broken = true
        } else {
            T.Clock().sleepMilliseconds(5u)
        }
        attempts = attempts + 1
    }
    check.that("broken pipe detected", broken)
    check.that("broken pipe message", closer.inputError().startsWith("stdin closed by the child"))
    check.that("broken pipe sticky", closer.write("again\n") == false)
    check.that("broken pipe message kept", closer.inputError().startsWith("stdin closed by the child"))
    check.that("closer still running", closer.state() == P.AsyncProcess.RUNNING)
    check.that("closer closeInput ok", closer.closeInput())
    closer.close()
    check.that("closer cancelled", closer.state() == P.AsyncProcess.CANCELLED)

    # A child that exits while input is queued: data is discarded and reported.
    P.AsyncProcess quitter = P.AsyncProcess("/bin/sh", ["-c", "head -c 1 >/dev/null; exit 3"], null, true)
    int64 quitterWrites = 0
    while (quitterWrites < 20 && quitter.write(block)) {
        quitterWrites = quitterWrites + 1
    }
    check.that("quitter completes", quitter.wait(10000))
    check.that("quitter exit code", quitter.exitCode() == 3)
    check.that("quitter write rejected", quitter.write("x") == false)
    check.that("quitter pending zero", quitter.pendingInput() == 0)
    check.that("quitter error", quitter.inputError().length > 0)
    quitter.close()

    # Each child's stdin write end is close-on-exec: closing one child's input
    # ends it even while another interactive child is running.
    P.AsyncProcess first = P.AsyncProcess("/bin/cat", [], null, true)
    P.AsyncProcess second = P.AsyncProcess("/bin/cat", [], null, true)
    check.that("first closeInput", first.closeInput())
    check.that("first sees eof", first.wait(10000))
    check.that("second still running", second.state() == P.AsyncProcess.RUNNING)
    check.that("second closeInput", second.closeInput())
    check.that("second sees eof", second.wait(10000))
    first.close()
    second.close()

    # close() with queued input kills the child and releases everything.
    P.AsyncProcess abandoned = P.AsyncProcess("/bin/sleep", ["30"], null, true)
    check.that("abandoned write", abandoned.write(block))
    check.that("abandoned write 2", abandoned.write(block))
    abandoned.close()
    check.that("abandoned cancelled", abandoned.state() == P.AsyncProcess.CANCELLED)
    check.that("abandoned pending", abandoned.pendingInput() == 0)
    check.that("abandoned write rejected", abandoned.write("x") == false)
    abandoned.close()

    # Writer thread and reader thread share one object concurrently.
    P.AsyncProcess shared = P.AsyncProcess("/bin/cat", [], null, true)
    LineWriter writer = LineWriter(shared, 500)
    handle writerThread = writer.launch()
    Reader sharedOut = Reader()
    check.that("shared drain", sharedOut.drain(shared))
    writer.join(writerThread)
    check.that("writer ok", writer.ok)
    String expected = ""
    int64 line = 0
    while (line < 500) {
        expected.append(format("line{}\n", line))
        line = line + 1
    }
    check.that("shared ordered", sharedOut.out.equals(expected))
    shared.close()

    check.that("no failures", check.failures == 0)
}
