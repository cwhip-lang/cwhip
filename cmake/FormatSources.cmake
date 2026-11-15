# Body of the format target. Fails when cwhip-format is not available.
# cwhip-format reads .cwhip-format from the working directory, which is the
# source root. The build directory is not formatted.

if(NOT CWHIP_SOURCE_DIR)
    message(FATAL_ERROR "cwhip-format requires CWHIP_SOURCE_DIR")
endif()
get_filename_component(CWHIP_SOURCE_DIR "${CWHIP_SOURCE_DIR}" ABSOLUTE)

set(cwhip_format_hints)
if(CWHIP_FORMAT_HINT)
    list(APPEND cwhip_format_hints HINTS "${CWHIP_FORMAT_HINT}")
endif()
find_program(CWHIP_FORMAT_EXECUTABLE NAMES cwhip-format ${cwhip_format_hints})
if(NOT CWHIP_FORMAT_EXECUTABLE)
    message(FATAL_ERROR "cwhip-format is not available")
endif()

set(cwhip_format_binary_relative "")
if(CWHIP_BINARY_DIR)
    get_filename_component(CWHIP_BINARY_DIR "${CWHIP_BINARY_DIR}" ABSOLUTE)
    file(RELATIVE_PATH cwhip_format_binary_relative
        "${CWHIP_SOURCE_DIR}" "${CWHIP_BINARY_DIR}")
    if(cwhip_format_binary_relative STREQUAL ""
       OR cwhip_format_binary_relative MATCHES "^\\.\\.")
        set(cwhip_format_binary_relative "")
    endif()
endif()

set(cwhip_format_roots builtin stdlib tools examples tests)
set(cwhip_format_inputs)
foreach(root IN LISTS cwhip_format_roots)
    file(GLOB_RECURSE cwhip_format_found LIST_DIRECTORIES false
        "${CWHIP_SOURCE_DIR}/${root}/*.cw")
    foreach(path IN LISTS cwhip_format_found)
        file(RELATIVE_PATH relative "${CWHIP_SOURCE_DIR}" "${path}")
        if(relative MATCHES "(^|/)build(/|$)")
            continue()
        endif()
        if(NOT cwhip_format_binary_relative STREQUAL "")
            if(relative STREQUAL cwhip_format_binary_relative)
                continue()
            endif()
            string(LENGTH "${cwhip_format_binary_relative}" prefix_length)
            string(LENGTH "${relative}" relative_length)
            if(relative_length GREATER prefix_length)
                string(SUBSTRING "${relative}" 0 "${prefix_length}" prefix)
                string(SUBSTRING "${relative}" "${prefix_length}" 1 separator)
                if(prefix STREQUAL cwhip_format_binary_relative AND separator STREQUAL "/")
                    continue()
                endif()
            endif()
        endif()
        list(APPEND cwhip_format_inputs "${path}")
    endforeach()
endforeach()

if(NOT cwhip_format_inputs)
    message(FATAL_ERROR "cwhip-format found no Cwhip sources to format")
endif()
list(SORT cwhip_format_inputs)

execute_process(
    COMMAND "${CWHIP_FORMAT_EXECUTABLE}" -i ${cwhip_format_inputs}
    WORKING_DIRECTORY "${CWHIP_SOURCE_DIR}"
    RESULT_VARIABLE cwhip_format_status)
if(NOT cwhip_format_status EQUAL 0)
    message(FATAL_ERROR "cwhip-format failed with status ${cwhip_format_status}")
endif()
