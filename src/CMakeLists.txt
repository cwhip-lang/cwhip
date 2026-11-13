cmake_minimum_required(VERSION 3.16)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    project(cwhip_compiler VERSION 0.0.2 LANGUAGES C CXX)
    include("${CMAKE_CURRENT_SOURCE_DIR}/../cmake/CwhipInstallPrefix.cmake")
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
    set(CMAKE_C_STANDARD 11)
    set(CMAKE_C_STANDARD_REQUIRED ON)
    set(CMAKE_C_EXTENSIONS OFF)
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
    add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../include"
                     "${CMAKE_CURRENT_BINARY_DIR}/include")
endif()

if(NOT DEFINED CWHIP_CLANG_EXECUTABLE OR NOT DEFINED CWHIP_TARGET_TRIPLE)
    message(FATAL_ERROR "cwhip requires its configured Clang target for native type validation")
endif()
set(CWHIP_NATIVE_TYPE_CHECK "${CMAKE_CURRENT_BINARY_DIR}/cwhip-native-type-check.c")
file(WRITE "${CWHIP_NATIVE_TYPE_CHECK}" [=[
#include <float.h>
#include <limits.h>
#if !defined(__SIZEOF_INT__) || __SIZEOF_INT__ != 4 || __INT_MAX__ != 2147483647
#error cwhip native int aliases require a 32-bit C int
#endif
#if !defined(__SIZEOF_FLOAT__) || __SIZEOF_FLOAT__ != 4 || \
    !defined(__FLT_RADIX__) || __FLT_RADIX__ != 2 || \
    !defined(__FLT_MANT_DIG__) || __FLT_MANT_DIG__ != 24 || \
    !defined(__FLT_MIN_EXP__) || __FLT_MIN_EXP__ != -125 || \
    !defined(__FLT_MAX_EXP__) || __FLT_MAX_EXP__ != 128 || \
    !defined(__FLT_HAS_DENORM__) || __FLT_HAS_DENORM__ != 1
#error cwhip native float alias requires IEEE-754 binary32
#endif
_Static_assert(INT_MIN == (-2147483647 - 1),
               "cwhip native int alias requires two's-complement int");
_Static_assert(sizeof(unsigned int) == 4 && UINT_MAX == 4294967295U,
               "cwhip native uint alias requires a 32-bit unsigned int");
_Static_assert(FLT_RADIX == 2 && FLT_MANT_DIG == 24 &&
                   FLT_MIN_EXP == -125 && FLT_MAX_EXP == 128,
               "cwhip native float alias requires IEEE-754 binary32");
]=])
execute_process(
    COMMAND "${CWHIP_CLANG_EXECUTABLE}" -target "${CWHIP_TARGET_TRIPLE}"
            -std=c11 -fsyntax-only "${CWHIP_NATIVE_TYPE_CHECK}"
    RESULT_VARIABLE CWHIP_NATIVE_TYPE_CHECK_RESULT
    OUTPUT_QUIET
    ERROR_VARIABLE CWHIP_NATIVE_TYPE_CHECK_ERROR
)
if(NOT CWHIP_NATIVE_TYPE_CHECK_RESULT EQUAL 0)
    message(FATAL_ERROR
        "cwhip native aliases require target ${CWHIP_TARGET_TRIPLE} to provide "
        "32-bit int/unsigned int and IEEE-754 binary32 float: "
        "${CWHIP_NATIVE_TYPE_CHECK_ERROR}")
endif()

include(GNUInstallDirs)
include("${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Instrumentation.cmake")
find_package(Python3 3.11 REQUIRED COMPONENTS Interpreter)

# The staged prefix mirrors the install layout so the compiler finds its
# resources relative to its own executable both in a build and after install.
if(NOT DEFINED CWHIP_STAGE_PREFIX)
    set(CWHIP_STAGE_PREFIX "${CMAKE_CURRENT_BINARY_DIR}")
endif()
if(NOT DEFINED CWHIP_RUNTIME_OUTPUT_DIRECTORY)
    set(CWHIP_RUNTIME_OUTPUT_DIRECTORY "${CWHIP_STAGE_PREFIX}/${CMAKE_INSTALL_BINDIR}")
endif()
if(NOT DEFINED CWHIP_LIBRARY_OUTPUT_DIRECTORY)
    set(CWHIP_LIBRARY_OUTPUT_DIRECTORY "${CWHIP_STAGE_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
endif()
if("${CWHIP_RUNTIME_OUTPUT_DIRECTORY};${CWHIP_LIBRARY_OUTPUT_DIRECTORY}" MATCHES "[ \t]")
    # GNU ld depfiles do not escape spaces; retain CMake's explicit link dependencies.
    set(CMAKE_LINK_DEPENDS_USE_LINKER FALSE)
endif()

# Resource locations are compiled in only as paths relative to the prefix.
foreach(cwhip_install_kind BINDIR LIBDIR INCLUDEDIR DATADIR)
    file(RELATIVE_PATH CWHIP_RELATIVE_${cwhip_install_kind}
         "${CMAKE_INSTALL_PREFIX}" "${CMAKE_INSTALL_FULL_${cwhip_install_kind}}")
    if(CWHIP_RELATIVE_${cwhip_install_kind} STREQUAL ""
       OR CWHIP_RELATIVE_${cwhip_install_kind} MATCHES "^\\.\\.(/|$)")
        message(FATAL_ERROR
            "CMAKE_INSTALL_${cwhip_install_kind} (${CMAKE_INSTALL_FULL_${cwhip_install_kind}}) "
            "must be inside CMAKE_INSTALL_PREFIX (${CMAKE_INSTALL_PREFIX}) for a "
            "relocatable cwhip installation")
    endif()
endforeach()
set(CWHIP_STAGE_RUNTIME_DIRECTORY "${CWHIP_STAGE_PREFIX}/${CWHIP_RELATIVE_LIBDIR}/cwhip")
set(CWHIP_STAGE_INCLUDE_DIRECTORY "${CWHIP_STAGE_PREFIX}/${CWHIP_RELATIVE_INCLUDEDIR}/cwhip")
set(CWHIP_STAGE_BUILTIN_DIRECTORY "${CWHIP_STAGE_PREFIX}/${CWHIP_RELATIVE_DATADIR}/cwhip/builtin")
set(CWHIP_STAGE_MODULE_DIRECTORY "${CWHIP_STAGE_PREFIX}/${CWHIP_RELATIVE_DATADIR}/cwhip/modules")
file(RELATIVE_PATH CWHIP_PKG_STDLIB_RELATIVE_PATH
    "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}" "${CWHIP_STAGE_MODULE_DIRECTORY}")
file(RELATIVE_PATH CWHIP_PKG_PREFIX_STDLIB_RELATIVE_PATH
    "${CMAKE_INSTALL_PREFIX}" "${CMAKE_INSTALL_FULL_DATADIR}/cwhip/modules")
file(MAKE_DIRECTORY "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}")
file(RELATIVE_PATH CWHIP_PKG_PREFIX_RELATIVE_PATH
    "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}" "${CWHIP_STAGE_PREFIX}")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/../tools/cwhip-pkg.py.in"
    "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}/cwhip-pkg"
    @ONLY
)
file(RELATIVE_PATH CWHIP_PKG_STDLIB_RELATIVE_PATH
    "${CMAKE_INSTALL_FULL_BINDIR}" "${CMAKE_INSTALL_FULL_DATADIR}/cwhip/modules")
file(RELATIVE_PATH CWHIP_PKG_PREFIX_RELATIVE_PATH
    "${CMAKE_INSTALL_FULL_BINDIR}" "${CMAKE_INSTALL_PREFIX}")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/../tools/cwhip-pkg.py.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cwhip-pkg-install"
    @ONLY
)
set(CWHIP_SOURCE_INCLUDE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../include/cwhip")
set(CWHIP_SOURCE_BUILTIN_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../builtin")
set(CWHIP_SOURCE_STDLIB_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../stdlib")
set(CWHIP_RUNTIME_HEADERS
    "${CWHIP_SOURCE_INCLUDE_DIRECTORY}/Callbacks.h"
    "${CWHIP_SOURCE_INCLUDE_DIRECTORY}/Stdlib.h"
    "${CWHIP_SOURCE_INCLUDE_DIRECTORY}/RuntimeDemoShims.h"
    "${CWHIP_SOURCE_INCLUDE_DIRECTORY}/RuntimeGc.h"
    "${CWHIP_SOURCE_INCLUDE_DIRECTORY}/RuntimeThreads.h"
)
set(CWHIP_BUILTIN_SOURCES "${CWHIP_SOURCE_BUILTIN_DIRECTORY}/String.cw")
file(GLOB_RECURSE CWHIP_STDLIB_SOURCES CONFIGURE_DEPENDS
    "${CWHIP_SOURCE_STDLIB_DIRECTORY}/*")

find_package(Threads REQUIRED)
find_package(SQLite3 REQUIRED)

include(CheckIncludeFile)
check_include_file(unistd.h CWHIP_HAVE_UNISTD_H)
if(NOT CWHIP_HAVE_UNISTD_H)
    message(FATAL_ERROR "cwhip requires a POSIX target with unistd.h (including inline C)")
endif()

add_library(cwhip_runtime STATIC RuntimeGc.c RuntimeStdlib.c RuntimeOS.c RuntimeProcess.c
    RuntimeProcessAsync.c
    RuntimeDemoShims.c RuntimeThreads.c)
target_link_libraries(cwhip_runtime PUBLIC cwhip_headers Threads::Threads)
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    # The standalone debugger reads runtime type layouts without runtime sources.
    target_compile_options(cwhip_runtime PRIVATE -g)
endif()
set_target_properties(cwhip_runtime PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CWHIP_STAGE_RUNTIME_DIRECTORY}"
    LIBRARY_OUTPUT_DIRECTORY "${CWHIP_STAGE_RUNTIME_DIRECTORY}"
)

set(cwhip_stage_commands
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CWHIP_STAGE_BUILTIN_DIRECTORY}"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different ${CWHIP_BUILTIN_SOURCES}
            "${CWHIP_STAGE_BUILTIN_DIRECTORY}/"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CWHIP_STAGE_MODULE_DIRECTORY}"
    COMMAND "${CMAKE_COMMAND}" -E copy_directory "${CWHIP_SOURCE_STDLIB_DIRECTORY}"
            "${CWHIP_STAGE_MODULE_DIRECTORY}"
)
get_filename_component(cwhip_source_include_real "${CWHIP_SOURCE_INCLUDE_DIRECTORY}" REALPATH)
get_filename_component(cwhip_stage_include_real "${CWHIP_STAGE_INCLUDE_DIRECTORY}" REALPATH)
if(NOT cwhip_source_include_real STREQUAL cwhip_stage_include_real)
    list(APPEND cwhip_stage_commands
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CWHIP_STAGE_INCLUDE_DIRECTORY}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different ${CWHIP_RUNTIME_HEADERS}
                "${CWHIP_STAGE_INCLUDE_DIRECTORY}/")
endif()
set(CWHIP_SQLITE_PACKAGE_LIBRARY_DIRECTORY
    "${CWHIP_STAGE_MODULE_DIRECTORY}/sqlite/0.1.0/lib")
file(MAKE_DIRECTORY "${CWHIP_SQLITE_PACKAGE_LIBRARY_DIRECTORY}")
add_library(cwhip_sqlite_native STATIC
    "${CWHIP_SOURCE_STDLIB_DIRECTORY}/sqlite/0.1.0/native/sqlite.c")
target_link_libraries(cwhip_sqlite_native PRIVATE cwhip_headers SQLite::SQLite3)
set_target_properties(cwhip_sqlite_native PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CWHIP_SQLITE_PACKAGE_LIBRARY_DIRECTORY}"
    OUTPUT_NAME cwhip_sqlite
)
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
    pkg_check_modules(GTK4 QUIET IMPORTED_TARGET "gtk4>=4.10")
    pkg_check_modules(GTK_SOURCEVIEW QUIET IMPORTED_TARGET gtksourceview-5)
endif()
option(CWHIP_GTK "Build the GTK 4 interface package (default: detect installed dependencies)" ${GTK4_FOUND})
set(cwhip_sourceview_default OFF)
if(CWHIP_GTK AND GTK_SOURCEVIEW_FOUND)
    set(cwhip_sourceview_default ON)
endif()
option(CWHIP_GTK_SOURCEVIEW "Build the GtkSourceView editor package (default: detect installed dependencies)" ${cwhip_sourceview_default})
if(CWHIP_GTK_SOURCEVIEW AND NOT CWHIP_GTK)
    message(FATAL_ERROR "CWHIP_GTK_SOURCEVIEW requires CWHIP_GTK=ON")
endif()
if(CWHIP_GTK)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(GTK4 REQUIRED IMPORTED_TARGET "gtk4>=4.10")
    add_library(cwhip_gtk_native STATIC
        "${CWHIP_SOURCE_STDLIB_DIRECTORY}/gtk/0.1.0/native/gtk.c"
        "${CWHIP_SOURCE_STDLIB_DIRECTORY}/gtk/0.1.0/native/toml.c")
    target_link_libraries(cwhip_gtk_native PRIVATE cwhip_headers PkgConfig::GTK4 Threads::Threads)
    if(CWHIP_GTK_SOURCEVIEW)
        pkg_check_modules(GTK_SOURCEVIEW REQUIRED IMPORTED_TARGET gtksourceview-5)
        target_link_libraries(cwhip_gtk_native PRIVATE PkgConfig::GTK_SOURCEVIEW)
        target_compile_definitions(cwhip_gtk_native PRIVATE CWHIP_GTK_SOURCEVIEW=1)
        set(CWHIP_GTK_SOURCEVIEW_MANIFEST
            "${CMAKE_CURRENT_BINARY_DIR}/gtk-sourceview-cwhip-package.toml")
        configure_file(
            "${CWHIP_SOURCE_STDLIB_DIRECTORY}/gtk/0.1.0/cwhip-package-sourceview.toml.in"
            "${CWHIP_GTK_SOURCEVIEW_MANIFEST}" @ONLY)
        list(APPEND cwhip_stage_commands
            COMMAND "${CMAKE_COMMAND}" -E copy_if_different
                "${CWHIP_GTK_SOURCEVIEW_MANIFEST}"
                "${CWHIP_STAGE_MODULE_DIRECTORY}/gtk/0.1.0/cwhip-package.toml")
    else()
        list(APPEND cwhip_stage_commands
            COMMAND "${CMAKE_COMMAND}" -E remove_directory
                "${CWHIP_STAGE_MODULE_DIRECTORY}/sourceview")
    endif()
    target_compile_options(cwhip_gtk_native PRIVATE -Wall -Wextra -Wpedantic)
    set_target_properties(cwhip_gtk_native PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CWHIP_STAGE_MODULE_DIRECTORY}/gtk/0.1.0/lib"
        OUTPUT_NAME cwhip_gtk)
    message(STATUS "GTK 4 interface enabled; GTK links only into importing applications")
    if(CWHIP_GTK_SOURCEVIEW)
        message(STATUS "GtkSourceView editor package enabled")
    endif()
else()
    # Do not advertise an unusable source-only package in a non-GTK prefix.
    list(APPEND cwhip_stage_commands
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${CWHIP_STAGE_MODULE_DIRECTORY}/gtk")
    list(APPEND cwhip_stage_commands
        COMMAND "${CMAKE_COMMAND}" -E remove_directory
            "${CWHIP_STAGE_MODULE_DIRECTORY}/sourceview")
    message(STATUS "GTK 4 interface disabled (enable with -DCWHIP_GTK=ON)")
endif()

set(cwhip_stage_outputs "${CWHIP_STAGE_BUILTIN_DIRECTORY}/String.cw")
if(NOT cwhip_source_include_real STREQUAL cwhip_stage_include_real)
    foreach(header IN LISTS CWHIP_RUNTIME_HEADERS)
        get_filename_component(name "${header}" NAME)
        list(APPEND cwhip_stage_outputs "${CWHIP_STAGE_INCLUDE_DIRECTORY}/${name}")
    endforeach()
endif()
foreach(source IN LISTS CWHIP_STDLIB_SOURCES)
    file(RELATIVE_PATH relative "${CWHIP_SOURCE_STDLIB_DIRECTORY}" "${source}")
    if((NOT CWHIP_GTK AND relative MATCHES "^gtk/")
       OR (NOT CWHIP_GTK_SOURCEVIEW AND relative MATCHES "^sourceview/"))
        continue()
    endif()
    list(APPEND cwhip_stage_outputs "${CWHIP_STAGE_MODULE_DIRECTORY}/${relative}")
endforeach()
set(CWHIP_RESOURCE_STAMP "${CMAKE_CURRENT_BINARY_DIR}/cwhip-resources.stamp")
file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/cwhip-resource-options.txt"
    CONTENT "GTK=${CWHIP_GTK}\nSOURCEVIEW=${CWHIP_GTK_SOURCEVIEW}\n")
add_custom_command(
    OUTPUT "${CWHIP_RESOURCE_STAMP}" ${cwhip_stage_outputs}
    ${cwhip_stage_commands}
    COMMAND "${CMAKE_COMMAND}" -E touch "${CWHIP_RESOURCE_STAMP}"
    DEPENDS ${CWHIP_BUILTIN_SOURCES} ${CWHIP_RUNTIME_HEADERS} ${CWHIP_STDLIB_SOURCES}
        ${CWHIP_GTK_SOURCEVIEW_MANIFEST}
        "${CMAKE_CURRENT_LIST_FILE}" "${CMAKE_CURRENT_BINARY_DIR}/cwhip-resource-options.txt"
    COMMENT "Staging cwhip builtin, runtime headers, and module directories"
    VERBATIM)
add_custom_target(cwhip_resources ALL DEPENDS "${CWHIP_RESOURCE_STAMP}" ${cwhip_stage_outputs})
add_dependencies(cwhip_resources cwhip_sqlite_native)
if(CWHIP_GTK)
    add_dependencies(cwhip_resources cwhip_gtk_native)
endif()

add_library(cwhip_frontend
    Ast.cpp
    CommandLine.cpp
    CodeGenerator.cpp
    CodeGeneratorNumeric.cpp
    CodeGeneratorCallbacks.cpp
    CodeGeneratorDebug.cpp
    CodeGeneratorDispatch.cpp
    CodeGeneratorExceptions.cpp
    CodeGeneratorLayout.cpp
    CodeGeneratorModule.cpp
    CodeGeneratorPrint.cpp
    CodeGeneratorStatements.cpp
    Diagnostic.cpp
    Lexer.cpp
    ModuleRegistry.cpp
    PackageIntegrity.cpp
    PackageRegistry.cpp
    Parser.cpp
    ParserClass.cpp
    PathResolution.cpp
    SemanticAnalyzer.cpp
    SemanticInheritance.cpp
    SemanticExpressions.cpp
    SemanticStatements.cpp
    SourceLoader.cpp
    SourceCheck.cpp
)
target_link_libraries(cwhip_frontend PUBLIC cwhip_headers)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(cwhip_frontend PRIVATE -ffp-contract=off)
endif()
if(CWHIP_FUZZ)
    target_compile_options(cwhip_frontend PRIVATE -fsanitize=fuzzer-no-link)
endif()
target_compile_definitions(cwhip_frontend PRIVATE
    CWHIP_INSTALL_BINDIR="${CWHIP_RELATIVE_BINDIR}"
    CWHIP_INSTALL_LIBDIR="${CWHIP_RELATIVE_LIBDIR}"
    CWHIP_INSTALL_INCLUDEDIR="${CWHIP_RELATIVE_INCLUDEDIR}"
    CWHIP_INSTALL_DATADIR="${CWHIP_RELATIVE_DATADIR}"
    CWHIP_RUNTIME_LIBRARY_NAME="$<TARGET_FILE_NAME:cwhip_runtime>"
)
add_dependencies(cwhip_frontend cwhip_resources cwhip_runtime)
set_target_properties(cwhip_frontend PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CWHIP_LIBRARY_OUTPUT_DIRECTORY}"
    LIBRARY_OUTPUT_DIRECTORY "${CWHIP_LIBRARY_OUTPUT_DIRECTORY}"
)

add_executable(cwhip main.cpp)
target_link_libraries(cwhip PRIVATE cwhip_frontend)
add_executable(cwhip-lsp LspServer.cpp)
target_link_libraries(cwhip-lsp PRIVATE cwhip_frontend)
target_compile_definitions(cwhip PRIVATE
    CWHIP_VERSION="${PROJECT_VERSION}"
    CWHIP_CLANG_EXECUTABLE="${CWHIP_CLANG_EXECUTABLE}"
    CWHIP_TARGET_TRIPLE="${CWHIP_TARGET_TRIPLE}"
    CWHIP_SANITIZER_LIST="${CWHIP_SANITIZER_LIST}"
    CWHIP_COVERAGE=$<BOOL:${CWHIP_COVERAGE}>
)
add_dependencies(cwhip cwhip_runtime)
set_target_properties(cwhip PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}"
)
set_target_properties(cwhip-lsp PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}"
)
add_library(cwhip_format STATIC
    format/FormatLexer.cpp
    format/UnwrappedLine.cpp
    format/Style.cpp
    format/Printer.cpp
    format/Format.cpp)
target_link_libraries(cwhip_format PUBLIC cwhip_frontend cwhip_runtime)
target_compile_definitions(cwhip_format PRIVATE CWHIP_VERSION="${PROJECT_VERSION}")
set_target_properties(cwhip_format PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CWHIP_LIBRARY_OUTPUT_DIRECTORY}"
)

# The driver is a Cwhip program. cwhip rejects a static archive, so the link
# line passes the format objects plus the frontend objects they call.
add_custom_command(
    OUTPUT "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}/cwhip-format"
    COMMAND $<TARGET_FILE:cwhip>
            "${CMAKE_CURRENT_SOURCE_DIR}/../tools/cwhip-format.cw"
            $<TARGET_OBJECTS:cwhip_format>
            $<TARGET_OBJECTS:cwhip_frontend>
            -l stdc++
            -o "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}/cwhip-format"
    DEPENDS cwhip cwhip_format cwhip_frontend cwhip_resources
            "${CMAKE_CURRENT_SOURCE_DIR}/../tools/cwhip-format.cw"
    COMMENT "Building cwhip-format"
    COMMAND_EXPAND_LISTS
    VERBATIM)
add_custom_target(cwhip-format ALL
    DEPENDS "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}/cwhip-format")

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(cwhip_frontend PRIVATE -Wall -Wextra -Wpedantic)
    target_compile_options(cwhip PRIVATE -Wall -Wextra -Wpedantic)
    target_compile_options(cwhip-lsp PRIVATE -Wall -Wextra -Wpedantic)
    target_compile_options(cwhip_runtime PRIVATE -Wall -Wextra -Wpedantic)
    target_compile_options(cwhip_format PRIVATE -Wall -Wextra -Wpedantic)
endif()

install(TARGETS cwhip cwhip-lsp RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(PROGRAMS "${CWHIP_RUNTIME_OUTPUT_DIRECTORY}/cwhip-format"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")
install(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/cwhip-pkg-install"
    DESTINATION "${CMAKE_INSTALL_BINDIR}" RENAME cwhip-pkg)
install(TARGETS cwhip_runtime
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}/cwhip"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/cwhip"
)
install(FILES ${CWHIP_RUNTIME_HEADERS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/cwhip")
install(FILES ${CWHIP_BUILTIN_SOURCES} DESTINATION "${CMAKE_INSTALL_DATADIR}/cwhip/builtin")
install(DIRECTORY "${CWHIP_STAGE_MODULE_DIRECTORY}/"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/cwhip/modules")

# Packages installed into this prefix by other projects are not replaced by an
# SDK install; report any left over for another SDK ABI (or, with
# CWHIP_QUARANTINE_INCOMPATIBLE_PACKAGES=1 at install time, move them to a backup).
file(STRINGS "${CWHIP_SOURCE_INCLUDE_DIRECTORY}/Stdlib.h" cwhip_sdk_abi_define
    REGEX "^#define CWHIP_SDK_ABI \"[^\"]+\"$")
string(REGEX REPLACE "^#define CWHIP_SDK_ABI \"([^\"]+)\"$" "\\1"
    CWHIP_SDK_ABI "${cwhip_sdk_abi_define}")
if(NOT CWHIP_SDK_ABI MATCHES "^[A-Za-z0-9.-]+$")
    message(FATAL_ERROR "Cannot read CWHIP_SDK_ABI from ${CWHIP_SOURCE_INCLUDE_DIRECTORY}/Stdlib.h")
endif()
install(CODE "
    set(cwhip_installed_data \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${CWHIP_RELATIVE_DATADIR}/cwhip\")
    execute_process(COMMAND \"${Python3_EXECUTABLE}\"
            \"${CMAKE_CURRENT_SOURCE_DIR}/../tools/cwhip-install-package-check.py\"
            --modules-dir \"\${cwhip_installed_data}/modules\"
            --owned-dir \"${CWHIP_STAGE_MODULE_DIRECTORY}\"
            --backup-dir \"\${cwhip_installed_data}/package-backups\"
            --sdk-abi \"${CWHIP_SDK_ABI}\"
        RESULT_VARIABLE cwhip_package_check_result)
    if(NOT cwhip_package_check_result EQUAL 0)
        message(FATAL_ERROR \"Installed package check failed; see the cwhip-install error above\")
    endif()
")

include(CMakePackageConfigHelpers)
set(CWHIP_SDK_CMAKE_DIRECTORY "${CMAKE_INSTALL_LIBDIR}/cmake/Cwhip")
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/CwhipConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/CwhipConfig.cmake"
    INSTALL_DESTINATION "${CWHIP_SDK_CMAKE_DIRECTORY}"
    PATH_VARS CMAKE_INSTALL_BINDIR CMAKE_INSTALL_LIBDIR
        CMAKE_INSTALL_INCLUDEDIR CMAKE_INSTALL_DATADIR)
write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/CwhipConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}" COMPATIBILITY ExactVersion)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/CwhipConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/CwhipConfigVersion.cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/CwhipApplication.cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/CwhipApplicationDefaults.cmake"
    "${CMAKE_CURRENT_SOURCE_DIR}/../cmake/CwhipStageSources.cmake"
    DESTINATION "${CWHIP_SDK_CMAKE_DIRECTORY}")
