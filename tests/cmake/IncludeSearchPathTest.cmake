if(NOT DEFINED COMPILER OR NOT DEFINED WORK_DIR OR NOT DEFINED FIXTURES OR
   NOT DEFINED CASE)
    message(FATAL_ERROR "COMPILER, WORK_DIR, FIXTURES, and CASE are required")
endif()

set(work "${WORK_DIR}/include search path tests/${CASE}")
set(source_directory "${work}/source")
set(first_search_directory "${work}/first search directory")
set(second_search_directory "${work}/second search directory")
# Start from an empty directory so artifacts from earlier runs cannot leak in.
file(REMOVE_RECURSE "${work}")
file(MAKE_DIRECTORY "${source_directory}" "${first_search_directory}" "${second_search_directory}")

set(search_source "${source_directory}/search.cw")
configure_file("${FIXTURES}/search.cw" "${search_source}" COPYONLY)
configure_file("${FIXTURES}/first/search_target.cw"
    "${first_search_directory}/search_target.cw" COPYONLY)
configure_file("${FIXTURES}/second/search_target.cw"
    "${second_search_directory}/search_target.cw" COPYONLY)
configure_file("${FIXTURES}/second/nested_value.cw"
    "${second_search_directory}/nested_value.cw" COPYONLY)

if(CASE STREQUAL "missing")
execute_process(
    COMMAND "${COMPILER}" "${search_source}" --check-only
    RESULT_VARIABLE result
    OUTPUT_VARIABLE stdout
    ERROR_VARIABLE stderr
)
if(result EQUAL 0)
    message(FATAL_ERROR "Compilation without an include search path unexpectedly succeeded")
endif()
if(NOT stdout STREQUAL "")
    message(FATAL_ERROR "Missing-path compilation wrote unexpected stdout: '${stdout}'")
endif()
if(NOT stderr MATCHES
   "^cwhip: error\\[CWHIP1001\\]: source compilation failed\n.*search\\.cw:12:9: error: cannot resolve included source 'search_target\\.cw'\n$")
    message(FATAL_ERROR "Missing-path compilation wrote an unexpected diagnostic:\n${stderr}")
endif()
elseif(CASE STREQUAL "ordered")
set(search_executable "${work}/search executable")
execute_process(
    COMMAND "${COMPILER}"
        -p "${first_search_directory}"
        --path "${second_search_directory}"
        "${search_source}"
        -o "${search_executable}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE stdout
    ERROR_VARIABLE stderr
)
set(expected_stdout "cwhip: built ${search_executable}\n")
if(NOT result EQUAL 0 OR NOT stdout STREQUAL expected_stdout OR NOT stderr STREQUAL "")
    message(FATAL_ERROR
        "Compilation with ordered include search paths failed "
        "(result ${result}, stdout '${stdout}'):\n${stderr}")
endif()
execute_process(
    COMMAND "${search_executable}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE stdout
    ERROR_VARIABLE stderr
)
if(NOT result EQUAL 0 OR NOT stdout STREQUAL "42" OR NOT stderr STREQUAL "")
    message(FATAL_ERROR
        "Search-path program result was unexpected "
        "(result ${result}, stdout '${stdout}', stderr '${stderr}')")
endif()
elseif(CASE STREQUAL "relative")
set(relative_source_directory "${work}/relative source")
file(MAKE_DIRECTORY "${relative_source_directory}")
set(relative_source "${relative_source_directory}/relative.cw")
configure_file("${FIXTURES}/relative/relative.cw" "${relative_source}" COPYONLY)
configure_file("${FIXTURES}/relative/search_target.cw"
    "${relative_source_directory}/search_target.cw" COPYONLY)

set(relative_executable "${work}/relative executable")
execute_process(
    COMMAND "${COMPILER}"
        --path "${second_search_directory}"
        "${relative_source}"
        -o "${relative_executable}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE stdout
    ERROR_VARIABLE stderr
)
set(expected_stdout "cwhip: built ${relative_executable}\n")
if(NOT result EQUAL 0 OR NOT stdout STREQUAL expected_stdout OR NOT stderr STREQUAL "")
    message(FATAL_ERROR
        "Compilation for includer-relative precedence failed "
        "(result ${result}, stdout '${stdout}'):\n${stderr}")
endif()
execute_process(
    COMMAND "${relative_executable}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE stdout
    ERROR_VARIABLE stderr
)
if(NOT result EQUAL 0 OR NOT stdout STREQUAL "7" OR NOT stderr STREQUAL "")
    message(FATAL_ERROR
        "Includer-relative precedence result was unexpected "
        "(result ${result}, stdout '${stdout}', stderr '${stderr}')")
endif()
else()
    message(FATAL_ERROR "Unknown include search path case: ${CASE}")
endif()
