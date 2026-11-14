#!/usr/bin/env python3
"""Exercise the staged or installed numeric-v2 SDK without user configuration."""
import argparse
import os
from pathlib import Path
import shutil
import shlex
import subprocess
import tempfile


def run(command, *, env, cwd, failure=None):
    result = subprocess.run(command, env=env, cwd=cwd, text=True, capture_output=True,
                            timeout=120)
    if failure is not None:
        assert result.returncode and failure in result.stderr, (
            command, result.stdout, result.stderr)
    elif result.returncode:
        raise AssertionError(f"{command}\n{result.stdout}\n{result.stderr}")
    return result


def exercise(sdk, clang, work, require_installed):
    compiler, package_tool = sdk / "bin/cwhip", sdk / "bin/cwhip-pkg"
    env = {key: value for key, value in os.environ.items()
           if not key.startswith(("CWHIP_", "XDG_")) and key != "DESTDIR"}
    env.update(HOME=str(work / "home"), XDG_CONFIG_HOME=str(work / "xdg"),
               XDG_DATA_HOME=str(work / "data"), XDG_CACHE_HOME=str(work / "cache"),
               XDG_STATE_HOME=str(work / "state"), CC=clang)
    for name in ("home", "xdg", "data", "cache", "state"):
        (work / name).mkdir()

    def execute(command, **kwargs):
        return run([str(part) for part in command], env=env, cwd=work, **kwargs)

    execute([package_tool, "init", work])
    checks = []

    def check(expression):
        checks.append(f'print("{{}}\\n", {expression})')

    parsers = {}
    for width in (8, 16, 32, 64):
        for signed in (True, False):
            typ = ("int" if signed else "uint") + str(width)
            method = ("toInt" if signed else "toUint") + str(width)
            minimum = -(1 << (width - 1)) if signed else 0
            maximum = (1 << (width - (1 if signed else 0))) - 1
            parsers[method] = (minimum, maximum)
            suffix = "" if signed else "u"
            for value in (minimum, maximum):
                check(f'"{value}".{method}() == {typ}({value}{suffix})')
            check(f'type(["1".{method}()][0]) == {typ}')
            check(f'"+0".{method}() == {typ}(0)')
            check(f'format("{{}}", {typ}({maximum}{suffix})).equals("{maximum}")')
            check(f'format("{{:04x}}", {typ}(15)).equals("000f")')
    for typ, method, subnormal in (("fp32", "toFp32", "1.401298464324817e-45"),
                                    ("fp64", "toFp64", "5e-324")):
        suffix = "" if typ == "fp32" else "f64"
        check(f'"0.1".{method}() == 0.1{suffix}')
        check(f'type(["1.5".{method}()][0]) == {typ}')
        check(f'"{subnormal}".{method}() > {typ}(0)')
        check(f'(1.0{suffix} / "-0".{method}()) < {typ}(0)')
        check(f'format("{{}}", "1.5".{method}()).equals("1.5")')
        check(f'"+.5e1".{method}() == {typ}(5)')
    # strtof must not first round a halfway-adjacent decimal through double.
    check('"1.0000000596046447753906250000000000001".toFp32() > fp32(1)')
    check('type(buffer[255][0]) == uint8')
    check('buffer[257][0] == uint8(1)')
    check('buffer[-1][0] == uint8(255)')
    check('type("abc".length) == int64')
    failures = []
    for method, (minimum, maximum) in parsers.items():
        for value in (minimum - 1, maximum + 1):
            failures.append(f'"{value}".{method}()')
        for text in ("", " 1", "1 ", "1x", "1.0", "+"):
            failures.append(f'"{text}".{method}()')
        if method.startswith("toUint"):
            failures.append(f'"-0".{method}()')
    for method in ("toFp32", "toFp64"):
        for text in ("", " 1", "1 ", "0x1p0", "nan", "inf", "1e", "1e400", "1e-400"):
            failures.append(f'"{text}".{method}()')
    source = work / "parsers.cw"
    source.write_text("start {\n" + "\n".join(checks) + "\n" + "\n".join(
        f'try {{ print({expression}) }} except () {{ print("caught\\n") }}'
        for expression in failures) + "\n}\n")
    binary = work / "parsers"
    execute([compiler, source, "-o", binary])
    result = execute([binary])
    parser_output = "true\n" * len(checks) + "caught\n" * len(failures)
    assert result.stdout == parser_output, result
    for removed in ("toInt", "toUnsigned", "toFloat"):
        old_source = work / "old-api.cw"
        old_source.write_text(f'start {{ print("1".{removed}()) }}\n')
        execute([compiler, old_source, "--check-only"], failure=removed)

    modules = sdk / "share/cwhip/modules"
    gui = (modules / "sourceview").is_dir()
    standard = work / "standard.cw"
    standard.write_text("""
import math as Math
import system as Sys
import time as Time
import terminal as Term
import random as Random
import synchronization as Sync
import process as Proc
import networking as Net
import sql as SQL
import sqlite as SQLite
""" + ("import gtk as Gtk\nimport sourceview as Source\n" if gui else "") + """
start {
    print("{}\\n", Math.Math().pi() == 3.141592653589793f64)
    print("{}\\n", Math.Math().absInt(int64(-9223372036854775807)) == 9223372036854775807)
    print("{}\\n", Math.Math().sqrt(4.0f64) == 2.0f64)
    print("{}\\n", type(Sys.System().argc()) == int64)
    print("{}\\n", type(Time.Clock().epochMilliseconds()) == uint64)
    print("{}\\n", type(Term.Terminal().columns()) == int64)
    print("{}\\n", Random.SecureRandom().bytes(256).length == 256)
    Sync.Semaphore semaphore = Sync.Semaphore(256)
    semaphore.wait()
    semaphore.signal()
    semaphore.close()
    Proc.Process child = Proc.Process("/bin/sh", ["-c", "exit 23"])
    print("{}\\n", child.wait() && child.exitCode() == 23)
    child.close()
    SQLite.Connection db = SQLite.Connection(":memory:")
    SQL.Statement statement = db.prepare("select ?, ?")
    print("{}\\n", statement.bind(1, SQL.Value(int64(9223372036854775807))))
    print("{}\\n", statement.bind(2, SQL.Value(0.1f64)))
    print("{}\\n", statement.step())
    print("{}\\n", statement.value(0).asInteger() == 9223372036854775807)
    print("{}\\n", statement.value(1).asReal() == 0.1f64)
    statement.close()
    db.close()
}
""")
    execute([compiler, standard, "-o", work / "standard"])
    result = execute([work / "standard"])
    assert result.stdout == "true\n" * 13, result
    if gui:
        shutil.copytree(modules / "sourceview/0.1.0/language-specs",
                        work / "share/cwhip/modules/sourceview/0.1.0/language-specs")
        scan_directory = work / "gui-scan"
        scan_directory.mkdir()
        for index in range(300):
            (scan_directory / str(index)).touch()
        gtk_flags = shlex.split(execute(["pkg-config", "--cflags", "gtk4"]).stdout)
        execute([clang, *gtk_flags, "-c", Path(__file__).with_name("numeric_sdk_gui_fixture.c"),
                 "-o", work / "gui-fixture.o"])
        gui_source = work / "gui.cw"
        gui_source.write_text("""
import gtk as Gtk
import sourceview as Source
class Native { public: int64 emit() }
int64 Native.emit() from "numeric_gui_emit"
class Probe {
    public:
    Gtk.Application app
    Probe self
    Gtk.Window window
    Gtk.Tree tree
    Source.View view
    Gtk.DirectoryScan scan
    int64 changes
    int64 requested
    int64 activated
    int64 line
    int64 scannedCount
    void changed() { changes += 1 }
    void request(int64 id) { requested = id }
    void activateRow(int64 id) { activated = id }
    void activateLine(int64 number) { line = number }
    void scanned(int64 count, String error) {
        if (count >= 0) { scannedCount += count }
        else {
            print("{}\\n", scannedCount == 300 && count == -1 && error.equals(""))
            view.widget().dispose()
            tree.dispose()
            window.dispose()
            app.quit()
        }
    }
    void activate() {
        view = Source.View()
        print("{}\\n", view.setLanguage("cwhip"))
        int64 token = view.onChanged(self.changed)
        int64 lineToken = view.onLineActivated(self.activateLine)
        view.setText("first\\nsecond\\n")
        view.setCursor(2, 4)
        print("{}\\n", type(token) == int64 && token > 0)
        print("{}\\n", view.line() == 2 && view.column() == 4)
        print("{}\\n", changes > 0)
        print("{}\\n", view.replaceAll("second", "third", 0) == 1)
        tree = Gtk.Tree(self.request, self.activateRow)
        tree.add(0, 4294967553, "leaf", "", false, "leaf", 4294967553)
        tree.add(0, 4294967554, "folder", "", true, "folder", 4294967554)
        Gtk.Box box = Gtk.Box(1, 0)
        box.append(tree)
        box.append(view.widget())
        window = Gtk.Window("Numeric callbacks")
        window.setChild(box)
        window.present()
        int64 emitted = Native().emit()
        print("{}\\n", emitted == 3 && activated == 4294967553 && line == 1)
        if (emitted != 3 || activated != 4294967553 || line != 1) {
            print("callback details: emitted={} activated={} line={}\\n", emitted, activated, line)
        }
        tree.setExpanded(4294967554, true)
        print("{}\\n", requested == 4294967554)
        scan = Gtk.DirectoryScan(tree, "gui-scan", false, self.scanned)
    }
    void run(Probe receiver) {
        self = receiver
        app = Gtk.Application("org.cwhip.NumericSdkTest")
        Gtk.SignalConnection connection = app.onActivate(self.activate)
        app.run()
    }
}
start { Probe probe = Probe()
    probe.run(probe) }
""")
        execute([compiler, gui_source, work / "gui-fixture.o", "-o", work / "gui"])
        if shutil.which("Xvfb") and shutil.which("dbus-daemon"):
            from gtk_support import headless
            with headless(shutil.which("Xvfb"), work, env) as gui_env:
                result = run([str(work / "gui")], env=gui_env, cwd=work)
            assert result.stdout == "true\n" * 8, result
        else:
            print("GUI runtime check skipped: Xvfb and dbus-daemon are required")

    # Build an external native package using only installed public headers.
    native_root = work / "native-modules"
    native = native_root / "nativefixture/0.1.0"
    (native / "lib").mkdir(parents=True)
    types = ("int8", "uint8", "int16", "uint16", "int32", "uint32",
             "int64", "uint64", "fp32", "fp64")
    native_source = work / "native.c"
    native_source.write_text('#include "cwhip/Stdlib.h"\n' + "\n".join(
        f"{'float' if typ == 'fp32' else 'double' if typ == 'fp64' else typ + '_t'} "
        f"echo_{typ}(void *self, "
        f"{'float' if typ == 'fp32' else 'double' if typ == 'fp64' else typ + '_t'} x)"
        " { (void)self; return x; }" for typ in types))
    execute([clang, "-I", sdk / "include", "-c", native_source, "-o", work / "native.o"])
    execute(["ar", "rcs", native / "lib/libnativefixture.a", work / "native.o"])
    (native / "nativefixture.cw").write_text("class Native {\npublic:\n" + "\n".join(
        f"    {typ} echo_{typ}({typ} x)" for typ in types) + "\n}\n" + "\n".join(
        f'{typ} Native.echo_{typ}({typ} x) from "echo_{typ}"' for typ in types) + "\n")
    manifest = native / "cwhip-package.toml"
    manifest_text = """[package]
sdk-abi = "numeric-v2"
name = "nativefixture"
version = "0.1.0"
source = "nativefixture.cw"
export = "class:Native"
[link]
libraries = ["nativefixture"]
library-paths = ["lib"]
"""
    manifest.write_text(manifest_text)
    native_project = work / "native-project"
    (native_project / "modules").mkdir(parents=True)
    env["CWHIP_STDLIB_MODULE_DIR"] = str(native_root)
    execute([package_tool, "init", native_project])
    native_program = native_project / "main.cw"
    native_checks = []
    for typ in types:
        value = "-7" if typ.startswith("int") else "250" if typ.startswith("uint") else "1.5"
        native_checks.append(
            f'print("{{}}\\n", Native().echo_{typ}({typ}({value})) == {typ}({value}))')
    native_program.write_text("import nativefixture as Native\nstart {\n" +
                              "\n".join(native_checks) + "\n}\n")
    execute([compiler, native_program, "-o", work / "native-program"])
    assert execute([work / "native-program"]).stdout == "true\n" * len(types)
    for abi in ('sdk-abi = "numeric-v1"\n', ""):
        manifest.write_text(manifest_text.replace('sdk-abi = "numeric-v2"\n', abi))
        execute([compiler, native_program, "--check-only"], failure="incompatible package SDK ABI")
        bad_project = work / ("bad-" + ("old" if abi else "missing"))
        (bad_project / "modules").mkdir(parents=True)
        execute([package_tool, "init", bad_project], failure="PKG2004")
    manifest.write_text(manifest_text)
    del env["CWHIP_STDLIB_MODULE_DIR"]

    # Versioned object sidecars reject old artifacts before invoking the linker.
    execute([compiler, source, "-c", "-o", work / "parsers.o"])
    sidecar = work / "parsers.o.cwhip-link"
    assert sidecar.read_text().startswith("CWHIP-LINK 2 numeric-v2\n")
    execute([compiler, work / "parsers.o", "-o", work / "object-program"])
    assert execute([work / "object-program"]).stdout == parser_output
    sidecar.write_text("CWHIP-LINK 1\n")
    execute([compiler, work / "parsers.o", "-o", work / "old-program"], failure="CWHIP2001")
    if shutil.which("objcopy"):
        stale_runtime = work / "stale-runtime"
        stale_runtime.mkdir()
        runtime = stale_runtime / "libcwhip_runtime.a"
        shutil.copyfile(sdk / "lib/cwhip/libcwhip_runtime.a", runtime)
        execute(["objcopy", "--redefine-sym",
                 "cwhip_runtime_abi_numeric_v2=cwhip_runtime_abi_pre_numeric", runtime])
        env["CWHIP_RUNTIME_DIR"] = str(stale_runtime)
        execute([compiler, source, "-o", work / "stale-runtime-program"],
                failure="cwhip_runtime_abi_numeric_v2")
        del env["CWHIP_RUNTIME_DIR"]
    else:
        print("Stale runtime check skipped: objcopy is required")
    assert not (work / "xdg/cwhip/sdk.toml").exists()

    # Exact CMake discovery, native object inputs, GUI resource staging.
    if not (sdk / "lib/cmake/Cwhip/CwhipConfig.cmake").is_file():
        assert not require_installed, "Missing installed CMake config"
        print("Staged prefix: installed CMake consumer check requires --require-installed")
        return
    cmake_source = work / "cmake-source"
    cmake_source.mkdir()
    (cmake_source / "main.cw").write_text("""
class Native { public: int8 value(int8 x) }
int8 Native.value(int8 x) from "echo_int8"
start { print("{}\\n", Native().value(-7)) }
""")
    shutil.copyfile(native_source, cmake_source / "native.c")
    (cmake_source / "CMakeLists.txt").write_text("""
cmake_minimum_required(VERSION 3.24)
find_package(Cwhip 0.0.2 EXACT CONFIG REQUIRED)
project(numeric_consumer LANGUAGES C)
if(NOT Cwhip_SDK_ABI STREQUAL "numeric-v2")
  message(FATAL_ERROR "Wrong numeric SDK ABI")
endif()
add_library(native OBJECT native.c)
target_include_directories(native PRIVATE "${Cwhip_INCLUDE_DIR}")
""" + ("cwhip_require_sourceview()\n" if gui else "") + """
cwhip_add_program(consumer SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/main.cw"
  OBJECTS $<TARGET_OBJECTS:native> DEPENDS native)
""")
    execute(["cmake", "-S", cmake_source, "-B", work / "cmake-build",
             f"-DCMAKE_PREFIX_PATH={sdk}"])
    execute(["cmake", "--build", work / "cmake-build", "-j2"])
    assert execute([work / "cmake-build/bin/consumer"]).stdout == "-7\n"
    if gui:
        assert (work / "cmake-build/share/cwhip/modules/sourceview/0.1.0/"
                "language-specs/cwhip.lang").is_file()
    assert not (work / "xdg/cwhip/sdk.toml").exists()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--sdk", type=Path, required=True)
    parser.add_argument("--clang", default="clang")
    parser.add_argument("--require-installed", action="store_true")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="cwhip-numeric-sdk-") as directory:
        exercise(args.sdk.resolve(), args.clang, Path(directory), args.require_installed)
    print("numeric SDK contracts passed")


if __name__ == "__main__":
    main()
