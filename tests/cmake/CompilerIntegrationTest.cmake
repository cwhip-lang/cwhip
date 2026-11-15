if(NOT DEFINED COMPILER OR NOT DEFINED SOURCE OR NOT DEFINED OUTPUT)
    message(FATAL_ERROR "COMPILER, SOURCE, and OUTPUT are required")
endif()

# Every case runs in its own work directory with the compiler's path
# environment cleared, so only the case's own module configuration is seen.
set(work_directory "${OUTPUT}.work")
set(project_directory "${work_directory}/project")
file(REMOVE_RECURSE "${work_directory}")
file(MAKE_DIRECTORY "${project_directory}")
set(compiler_environment
    --unset=CWHIP_MODULE_DIR --unset=CWHIP_PACKAGE_PATH --unset=CWHIP_MODULE_REGISTRY
    --unset=CWHIP_HOME --unset=CWHIP_RUNTIME_DIR --unset=CWHIP_INCLUDE_DIR
    --unset=CWHIP_BUILTIN_DIR --unset=CWHIP_STDLIB_MODULE_DIR
    "HOME=${work_directory}/home" "XDG_CONFIG_HOME=${work_directory}/xdg")
file(MAKE_DIRECTORY "${work_directory}/home" "${work_directory}/xdg")
if(MODULE_PACKAGES)
    file(MAKE_DIRECTORY "${project_directory}/modules")
    file(COPY "${PACKAGE_FIXTURES}/" DESTINATION "${project_directory}/modules")
endif()
if(MODULE_PACKAGES OR DEFINED MODULE_ROOT OR DEFINED MODULE_ROOT_SOURCE)
    get_filename_component(source_name "${SOURCE}" NAME)
    file(COPY "${SOURCE}" DESTINATION "${project_directory}")
    set(SOURCE "${project_directory}/${source_name}")
endif()
set(package_arguments)
if(DEFINED MODULE_ROOT OR DEFINED MODULE_ROOT_SOURCE)
    if(NOT DEFINED MODULE_ROOT_SOURCE)
        set(MODULE_ROOT_SOURCE cli)
    endif()
    set(default_module_root "${project_directory}/modules")
    set(environment_module_root "${work_directory}/env-modules")
    if(MODULE_ROOT_SOURCE STREQUAL "cli")
        set(PACKAGE_SEARCH_ROOT "${work_directory}/cli-modules")
        list(APPEND package_arguments -M "${PACKAGE_SEARCH_ROOT}")
        set(decoy_roots "${environment_module_root}" "${default_module_root}")
        if(DEFINED MODULE_DECOY)
            list(APPEND compiler_environment "CWHIP_MODULE_DIR=${environment_module_root}")
        endif()
    elseif(MODULE_ROOT_SOURCE STREQUAL "env")
        set(PACKAGE_SEARCH_ROOT "${environment_module_root}")
        list(APPEND compiler_environment "CWHIP_MODULE_DIR=${PACKAGE_SEARCH_ROOT}")
        set(decoy_roots "${default_module_root}")
    elseif(MODULE_ROOT_SOURCE STREQUAL "default")
        set(PACKAGE_SEARCH_ROOT "${default_module_root}")
        set(decoy_roots)
    elseif(MODULE_ROOT_SOURCE STREQUAL "home")
        set(PACKAGE_SEARCH_ROOT "${work_directory}/xdg/cwhip/modules")
        file(MAKE_DIRECTORY "${PACKAGE_SEARCH_ROOT}")
    elseif(MODULE_ROOT_SOURCE STREQUAL "stdlib")
        set(PACKAGE_SEARCH_ROOT "${work_directory}/stdlib-modules")
        list(APPEND compiler_environment "CWHIP_STDLIB_MODULE_DIR=${PACKAGE_SEARCH_ROOT}")
        set(decoy_roots)
    else()
        message(FATAL_ERROR "Unsupported MODULE_ROOT_SOURCE: ${MODULE_ROOT_SOURCE}")
    endif()
    if(NOT MODULE_ROOT_MISSING)
        file(MAKE_DIRECTORY "${PACKAGE_SEARCH_ROOT}")
        if(DEFINED MODULE_ROOT)
            file(COPY "${MODULE_ROOT}/" DESTINATION "${PACKAGE_SEARCH_ROOT}")
        endif()
    endif()
    if(DEFINED MODULE_DECOY)
        if(NOT decoy_roots AND NOT MODULE_ROOT_SOURCE STREQUAL "home")
            message(FATAL_ERROR "MODULE_DECOY needs a lower-precedence module root")
        endif()
        set(stdlib_decoy_root "${work_directory}/stdlib-decoy")
        list(APPEND decoy_roots "${stdlib_decoy_root}")
        list(APPEND compiler_environment "CWHIP_STDLIB_MODULE_DIR=${stdlib_decoy_root}")
        foreach(decoy_root IN LISTS decoy_roots)
            file(MAKE_DIRECTORY "${decoy_root}")
            file(COPY "${MODULE_DECOY}/" DESTINATION "${decoy_root}")
        endforeach()
    endif()
endif()
if(DEFINED ARGUMENTS)
    list(APPEND package_arguments ${ARGUMENTS})
endif()
set(package_command "${CMAKE_COMMAND}" -E env ${compiler_environment} "${COMPILER}")
set(source_arguments "${SOURCE}")
if(NO_SOURCE)
    set(source_arguments)
endif()

# Expectations may name case paths with <MODULE_ROOT>, <PROJECT_DIR>, and
# <WORK_DIR>; the substituted paths are regex-escaped.
function(expand_case_pattern output pattern)
    set(expanded "${pattern}")
    foreach(placeholder_pair IN ITEMS
            "MODULE_ROOT|${PACKAGE_SEARCH_ROOT}" "PROJECT_DIR|${project_directory}"
            "WORK_DIR|${work_directory}")
        string(FIND "${placeholder_pair}" "|" separator)
        string(SUBSTRING "${placeholder_pair}" 0 ${separator} placeholder)
        math(EXPR value_start "${separator} + 1")
        string(SUBSTRING "${placeholder_pair}" ${value_start} -1 value)
        string(REGEX REPLACE "([][+.*()^$?|\\\\{}])" "\\\\\\1" escaped "${value}")
        string(REPLACE "<${placeholder}>" "${escaped}" expanded "${expanded}")
    endforeach()
    set(${output} "${expanded}" PARENT_SCOPE)
endfunction()

function(check_compile_output text)
    if(text MATCHES "AddressSanitizer|UndefinedBehaviorSanitizer|runtime error:")
        message(FATAL_ERROR "Compiler sanitizer failure:\n${text}")
    endif()
    foreach(expected IN LISTS EXPECT_COMPILE_OUTPUT)
        expand_case_pattern(expected_pattern "${expected}")
        if(NOT text MATCHES "${expected_pattern}")
            message(FATAL_ERROR "Expected compiler output '${expected_pattern}', got:\n${text}")
        endif()
    endforeach()
    foreach(rejected IN LISTS REJECT_COMPILE_OUTPUT)
        expand_case_pattern(rejected_pattern "${rejected}")
        if(text MATCHES "${rejected_pattern}")
            message(FATAL_ERROR "Unexpected compiler output '${rejected_pattern}' in:\n${text}")
        endif()
    endforeach()
endfunction()

if(DEFINED PACKAGE_NATIVE_SOURCE)
    if(NOT DEFINED CLANG OR NOT DEFINED AR OR NOT DEFINED PACKAGE_NATIVE_LIBRARY)
        message(FATAL_ERROR "Package native builds require CLANG, AR, and a library name")
    endif()
    set(native_source "${PACKAGE_SEARCH_ROOT}/${PACKAGE_NATIVE_SOURCE}")
    get_filename_component(native_source_directory "${native_source}" DIRECTORY)
    get_filename_component(package_version_directory "${native_source_directory}" DIRECTORY)
    set(native_library_directory "${package_version_directory}/lib")
    file(MAKE_DIRECTORY "${native_library_directory}")
    set(native_object "${OUTPUT}.native.o")
    execute_process(
        COMMAND "${CLANG}" -c "${native_source}" -o "${native_object}"
        RESULT_VARIABLE native_compile_result
        OUTPUT_VARIABLE native_compile_stdout
        ERROR_VARIABLE native_compile_stderr
    )
    if(NOT native_compile_result EQUAL 0)
        message(FATAL_ERROR "Could not compile package native shim:\n${native_compile_stderr}")
    endif()
    execute_process(
        COMMAND "${AR}" rcs
            "${native_library_directory}/lib${PACKAGE_NATIVE_LIBRARY}.a"
            "${native_object}"
        RESULT_VARIABLE native_archive_result
        OUTPUT_VARIABLE native_archive_stdout
        ERROR_VARIABLE native_archive_stderr
    )
    if(NOT native_archive_result EQUAL 0)
        message(FATAL_ERROR "Could not archive package native shim:\n${native_archive_stderr}")
    endif()
endif()

if(DEFINED EXPECTED_DIAGNOSTIC)
    execute_process(
        COMMAND ${package_command} ${package_arguments} ${source_arguments} -o "${OUTPUT}"
        WORKING_DIRECTORY "${work_directory}"
        RESULT_VARIABLE result
        OUTPUT_VARIABLE stdout
        ERROR_VARIABLE stderr
    )
    if(result EQUAL 0)
        message(FATAL_ERROR "Expected compilation to fail, but it succeeded")
    endif()
    expand_case_pattern(expected_diagnostic "${EXPECTED_DIAGNOSTIC}")
    if(NOT stderr MATCHES "${expected_diagnostic}")
        message(FATAL_ERROR "Expected diagnostic '${expected_diagnostic}', got:\n${stderr}")
    endif()
    check_compile_output("${stdout}${stderr}")
    return()
endif()

if(NO_RUN)
    execute_process(
        COMMAND ${package_command} ${package_arguments} ${source_arguments}
        WORKING_DIRECTORY "${work_directory}"
        RESULT_VARIABLE result
        OUTPUT_VARIABLE stdout
        ERROR_VARIABLE stderr
    )
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "Compiler invocation failed (${result}):\n${stdout}${stderr}")
    endif()
    check_compile_output("${stdout}${stderr}")
    return()
endif()

if(NOT DEFINED IR_OUTPUT OR
   (NOT DEFINED EXPECTED_OUTPUT_FILE AND NOT DEFINED EXPECTED_OUTPUT AND
    NOT DEFINED EXPECT_EMPTY_OUTPUT))
    message(FATAL_ERROR "IR_OUTPUT and an expected output value/file are required for run mode")
endif()
if(DEFINED EXPECT_EMPTY_OUTPUT)
    set(EXPECTED_OUTPUT "")
elseif(DEFINED EXPECTED_OUTPUT)
    string(ASCII 27 ESCAPE_E)
    string(REPLACE "@ESC@" "${ESCAPE_E}" EXPECTED_OUTPUT "${EXPECTED_OUTPUT}")
    string(REPLACE "@NL@" "\n" EXPECTED_OUTPUT "${EXPECTED_OUTPUT}")
elseif(NOT EXISTS "${EXPECTED_OUTPUT_FILE}")
    message(FATAL_ERROR "Missing output expectation: ${EXPECTED_OUTPUT_FILE}")
else()
    file(READ "${EXPECTED_OUTPUT_FILE}" EXPECTED_OUTPUT)
endif()
if(DEFINED COMPILE_ONLY)
    set(package_object "${OUTPUT}.o")
    execute_process(
        COMMAND ${package_command} ${package_arguments} -c "${SOURCE}" -o "${package_object}"
        WORKING_DIRECTORY "${work_directory}"
        RESULT_VARIABLE compile_result
        OUTPUT_VARIABLE compile_stdout
        ERROR_VARIABLE compile_stderr
    )
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "Package compile-only failed (${compile_result}):\n${compile_stderr}")
    endif()
    check_compile_output("${compile_stdout}${compile_stderr}")
    if(NOT EXISTS "${package_object}.cwhip-link")
        message(FATAL_ERROR "Package compile-only did not write its link sidecar")
    endif()
    execute_process(
        COMMAND ${package_command} "${package_object}" -o "${OUTPUT}"
        WORKING_DIRECTORY "${work_directory}"
        RESULT_VARIABLE link_result
        OUTPUT_VARIABLE link_stdout
        ERROR_VARIABLE link_stderr
    )
    if(NOT link_result EQUAL 0)
        message(FATAL_ERROR "Package object relink failed (${link_result}):\n${link_stderr}")
    endif()
    # Force a non-TTY stdin by default, matching the main run path below, so
    # results are deterministic regardless of whether ctest was invoked from
    # an interactive terminal.
    execute_process(
        COMMAND "${OUTPUT}" ${run_arguments}
        RESULT_VARIABLE run_result
        OUTPUT_VARIABLE program_output
        ERROR_VARIABLE run_stderr
        INPUT_FILE "/dev/null"
    )
    if(NOT run_result EQUAL 0 OR NOT program_output STREQUAL EXPECTED_OUTPUT)
        message(FATAL_ERROR
            "Package object program result was '${program_output}': ${run_stderr}")
    endif()
    return()
endif()
set(debug_arguments)
if(DEBUG_INFO)
    list(APPEND debug_arguments -g)
endif()
execute_process(
    COMMAND ${package_command} ${package_arguments} ${debug_arguments} "${SOURCE}" -o "${OUTPUT}" --emit-llvm "${IR_OUTPUT}"
    WORKING_DIRECTORY "${work_directory}"
    RESULT_VARIABLE compile_result
    OUTPUT_VARIABLE compile_stdout
    ERROR_VARIABLE compile_stderr
)
if(NOT compile_result EQUAL 0)
    message(FATAL_ERROR "Compilation failed (${compile_result}):\n${compile_stderr}")
endif()
if(DEFINED EXPECT_WARNING AND NOT compile_stderr MATCHES "${EXPECT_WARNING}")
    message(FATAL_ERROR "Expected compiler warning '${EXPECT_WARNING}', got:\n${compile_stderr}")
endif()
check_compile_output("${compile_stdout}${compile_stderr}")
if(NOT EXISTS "${IR_OUTPUT}")
    message(FATAL_ERROR "Compiler did not write requested LLVM IR: ${IR_OUTPUT}")
endif()
file(READ "${IR_OUTPUT}" ir_text)
if(NOT ir_text MATCHES "define i32 @main")
    message(FATAL_ERROR "Emitted LLVM IR does not define main")
endif()
if(DEBUG_INFO)
    if(NOT DEFINED DEBUG_LINE OR NOT DEFINED DEBUG_LOCAL)
        message(FATAL_ERROR "Debug-info cases must define DEBUG_LINE and DEBUG_LOCAL")
    endif()
    get_filename_component(debug_fixture_name "${SOURCE}" NAME)
    if(NOT ir_text MATCHES "!DICompileUnit")
        message(FATAL_ERROR "Generated LLVM IR contains no DWARF compile-unit metadata")
    endif()
    if(ir_text MATCHES "define private [^\n]*@cwhip.thunk.Number.root.")
        message(FATAL_ERROR "Unnecessary Number receiver thunk obscures source-level stepping")
    endif()

    find_program(OPT_EXECUTABLE NAMES opt-22 opt)
    if(NOT OPT_EXECUTABLE)
        message(FATAL_ERROR "The -g integration test requires LLVM opt to verify emitted IR")
    endif()
    execute_process(
        COMMAND "${OPT_EXECUTABLE}" -passes=verify -disable-output "${IR_OUTPUT}"
        RESULT_VARIABLE verify_result
        OUTPUT_VARIABLE verify_stdout
        ERROR_VARIABLE verify_stderr
    )
    if(NOT verify_result EQUAL 0)
        message(FATAL_ERROR "LLVM IR verification failed:\n${verify_stderr}")
    endif()

    find_program(DWARFDUMP_EXECUTABLE NAMES llvm-dwarfdump-22 llvm-dwarfdump)
    if(NOT DWARFDUMP_EXECUTABLE)
        message(FATAL_ERROR "The -g integration test requires llvm-dwarfdump")
    endif()
    execute_process(
        COMMAND "${DWARFDUMP_EXECUTABLE}" --debug-line "${OUTPUT}"
        RESULT_VARIABLE dwarfdump_result
        OUTPUT_VARIABLE dwarfdump_stdout
        ERROR_VARIABLE dwarfdump_stderr
    )
    string(FIND "${dwarfdump_stdout}" "${debug_fixture_name}" debug_line_file_position)
    if(NOT dwarfdump_result EQUAL 0 OR debug_line_file_position LESS 0)
        message(FATAL_ERROR
            "Executable has no DWARF line table for the Cwhip fixture:\n${dwarfdump_stdout}\n${dwarfdump_stderr}")
    endif()

    find_program(DEBUGGER_EXECUTABLE NAMES gdb lldb)
    if(NOT DEBUGGER_EXECUTABLE)
        message(STATUS "Skipping optional debugger breakpoint/local check: neither gdb nor lldb is installed")
    else()
        get_filename_component(debugger_name "${DEBUGGER_EXECUTABLE}" NAME)
        if(debugger_name MATCHES "^gdb")
            execute_process(
                COMMAND "${DEBUGGER_EXECUTABLE}" --batch --quiet --nx
                    -ex "set pagination off"
                    -ex "break ${SOURCE}:28"
                    -ex run
                    -ex next
                    -ex next
                    -ex bt
                    -ex next
                    "${OUTPUT}"
                RESULT_VARIABLE stepping_result
                OUTPUT_VARIABLE stepping_stdout
                ERROR_VARIABLE stepping_stderr
            )
            if(NOT stepping_result EQUAL 0 OR
               NOT stepping_stdout MATCHES "${debug_fixture_name}:37" OR
               NOT stepping_stdout MATCHES "38[\t ]+answer = answer \\+ 1" OR
               stepping_stdout MATCHES "in \\?\\?" OR
               stepping_stderr MATCHES "Cannot find bounds")
                message(FATAL_ERROR
                    "DWARF method return/next did not reach caller lines 37 and 38:\n${stepping_stdout}\n${stepping_stderr}")
            endif()
            execute_process(
                COMMAND "${DEBUGGER_EXECUTABLE}" --batch --quiet --nx
                    -ex "set pagination off"
                    -ex "break ${SOURCE}:${DEBUG_LINE}"
                    -ex run
                    -ex "info locals"
                    "${OUTPUT}"
                RESULT_VARIABLE debugger_result
                OUTPUT_VARIABLE debugger_stdout
                ERROR_VARIABLE debugger_stderr
            )
        else()
            execute_process(
                COMMAND "${DEBUGGER_EXECUTABLE}" --batch
                    -o "breakpoint set --file ${debug_fixture_name} --line ${DEBUG_LINE}"
                    -o run
                    -o "frame variable ${DEBUG_LOCAL}"
                    "${OUTPUT}"
                RESULT_VARIABLE debugger_result
                OUTPUT_VARIABLE debugger_stdout
                ERROR_VARIABLE debugger_stderr
            )
        endif()
        string(FIND "${debugger_stdout}" "${debug_fixture_name}" debugger_file_position)
        string(FIND "${debugger_stdout}" "${DEBUG_LOCAL}" debugger_local_position)
        string(FIND "${debugger_stdout}" "42" debugger_value_position)
        if(NOT debugger_result EQUAL 0 OR debugger_file_position LESS 0 OR
           debugger_local_position LESS 0 OR debugger_value_position LESS 0)
            message(FATAL_ERROR
                "${debugger_name} could not stop at the Cwhip source line and show its local:\n${debugger_stdout}\n${debugger_stderr}")
        endif()
    endif()
endif()
if(DEFINED REQUIRE_GC_ROOTS)
    foreach(required_gc_symbol IN ITEMS
            "@cwhip_gc_push_tagged_or_abort" "@cwhip_gc_pop_or_abort" "@cwhip_gc_alloc")
        if(NOT ir_text MATCHES "${required_gc_symbol}")
            message(FATAL_ERROR "Emitted LLVM IR is missing ${required_gc_symbol}")
        endif()
    endforeach()
    string(REGEX MATCHALL "call void @cwhip_gc_push_or_abort\\(" root_push_calls "${ir_text}")
    string(REGEX MATCHALL "call void @cwhip_gc_push_tagged_or_abort\\("
           tagged_root_push_calls "${ir_text}")
    string(REGEX MATCHALL "call void @cwhip_gc_pop_or_abort\\(" root_pop_calls "${ir_text}")
    list(LENGTH root_push_calls root_push_count)
    list(LENGTH tagged_root_push_calls tagged_root_push_count)
    list(LENGTH root_pop_calls root_pop_count)
    math(EXPR root_push_count "${root_push_count} + ${tagged_root_push_count}")
    # Generated exception raisers unwind their root frames rather than
    # returning through the normal pop path.
    string(REGEX MATCHALL "call void @cwhip_exception_raise_object\\("
           root_unwind_calls "${ir_text}")
    list(LENGTH root_unwind_calls root_unwind_count)
    math(EXPR expected_root_count "${root_pop_count} + ${root_unwind_count}")
    if(root_push_count EQUAL 0 OR NOT root_push_count EQUAL expected_root_count)
        message(FATAL_ERROR
            "Generated functions have unbalanced root-frame lifecycle (${root_push_count} pushes, ${root_pop_count} pops)")
    endif()
endif()
if(DEFINED REQUIRE_VIRTUAL_DISPATCH)
    if(NOT ir_text MATCHES "call i64 %t[0-9]+\\(")
        message(FATAL_ERROR "Generated IR does not call a method through a loaded dispatch slot")
    endif()
    if(NOT ir_text MATCHES "call i64 @cwhip.Grandchild.read\\(")
        message(FATAL_ERROR "Most-derived override is missing from generated dispatch thunks")
    endif()
endif()

set(run_arguments)
if(DEFINED RUN_ARGUMENTS)
    list(APPEND run_arguments ${RUN_ARGUMENTS})
endif()
set(stdin_arguments)
if(DEFINED STDIN_FILE)
    list(APPEND stdin_arguments INPUT_FILE "${STDIN_FILE}")
else()
    # execute_process() does not redirect stdin unless told to, so the
    # compiled program otherwise inherits ctest's own stdin. When ctest is
    # invoked from an interactive shell that is a real TTY, which makes
    # terminal-detection tests (isInteractive(), etc.) observe different,
    # non-deterministic results depending on how the test was launched.
    # Force a non-TTY stdin by default so results are deterministic.
    list(APPEND stdin_arguments INPUT_FILE "/dev/null")
endif()
execute_process(
    COMMAND "${OUTPUT}" ${run_arguments}
    RESULT_VARIABLE run_result
    OUTPUT_VARIABLE program_output
    ERROR_VARIABLE run_stderr
    ${stdin_arguments}
)
if(run_stderr MATCHES "AddressSanitizer|UndefinedBehaviorSanitizer|runtime error:")
    message(FATAL_ERROR "Program sanitizer failure:\n${run_stderr}")
endif()
if(DEFINED EXPECT_EXIT_CODE)
    if(NOT run_result EQUAL EXPECT_EXIT_CODE)
        message(FATAL_ERROR
            "Expected compiled program to exit ${EXPECT_EXIT_CODE}, got ${run_result}:\n${run_stderr}")
    endif()
    if(NOT program_output STREQUAL EXPECTED_OUTPUT)
        message(FATAL_ERROR
            "Expected output '${EXPECTED_OUTPUT}', got '${program_output}'")
    endif()
    return()
endif()
if(NOT run_result EQUAL 0)
    if(DEFINED EXPECT_RUNTIME_FAILURE)
        if(DEFINED EXPECT_RUNTIME_DIAGNOSTIC AND
           NOT run_stderr MATCHES "${EXPECT_RUNTIME_DIAGNOSTIC}")
            message(FATAL_ERROR
                "Expected runtime diagnostic '${EXPECT_RUNTIME_DIAGNOSTIC}', got:\n${run_stderr}")
        endif()
        if(DEFINED EXPECT_RUNTIME_FRAMES)
            string(REPLACE "|" ";" expected_frames "${EXPECT_RUNTIME_FRAMES}")
            set(previous_frame_position -1)
            foreach(expected_frame IN LISTS expected_frames)
                string(FIND "${run_stderr}" "${expected_frame}" frame_position)
                if(frame_position LESS 0 OR frame_position LESS_EQUAL previous_frame_position)
                    message(FATAL_ERROR
                        "Expected ordered runtime frame '${expected_frame}', got:\n${run_stderr}")
                endif()
                string(SUBSTRING "${run_stderr}" ${frame_position} -1 frame_tail)
                string(FIND "${frame_tail}" "\n" frame_line_end)
                if(frame_line_end LESS 0)
                    set(frame_line "${frame_tail}")
                else()
                    string(SUBSTRING "${frame_tail}" 0 ${frame_line_end} frame_line)
                endif()
                if(NOT frame_line MATCHES "\\([^)]*:[0-9]+:[0-9]+\\)$")
                    message(FATAL_ERROR
                        "Runtime frame '${expected_frame}' has no source location: ${frame_line}")
                endif()
                set(previous_frame_position "${frame_position}")
            endforeach()
        endif()
        if(NOT program_output STREQUAL EXPECTED_OUTPUT)
            message(FATAL_ERROR
                "Expected output '${EXPECTED_OUTPUT}' before runtime failure, got '${program_output}'")
        endif()
        return()
    endif()
    message(FATAL_ERROR "Compiled Cwhip program exited ${run_result}:\n${run_stderr}")
endif()
if(DEFINED EXPECT_RUNTIME_FAILURE)
    message(FATAL_ERROR "Expected compiled program to fail at runtime, but it exited successfully")
endif()
if(NOT program_output STREQUAL EXPECTED_OUTPUT)
    message(FATAL_ERROR "Expected output '${EXPECTED_OUTPUT}', got '${program_output}'")
endif()
if(DEFINED EXPECT_EMPTY_RUNTIME_STDERR AND NOT run_stderr STREQUAL "")
    message(FATAL_ERROR "Expected no runtime diagnostic on stderr, got:\n${run_stderr}")
endif()
if(DEFINED EXPECT_RUNTIME_STDERR_FILE)
    if(NOT EXISTS "${EXPECT_RUNTIME_STDERR_FILE}")
        message(FATAL_ERROR "Missing runtime stderr expectation: ${EXPECT_RUNTIME_STDERR_FILE}")
    endif()
    file(READ "${EXPECT_RUNTIME_STDERR_FILE}" expected_runtime_stderr)
    if(NOT run_stderr STREQUAL expected_runtime_stderr)
        message(FATAL_ERROR
            "Expected runtime stderr '${expected_runtime_stderr}', got '${run_stderr}'")
    endif()
endif()
