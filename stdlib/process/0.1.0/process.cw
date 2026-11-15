/*
 * stdlib/process/0.1.0/process.cw — process package implementation.
 *
 * Created: 2026-10-01
 * Author: chuck
 *
 * Changelog:
 *   2026-10-01  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

namespace Process {

    /*
     * Runtime is a class in this standard-library package.
     *
     * Its methods include spawn, wait, exitCode, stdout, stderr, close, and 20
     * more.
     */
    class Runtime {
        public:
        /*
         * Handles spawn for this Runtime by calling the native function
         * cwhip_process_spawn.
         *
         * Parameters:
         *   executable — String executable.
         *   arguments — list arguments.
         *
         * Returns handle.
         */
        handle spawn(String executable, list arguments)

        /*
         * Handles wait for this Runtime by calling the native function
         * cwhip_process_wait.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns bool.
         */
        bool wait(handle process)

        /*
         * Handles exit code for this Runtime by calling the native function
         * cwhip_process_exit_code.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns int64.
         */
        int64 exitCode(handle process)

        /*
         * Handles stdout for this Runtime by calling the native function
         * cwhip_process_stdout.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns String.
         */
        String stdout(handle process)

        /*
         * Handles stderr for this Runtime by calling the native function
         * cwhip_process_stderr.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns String.
         */
        String stderr(handle process)

        /*
         * Closes the Runtime state by calling the native function
         * cwhip_process_close.
         *
         * Parameters:
         *   process — handle process.
         *
         * Does not return a value.
         */
        void close(handle process)

        /*
         * Handles async start for this Runtime by calling the native function
         * cwhip_process_async_start.
         *
         * Parameters:
         *   executable — String executable.
         *   arguments — list arguments.
         *   workingDirectory — String working directory.
         *
         * Returns handle.
         */
        handle asyncStart(
                String executable,
                list arguments,
                String workingDirectory)

        /*
         * Handles async start interactive for this Runtime by calling the
         * native function cwhip_process_async_start_interactive.
         *
         * Parameters:
         *   executable — String executable.
         *   arguments — list arguments.
         *   workingDirectory — String working directory.
         *
         * Returns handle.
         */
        handle asyncStartInteractive(
                String executable,
                list arguments,
                String workingDirectory)

        /*
         * Handles async write for this Runtime by calling the native function
         * cwhip_process_async_write.
         *
         * Parameters:
         *   process — handle process.
         *   text — String text.
         *
         * Returns bool.
         */
        bool asyncWrite(handle process, String text)

        /*
         * Handles async close input for this Runtime by calling the native
         * function cwhip_process_async_close_input.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns bool.
         */
        bool asyncCloseInput(handle process)

        /*
         * Handles async pending input for this Runtime by calling the native
         * function cwhip_process_async_pending_input.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns int64.
         */
        int64 asyncPendingInput(handle process)

        /*
         * Handles async input error for this Runtime by calling the native
         * function cwhip_process_async_input_error.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns String.
         */
        String asyncInputError(handle process)

        /*
         * Handles async next for this Runtime by calling the native function
         * cwhip_process_async_next.
         *
         * Parameters:
         *   process — handle process.
         *   timeoutMilliseconds — int64 timeout
         *     milliseconds.
         *
         * Returns handle.
         */
        handle asyncNext(handle process, int64 timeoutMilliseconds)

        /*
         * Handles async event kind for this Runtime by calling the native
         * function cwhip_process_async_event_kind.
         *
         * Parameters:
         *   event — handle event.
         *
         * Returns int64.
         */
        int64 asyncEventKind(handle event)

        /*
         * Handles async event data for this Runtime by calling the native
         * function cwhip_process_async_event_data.
         *
         * Parameters:
         *   event — handle event.
         *
         * Returns buffer.
         */
        buffer asyncEventData(handle event)

        /*
         * Handles async event release for this Runtime by calling the native
         * function cwhip_process_async_event_release.
         *
         * Parameters:
         *   event — handle event.
         *
         * Does not return a value.
         */
        void asyncEventRelease(handle event)

        /*
         * Handles async wait for this Runtime by calling the native function
         * cwhip_process_async_wait.
         *
         * Parameters:
         *   process — handle process.
         *   timeoutMilliseconds — int64 timeout
         *     milliseconds.
         *
         * Returns bool.
         */
        bool asyncWait(handle process, int64 timeoutMilliseconds)

        /*
         * Handles async cancel for this Runtime by calling the native function
         * cwhip_process_async_cancel.
         *
         * Parameters:
         *   process — handle process.
         *   graceMilliseconds — int64 grace milliseconds.
         *
         * Returns bool.
         */
        bool asyncCancel(handle process, int64 graceMilliseconds)

        /*
         * Handles async state for this Runtime by calling the native function
         * cwhip_process_async_state.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns int64.
         */
        int64 asyncState(handle process)

        /*
         * Handles async exit code for this Runtime by calling the native
         * function cwhip_process_async_exit_code.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns int64.
         */
        int64 asyncExitCode(handle process)

        /*
         * Handles async signal for this Runtime by calling the native function
         * cwhip_process_async_signal.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns int64.
         */
        int64 asyncSignal(handle process)

        /*
         * Handles async error for this Runtime by calling the native function
         * cwhip_process_async_error.
         *
         * Parameters:
         *   process — handle process.
         *
         * Returns String.
         */
        String asyncError(handle process)

        /*
         * Handles async shutdown for this Runtime by calling the native
         * function cwhip_process_async_shutdown.
         *
         * Parameters:
         *   process — handle process.
         *
         * Does not return a value.
         */
        void asyncShutdown(handle process)

        /*
         * Handles async close for this Runtime by calling the native function
         * cwhip_process_async_close.
         *
         * Parameters:
         *   process — handle process.
         *
         * Does not return a value.
         */
        void asyncClose(handle process)

        /*
         * Handles text decode for this Runtime by calling the native function
         * cwhip_process_text_decode.
         *
         * Parameters:
         *   bytes — buffer bytes.
         *
         * Returns String.
         */
        String textDecode(buffer bytes)

        /*
         * Handles text incomplete tail for this Runtime by calling the native
         * function cwhip_process_text_incomplete_tail.
         *
         * Parameters:
         *   bytes — buffer bytes.
         *
         * Returns int64.
         */
        int64 textIncompleteTail(buffer bytes)
    }

    /*
     * Process is a class in this standard-library package.
     *
     * Its methods include constructor, started, wait, exitCode, stdout,
     * stderr, and 1 more.
     */
    class Process {
        private:
        handle _native

        public:
        /*
         * Constructs a Process and stores _native.
         *
         * Parameters:
         *   executable — String executable.
         *   arguments — list arguments.
         *
         * Returns the constructed Process.
         */
        Process(String executable, list arguments) {
            _native = Runtime().spawn(executable, arguments)
        }

        /*
         * Returns _native != null.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool started() {
            return(_native != null)
        }

        /*
         * Returns Runtime().wait(_native).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool wait() {
            return(Runtime().wait(_native))
        }

        /*
         * Returns Runtime().exitCode(_native).
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 exitCode() {
            return(Runtime().exitCode(_native))
        }

        /*
         * Returns Runtime().stdout(_native).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String stdout() {
            return(Runtime().stdout(_native))
        }

        /*
         * Returns Runtime().stderr(_native).
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String stderr() {
            return(Runtime().stderr(_native))
        }

        /*
         * Closes the Process state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
        void close() {
            if (_native != null) {
                Runtime().close(_native)
                _native = null
            }
        }
    }

    /*
     * ProcessEvent is a class in this standard-library package.
     *
     * Its methods include constructor, kind, isStdout, isStderr, isCompleted,
     * data.
     */
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
        /*
         * Constructs a ProcessEvent and stores _kind, _data.
         *
         * Parameters:
         *   kind — int64 kind.
         *   data — buffer data.
         *
         * Returns the constructed ProcessEvent.
         */
        ProcessEvent(int64 kind, buffer data) {
            _kind = kind
            _data = data
        }

        /*
         * Returns the stored _kind.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 kind() {
            return(_kind)
        }

        /*
         * Returns _kind == ProcessEvent.STDOUT.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isStdout() {
            return(_kind == ProcessEvent.STDOUT)
        }

        /*
         * Returns _kind == ProcessEvent.STDERR.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isStderr() {
            return(_kind == ProcessEvent.STDERR)
        }

        /*
         * Returns _kind == ProcessEvent.COMPLETED.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool isCompleted() {
            return(_kind == ProcessEvent.COMPLETED)
        }

        /*
         * Returns the stored _data.
         *
         * Takes no parameters.
         *
         * Returns buffer.
         */
        buffer data() {
            return(_data)
        }
    }

    /*
     * OutputDecoder is a class in this standard-library package.
     *
     * Its methods include constructor, decode, finish, pending.
     */
    class OutputDecoder {
        private:
        buffer _pending

        public:
        /*
         * Constructs a OutputDecoder and stores _pending.
         *
         * Takes no parameters.
         *
         * Returns the constructed OutputDecoder.
         */
        OutputDecoder() {
            _pending = buffer[]
        }

        /*
         * Handles decode for this OutputDecoder.
         *
         * Parameters:
         *   chunk — buffer chunk.
         *
         * Returns String.
         */
        String decode(buffer chunk) {
            if (chunk != null) {
                int64 index = 0
                while (index < chunk.length) {
                    _pending.append(chunk[index])
                    index = index + 1
                }
            }
            int64 complete = _pending.length - Runtime().textIncompleteTail(
                    _pending)
            buffer ready = _pending[0:complete]
            _pending = _pending[complete:]
            return(Runtime().textDecode(ready))
        }

        /*
         * Handles finish for this OutputDecoder.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String finish() {
            String rest = Runtime().textDecode(_pending)
            _pending = buffer[]
            return(rest)
        }

        /*
         * Returns _pending.length.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 pending() {
            return(_pending.length)
        }
    }

    /*
     * AsyncProcess is a class in this standard-library package.
     *
     * Its methods include launch, constructor, started, next, wait, finished,
     * and 11 more.
     */
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

        /*
         * Handles launch for this AsyncProcess.
         *
         * Parameters:
         *   executable — String executable.
         *   arguments — list arguments.
         *   workingDirectory — String working directory.
         *   interactive — bool interactive.
         *
         * Does not return a value.
         */
        void launch(
                String executable,
                list arguments,
                String workingDirectory,
                bool interactive) {
            _closed = false
            _interactive = interactive
            if (interactive) {
                _native = Runtime().asyncStartInteractive(
                        executable,
                        arguments,
                        workingDirectory)
            }
            else {
                _native = Runtime().asyncStart(
                        executable,
                        arguments,
                        workingDirectory)
            }
        }

        public:
        /*
         * Constructs a AsyncProcess.
         *
         * Parameters:
         *   executable — String executable.
         *   arguments — list arguments.
         *
         * Returns the constructed AsyncProcess.
         */
        AsyncProcess(String executable, list arguments) {
            launch(executable, arguments, null, false)
        }

        /*
         * Constructs a AsyncProcess.
         *
         * Parameters:
         *   executable — String executable.
         *   arguments — list arguments.
         *   workingDirectory — String working directory.
         *
         * Returns the constructed AsyncProcess.
         */
        AsyncProcess(
                String executable,
                list arguments,
                String workingDirectory) {
            launch(executable, arguments, workingDirectory, false)
        }

        /*
         * Constructs a AsyncProcess.
         *
         * Parameters:
         *   executable — String executable.
         *   arguments — list arguments.
         *   workingDirectory — String working directory.
         *   interactive — bool interactive.
         *
         * Returns the constructed AsyncProcess.
         */
        AsyncProcess(
                String executable,
                list arguments,
                String workingDirectory,
                bool interactive) {
            launch(executable, arguments, workingDirectory, interactive)
        }

        /*
         * Returns state() != AsyncProcess.LAUNCH_FAILED.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool started() {
            return(state() != AsyncProcess.LAUNCH_FAILED)
        }

        /*
         * Handles next for this AsyncProcess.
         *
         * Parameters:
         *   timeoutMilliseconds — int64 timeout
         *     milliseconds.
         *
         * Returns ProcessEvent.
         */
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

        /*
         * Handles wait for this AsyncProcess.
         *
         * Parameters:
         *   timeoutMilliseconds — int64 timeout
         *     milliseconds.
         *
         * Returns bool.
         */
        bool wait(int64 timeoutMilliseconds) {
            if (_closed) {
                return(true)
            }
            return(Runtime().asyncWait(_native, timeoutMilliseconds))
        }

        /*
         * Returns wait(0).
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool finished() {
            return(wait(0))
        }

        /*
         * Cancels the AsyncProcess state.
         *
         * Parameters:
         *   graceMilliseconds — int64 grace milliseconds.
         *
         * Returns bool.
         */
        bool cancel(int64 graceMilliseconds) {
            if (_closed) {
                return(false)
            }
            return(Runtime().asyncCancel(_native, graceMilliseconds))
        }

        /*
         * Handles state for this AsyncProcess.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 state() {
            if (_closed) {
                return(_state)
            }
            return(Runtime().asyncState(_native))
        }

        /*
         * Handles exit code for this AsyncProcess.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 exitCode() {
            if (_closed) {
                return(_exitCode)
            }
            return(Runtime().asyncExitCode(_native))
        }

        /*
         * Handles signal for this AsyncProcess.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 signal() {
            if (_closed) {
                return(_signal)
            }
            return(Runtime().asyncSignal(_native))
        }

        /*
         * Handles error for this AsyncProcess.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String error() {
            if (_closed) {
                return(_error)
            }
            return(Runtime().asyncError(_native))
        }

        /*
         * Returns _interactive && started().
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool interactive() {
            return(_interactive && started())
        }

        /*
         * Writes the AsyncProcess state.
         *
         * Parameters:
         *   text — String text.
         *
         * Returns bool.
         */
        bool write(String text) {
            if (_closed) {
                return(false)
            }
            return(Runtime().asyncWrite(_native, text))
        }

        /*
         * Closes input for this AsyncProcess.
         *
         * Takes no parameters.
         *
         * Returns bool.
         */
        bool closeInput() {
            if (_closed) {
                return(interactive())
            }
            return(Runtime().asyncCloseInput(_native))
        }

        /*
         * Handles pending input for this AsyncProcess.
         *
         * Takes no parameters.
         *
         * Returns int64.
         */
        int64 pendingInput() {
            if (_closed) {
                return(0)
            }
            return(Runtime().asyncPendingInput(_native))
        }

        /*
         * Handles input error for this AsyncProcess.
         *
         * Takes no parameters.
         *
         * Returns String.
         */
        String inputError() {
            if (_closed) {
                return(_inputError)
            }
            return(Runtime().asyncInputError(_native))
        }

        /*
         * Closes the AsyncProcess state.
         *
         * Takes no parameters.
         *
         * Does not return a value.
         */
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
    handle Runtime.asyncStart(
            String executable,
            list arguments,
            String workingDirectory) from "cwhip_process_async_start"
    handle Runtime.asyncStartInteractive(
            String executable,
            list arguments,
            String workingDirectory) from "cwhip_process_async_start_interactive"
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
