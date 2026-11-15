/*
 * tests/functional/positive/positive_inline_stdlib.cw — Checks inline stdlib.
 *
 * Created: 2026-10-09
 * Author: chuck
 *
 * Changelog:
 *   2026-10-09  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

import math as M
import system as Sys

start {
    fp64 root = 0.0
    uint64 clock = 0u
    bool ok = false
    strg path
    strg mode = "w+"
    strg message = "inline public API"
    strg result
    strg error
    strg pattern = "/this/path/does/not/exist/*"
    list matches
    buffer bytes
    handle file
    handle mutex
    handle condition
    handle semaphore
    handle child
    strg executable = "/usr/bin/printf"
    list arguments = ["inline-child"]
    strg childOutput
    strg missing = "/this/path/does/not/exist"
    bool failed = false
    inline (
            fp64 root,
            uint64 clock,
            bool ok,
            strg path,
            strg mode,
            strg message,
            strg result,
            strg error,
            strg pattern,
            list matches,
            buffer bytes,
            handle file,
            handle mutex,
            handle condition,
            handle semaphore,
            handle child,
            strg executable,
            list arguments,
            strg childOutput,
            strg missing,
            bool failed) {
        *root = cwhip_math_sqrt(NULL, 9.0);
        *clock = cwhip_time_monotonic_milliseconds(NULL);
        *path = cwhip_fs_temp_file(NULL);
        *file = cwhip_file_open(NULL, *path, *mode);
        *ok = *file != NULL &&
              cwhip_file_write(NULL, *file, *message) == 17 &&
              cwhip_file_seek(NULL, *file, 0, 0) == 0;
        *result = cwhip_file_read_all(NULL, *file);
        cwhip_file_close(NULL, *file);
        *file = NULL;
        *ok = *ok && cwhip_fs_remove(NULL, *path);
        *matches = cwhip_glob_glob(NULL, *pattern);
        *bytes = cwhip_random_bytes(NULL, 4);
        *ok = *ok && *bytes != NULL && cwhip_random_fill(NULL, *bytes) &&
              cwhip_time_sleep_milliseconds(NULL, 0) &&
              cwhip_terminal_columns(NULL) >= 0;
        *mutex = cwhip_mutex_create(NULL);
        *condition = cwhip_condition_create(NULL);
        *semaphore = cwhip_semaphore_create(NULL, 0);
        *ok = *ok && *mutex && *condition && *semaphore &&
              cwhip_mutex_lock(NULL, *mutex) && cwhip_mutex_unlock(NULL, *mutex) &&
              cwhip_condition_signal(NULL, *condition) &&
              cwhip_condition_release(NULL, *condition) && cwhip_mutex_release(NULL, *mutex);
        cwhip_semaphore_signal(NULL, *semaphore);
        cwhip_semaphore_wait(NULL, *semaphore);
        cwhip_semaphore_release(NULL, *semaphore);
        *mutex = *condition = *semaphore = NULL;
        int64_t socket = cwhip_net_socket_create(NULL);
        *ok = *ok && socket >= 0;
        if (socket >= 0) cwhip_net_socket_close(NULL, socket);
        *child = cwhip_process_spawn(NULL, *executable, *arguments);
        *ok = *ok && *child != NULL && cwhip_process_wait(NULL, *child) &&
              cwhip_process_exit_code(NULL, *child) == 0;
        *childOutput = cwhip_process_stdout(NULL, *child);
        cwhip_process_close(NULL, *child);
        *child = NULL;
        *failed = cwhip_fs_file_size(NULL, *missing) == -1;
        *error = cwhip_system_last_error(NULL);
        *ok = *ok && cwhip_system_argc(NULL) >= 1 &&
              strcmp(cwhip_string_cstr(result), "inline public API") == 0;
    }
    print(root == M.Math().sqrt(9.0))
    print(clock > 0u)
    print(ok)
    print(result)
    print(matches.length)
    print(bytes.length)
    print(failed && error.length > 0)
    print(childOutput)
    print(Sys.System().argc() > 0)
}
