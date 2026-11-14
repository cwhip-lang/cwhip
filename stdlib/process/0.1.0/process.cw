namespace Process {
    class Runtime {
        public:
        handle spawn(String executable, list arguments)
        bool wait(handle process)
        int64 exitCode(handle process)
        String stdout(handle process)
        String stderr(handle process)
        void close(handle process)

        handle asyncStart(String executable, list arguments, String workingDirectory)
        handle asyncStartInteractive(String executable, list arguments, String workingDirectory)
        bool asyncWrite(handle process, String text)
        bool asyncCloseInput(handle process)
        int64 asyncPendingInput(handle process)
        String asyncInputError(handle process)
        handle asyncNext(handle process, int64 timeoutMilliseconds)
        int64 asyncEventKind(handle event)
        buffer asyncEventData(handle event)
        void asyncEventRelease(handle event)
        bool asyncWait(handle process, int64 timeoutMilliseconds)
        bool asyncCancel(handle process, int64 graceMilliseconds)
        int64 asyncState(handle process)
        int64 asyncExitCode(handle process)
        int64 asyncSignal(handle process)
        String asyncError(handle process)
        void asyncShutdown(handle process)
        void asyncClose(handle process)
        String textDecode(buffer bytes)
        int64 textIncompleteTail(buffer bytes)
    }

    class Process {
        private:
        handle _native

        public:
        Process(String executable, list arguments) {
            _native = Runtime().spawn(executable, arguments)
        }

        bool started() {
            return(_native != null)
        }

        bool wait() {
            return(Runtime().wait(_native))
        }

        int64 exitCode() {
            return(Runtime().exitCode(_native))
        }

        String stdout() {
            return(Runtime().stdout(_native))
        }

        String stderr() {
            return(Runtime().stderr(_native))
        }

        void close() {
            if (_native != null) {
                Runtime().close(_native)
                _native = null
            }
        }
    }

    class ProcessEvent {
        public:
        enum {
            STDOUT = 1,
            STDERR,
            COMPLETED
        }

        private:
        int64 _kind
        buffer _data

        public:
        ProcessEvent(int64 kind, buffer data) {
            _kind = kind
            _data = data
        }

        int64 kind() {
            return(_kind)
        }

        bool isStdout() {
            return(_kind == ProcessEvent.STDOUT)
        }

        bool isStderr() {
            return(_kind == ProcessEvent.STDERR)
        }

        bool isCompleted() {
            return(_kind == ProcessEvent.COMPLETED)
        }

        buffer data() {
            return(_data)
        }
    }

    class OutputDecoder {
        private:
        buffer _pending

        public:
        OutputDecoder() {
            _pending = buffer[]
        }

        String decode(buffer chunk) {
            if (chunk != null) {
                int64 index = 0
                while (index < chunk.length) {
                    _pending.append(chunk[index])
                    index = index + 1
                }
            }
            int64 complete = _pending.length - Runtime().textIncompleteTail(_pending)
            buffer ready = _pending[0:complete]
            _pending = _pending[complete:]
            return(Runtime().textDecode(ready))
        }

        String finish() {
            String rest = Runtime().textDecode(_pending)
            _pending = buffer[]
            return(rest)
        }

        int64 pending() {
            return(_pending.length)
        }
    }

    class AsyncProcess {
        public:
        enum {
            RUNNING = 0,
            EXITED,
            SIGNALED,
            CANCELLED,
            LAUNCH_FAILED,
            WAIT_FAILED
        }

        private:
        handle _native
        bool _closed
        int64 _state
        int64 _exitCode
        int64 _signal
        String _error
        bool _interactive
        String _inputError

        void launch(String executable, list arguments, String workingDirectory, bool interactive) {
            _closed = false
            _interactive = interactive
            if (interactive) {
                _native = Runtime().asyncStartInteractive(executable, arguments, workingDirectory)
            } else {
                _native = Runtime().asyncStart(executable, arguments, workingDirectory)
            }
        }

        public:
        AsyncProcess(String executable, list arguments) {
            launch(executable, arguments, null, false)
        }

        AsyncProcess(String executable, list arguments, String workingDirectory) {
            launch(executable, arguments, workingDirectory, false)
        }

        AsyncProcess(String executable, list arguments, String workingDirectory, bool interactive) {
            launch(executable, arguments, workingDirectory, interactive)
        }

        bool started() {
            return(state() != AsyncProcess.LAUNCH_FAILED)
        }

        ProcessEvent next(int64 timeoutMilliseconds) {
            if (_closed) {
                return(null)
            }
            handle raw = Runtime().asyncNext(_native, timeoutMilliseconds)
            if (raw == null) {
                return(null)
            }
            int64 kind = Runtime().asyncEventKind(raw)
            buffer data = Runtime().asyncEventData(raw)
            ProcessEvent event = ProcessEvent(kind, data)
            Runtime().asyncEventRelease(raw)
            return(event)
        }

        bool wait(int64 timeoutMilliseconds) {
            if (_closed) {
                return(true)
            }
            return(Runtime().asyncWait(_native, timeoutMilliseconds))
        }

        bool finished() {
            return(wait(0))
        }

        bool cancel(int64 graceMilliseconds) {
            if (_closed) {
                return(false)
            }
            return(Runtime().asyncCancel(_native, graceMilliseconds))
        }

        int64 state() {
            if (_closed) {
                return(_state)
            }
            return(Runtime().asyncState(_native))
        }

        int64 exitCode() {
            if (_closed) {
                return(_exitCode)
            }
            return(Runtime().asyncExitCode(_native))
        }

        int64 signal() {
            if (_closed) {
                return(_signal)
            }
            return(Runtime().asyncSignal(_native))
        }

        String error() {
            if (_closed) {
                return(_error)
            }
            return(Runtime().asyncError(_native))
        }

        bool interactive() {
            return(_interactive && started())
        }

        bool write(String text) {
            if (_closed) {
                return(false)
            }
            return(Runtime().asyncWrite(_native, text))
        }

        bool closeInput() {
            if (_closed) {
                return(interactive())
            }
            return(Runtime().asyncCloseInput(_native))
        }

        int64 pendingInput() {
            if (_closed) {
                return(0)
            }
            return(Runtime().asyncPendingInput(_native))
        }

        String inputError() {
            if (_closed) {
                return(_inputError)
            }
            return(Runtime().asyncInputError(_native))
        }

        void close() {
            if (_closed) {
                return
            }
            Runtime().asyncShutdown(_native)
            if (_closed) {
                return
            }
            _state = Runtime().asyncState(_native)
            _exitCode = Runtime().asyncExitCode(_native)
            _signal = Runtime().asyncSignal(_native)
            _error = Runtime().asyncError(_native)
            _inputError = Runtime().asyncInputError(_native)
            handle native = _native
            _native = null
            _closed = true
            Runtime().asyncClose(native)
        }
    }

    handle Runtime.spawn(String executable, list arguments) from "cwhip_process_spawn"
    bool Runtime.wait(handle process) from "cwhip_process_wait"
    int64 Runtime.exitCode(handle process) from "cwhip_process_exit_code"
    String Runtime.stdout(handle process) from "cwhip_process_stdout"
    String Runtime.stderr(handle process) from "cwhip_process_stderr"
    void Runtime.close(handle process) from "cwhip_process_close"
    handle Runtime.asyncStart(String executable, list arguments, String workingDirectory) from "cwhip_process_async_start"
    handle Runtime.asyncStartInteractive(String executable, list arguments, String workingDirectory) from "cwhip_process_async_start_interactive"
    bool Runtime.asyncWrite(handle process, String text) from "cwhip_process_async_write"
    bool Runtime.asyncCloseInput(handle process) from "cwhip_process_async_close_input"
    int64 Runtime.asyncPendingInput(handle process) from "cwhip_process_async_pending_input"
    String Runtime.asyncInputError(handle process) from "cwhip_process_async_input_error"
    handle Runtime.asyncNext(handle process, int64 timeoutMilliseconds) from "cwhip_process_async_next"
    int64 Runtime.asyncEventKind(handle event) from "cwhip_process_async_event_kind"
    buffer Runtime.asyncEventData(handle event) from "cwhip_process_async_event_data"
    void Runtime.asyncEventRelease(handle event) from "cwhip_process_async_event_release"
    bool Runtime.asyncWait(handle process, int64 timeoutMilliseconds) from "cwhip_process_async_wait"
    bool Runtime.asyncCancel(handle process, int64 graceMilliseconds) from "cwhip_process_async_cancel"
    int64 Runtime.asyncState(handle process) from "cwhip_process_async_state"
    int64 Runtime.asyncExitCode(handle process) from "cwhip_process_async_exit_code"
    int64 Runtime.asyncSignal(handle process) from "cwhip_process_async_signal"
    String Runtime.asyncError(handle process) from "cwhip_process_async_error"
    void Runtime.asyncShutdown(handle process) from "cwhip_process_async_shutdown"
    void Runtime.asyncClose(handle process) from "cwhip_process_async_close"
    String Runtime.textDecode(buffer bytes) from "cwhip_process_text_decode"
    int64 Runtime.textIncompleteTail(buffer bytes) from "cwhip_process_text_incomplete_tail"
}
