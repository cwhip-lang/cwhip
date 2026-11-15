cmake_minimum_required(VERSION 3.16)
project(cwhip VERSION 0.0.2 LANGUAGES C CXX)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/CwhipInstallPrefix.cmake")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

include(GNUInstallDirs)
include(cmake/Instrumentation.cmake)
option(CWHIP_REGISTER_SDK "Record the installed SDK and application defaults in sdk.toml" ON)

# Root builds stage a developer prefix in the source tree: <source>/bin/cwhip
# finds its runtime, headers, builtin, and standard modules in sibling
# directories with the same relative shape as an installed prefix.
set(CWHIP_STAGE_PREFIX "${CMAKE_SOURCE_DIR}" CACHE PATH "Developer resource staging prefix")
set(CWHIP_RUNTIME_OUTPUT_DIRECTORY "${CWHIP_STAGE_PREFIX}/bin")
set(CWHIP_LIBRARY_OUTPUT_DIRECTORY "${CWHIP_STAGE_PREFIX}/lib")

find_program(CWHIP_CLANG_EXECUTABLE NAMES clang)
if(NOT CWHIP_CLANG_EXECUTABLE)
    message(FATAL_ERROR "Clang is required to turn generated LLVM IR into an executable")
endif()
execute_process(
    COMMAND "${CWHIP_CLANG_EXECUTABLE}" -dumpmachine
    OUTPUT_VARIABLE CWHIP_TARGET_TRIPLE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE CWHIP_TARGET_TRIPLE_RESULT
)
if(NOT CWHIP_TARGET_TRIPLE_RESULT EQUAL 0 OR CWHIP_TARGET_TRIPLE STREQUAL "")
    message(FATAL_ERROR "Could not query the target triple from ${CWHIP_CLANG_EXECUTABLE}")
endif()

include(CTest)
add_subdirectory(include)
add_subdirectory(src)
if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

find_package(Doxygen QUIET)
if(DOXYGEN_FOUND)
    add_custom_target(docs
        COMMAND "${DOXYGEN_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/doc/doxygen.cfg"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/doc"
        COMMENT "Generating API documentation"
        DEPENDS site
        VERBATIM
    )
endif()

add_custom_target(site
    COMMAND "/usr/bin/python3" "build.py"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/doc/website"
    COMMENT "Generating web site"
    VERBATIM
)

# Rewrites Cwhip sources in place when cwhip-format is available.
add_custom_target(format
    COMMAND "${CMAKE_COMMAND}"
        "-DCWHIP_SOURCE_DIR=${CMAKE_SOURCE_DIR}"
        "-DCWHIP_BINARY_DIR=${CMAKE_BINARY_DIR}"
        "-DCWHIP_FORMAT_HINT=${CWHIP_RUNTIME_OUTPUT_DIRECTORY}"
        -P "${CMAKE_SOURCE_DIR}/cmake/FormatSources.cmake"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    COMMENT "Formatting Cwhip sources"
    VERBATIM
)

install(FILES README.md DESTINATION "${CMAKE_INSTALL_DOCDIR}")
file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/installed-docs/CWHIP-LANGUAGE-NOTES.md"
    CONTENT "# Cwhip language notes\n\nSee [the complete language notes](doc/CWHIP-LANGUAGE-NOTES.md).\n")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/installed-docs/CWHIP-LANGUAGE-NOTES.md"
    DESTINATION "${CMAKE_INSTALL_DOCDIR}")
install(DIRECTORY doc/ DESTINATION "${CMAKE_INSTALL_DOCDIR}/doc"
    FILES_MATCHING PATTERN "*.md")
install(FILES doc/cwhip.1 DESTINATION "${CMAKE_INSTALL_DOCDIR}/doc")
install(FILES tests/README.md DESTINATION "${CMAKE_INSTALL_DOCDIR}/tests")
install(FILES stdlib/README.md DESTINATION "${CMAKE_INSTALL_DOCDIR}/stdlib")
install(FILES doc/cwhip.1 DESTINATION "${CMAKE_INSTALL_MANDIR}/man1")

# Record the real install prefix (not DESTDIR-staged) separately from preferences.
if(CWHIP_REGISTER_SDK)
    get_property(cwhip_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(cwhip_multi_config)
        set(cwhip_install_build_type "\${CMAKE_INSTALL_CONFIG_NAME}")
    else()
        set(cwhip_install_build_type "${CMAKE_BUILD_TYPE}")
    endif()
    install(CODE "
        include(\"${CMAKE_SOURCE_DIR}/cmake/CwhipRegisterSdk.cmake\")
        cwhip_register_sdk(\"\${CMAKE_INSTALL_PREFIX}\" \"${cwhip_install_build_type}\")
    ")
endif()
