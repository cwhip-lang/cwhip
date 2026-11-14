#!/usr/bin/env python3
"""Run first-class range/consumer checks at O0/O2, normally and under GC stress."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET


def run(command, **kwargs):
    result = subprocess.run(command, text=True, capture_output=True, timeout=120, **kwargs)
    if result.returncode:
        raise AssertionError(f"{command}\n{result.stdout}\n{result.stderr}")
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", required=True)
    parser.add_argument("--clang", required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    spec = ET.parse(root / "stdlib/sourceview/0.1.0/language-specs/cwhip.lang")
    assert "range" in {entry.text for entry in spec.findall(".//keyword")}
    source = r"""
class Box {
    public:
    int64 value
    Box(int64 n) { value = n }
}
class Worker {
    public:
    range<int64> saved
    int64 calls
    int64 endpoint(int64 n) {
        calls += 1
        print(n)
        return(n)
    }
    range<int64> identity(range<int64> r) { saved = r
        return(saved) }
    range<int64> returning() {
        try { return(int64(3)..int64(1)) }
        finally { churn() }
    }
    void churn() {
        for (i in 1..100) { list trash = [i, i..i, format("{}", i)] }
    }
    int64 early(range<int64> r) {
        for (i in r) {
            try { return(i) }
            finally { print("return/") }
        }
        return(0)
    }
    int64 pick(range<int8> r) { return(8) }
    int64 pick(range<int64> r) { return(64) }
    int64 promote(range<int16> r) { return(16) }
    int64 promote(range<int64> r) { return(64) }
}
start {
    Worker w = Worker()
    int64 first = 1
    int64 last = 3
    range<int64> snapshot = w.identity(w.endpoint(first)..w.endpoint(last))
    print("/\n")
    first = 9
    last = 8
    range<int64> updated = first..last
    for (i in snapshot) { print(i) }
    print("/")
    for (i in updated) { print(i) }
    print("/{}\n", w.calls)
"""
    expected = "13/\n123/98/2\n"
    checks = 0

    def emit(text, output=""):
        nonlocal source, expected
        source += text + "\n"
        expected += output

    def check(expression, value="true"):
        nonlocal checks
        emit(f'print("{{}}\\n", {expression})', value + "\n")
        checks += 1

    check("2 in snapshot")
    check("8 in snapshot", "false")
    check("8 in updated")
    check("9 in updated")
    check("10 in updated", "false")
    check("2 in 1 + 1..3 * 2")
    check("type(snapshot) == range<int64>")
    check("snapshot is range<int64>")
    check("snapshot is range<uint64>", "false")
    check("w.pick(1..3) == 8")
    check("w.pick(int64(1)..int64(3)) == 64")
    check("w.promote(1..3) == 16")
    emit(r"""
    print(w.endpoint(2) in w.endpoint(1)..w.endpoint(3))
    print("\n")
    for (i in w.endpoint(3)..w.endpoint(1)) { print(i) }
    print("\n")
    list orderedSlice = [10, 20, 30][w.endpoint(0)..w.endpoint(1)]
    for (v in orderedSlice) { print(v) }
    print("\n")
    """, "213true\n31321\n011020\n")
    check("false && 1 in w.endpoint(1)..w.endpoint(3)", "false")
    check("w.calls == 9")
    emit(r"""
    range<int64> copied = snapshot
    snapshot = int64(40)..int64(42)
    list nested = [[copied], ["r": w.returning()]]
    w.churn()
    list inner = nested[0]
    dict mapping = nested[1]
    range<int64> restored = inner[0]
    range<int64> returned = mapping["r"]
    range<int64><range<int64>> action = w.identity
    range<int64> viaCallback = action(restored)
    """)
    check("2 in viaCallback")
    check("2 in restored")
    check("2 in returned")
    emit("range<int64> widened = 1..3")
    check("type(widened) == range<int64>")
    check("2 in widened")
    emit("list appended = []\n appended.append(widened)\n appended[0] = returned\n"
         "range<int64> appendedRange = appended[0]")
    check("2 in appendedRange")
    check("type(inner[0]) == range<int64>")
    check("inner[0] is range<int64>")
    check("inner[0] is range<int8>", "false")
    check("(inner[0] as range<int64>) is range<int64>")
    emit('print(widened)\n print("\\n")', "1..3\n")
    emit('print("{}\\n", inner[0])', "1..3\n")
    emit('print("{}\\n", returned)', "3..1\n")
    emit('print("{}\\n", w.early(restored))', "return/1\n")
    emit(r"""
    try { range<int8> wrong = inner[0]
        print("BAD")
    } except(Exception) { print("typed-error\n") }
    range<int64> nothing = null
    list nulls = [nothing]
    print("{}\n", nulls[0] == null)
    print("{}\n", type(nulls[0]))
    range<int64> restoredNull = nulls[0]
    range<int64> castNull = nothing as null
    print("{}\n", castNull == null)
    print("{}\n", nothing is range<int64>)
    try { for (i in nothing) { print("BAD") } }
    except(Exception) { print("null-loop\n") }
    try { print(1 in nothing) }
    except(Exception) { print("null-membership\n") }
    try { list fail = [1][nothing] }
    except(Exception) { print("null-slice\n") }
    """, "typed-error\ntrue\nnull\ntrue\nfalse\nnull-loop\nnull-membership\nnull-slice\n")
    # Every width at both edges; continue at the last endpoint must not overflow.
    for width in (8, 16, 32, 64):
        for signed in (True, False):
            numeric = ("int" if signed else "uint") + str(width)
            lo = -(1 << (width - 1)) if signed else 0
            hi = (1 << (width - (1 if signed else 0))) - 1

            def literal(n):
                return f"{numeric}({n}{'' if signed else 'u'})"

            for a, b in ((lo, lo + 1), (lo + 1, lo), (hi - 1, hi),
                         (hi, hi - 1), (lo, lo), (hi, hi)):
                sequence = range(a, b + (1 if a <= b else -1), 1 if a <= b else -1)
                emit(f"for (i in {literal(a)}..{literal(b)}) {{ print(i)\n continue }}\n"
                     'print("/\\n")', "".join(str(n) for n in sequence) + "/\n")
                checks += 1
            for a, b in ((lo, hi), (hi, lo)):
                bounds = f"{literal(a)}..{literal(b)}"
                for n in (lo, lo + 1, hi - 1, hi):
                    check(f"{literal(n)} in {bounds}")
                emit(f"for (i in {bounds}) {{ print(i)\n break }}\n"
                     'print("/\\n")', f"{a}/\n")
            # Store as collection payload and recover the exact range type.
            emit(f"{{ list stored = [{literal(lo)}..{literal(hi)}]\n"
                 f"w.churn()\n range<{numeric}> recovered = stored[0]\n"
                 f"print({literal(lo)} in recovered)\n }}", "true")
    for expr, result in (
        ("uint64(18446744073709551615u) in int64(-9223372036854775808)..int64(9223372036854775807)", "false"),
        ("int64(-1) in uint64(0)..uint64(18446744073709551615u)", "false"),
        ("int64(0) in uint64(18446744073709551615u)..uint64(0)", "true"),
        ("int16(-1) in int8(-1)..uint8(255)", "true"),
        ("int16(256) in int8(-1)..uint8(255)", "false"),
    ):
        check(expr, result)
    emit(r"""
    for (i in 1..3) {
        try {
            if (i == 1) { continue }
            for (j in 5..4) {
                try { print(j)
                    break }
                finally { print("/") }
            }
            if (i == 3) { break }
        } finally { print(i) }
    }
    print("\n")
    try {
        for (i in 3..1) {
            try { if (i == 2) { raise(Exception("stop")) } }
            finally { print(i) }
        }
    } except(Exception) { print("/caught\n") }
    int64 outer = 10
    for (outer in 1..2) {
        { int64 outer = 9
            outer += 1
            print(outer) }
        for (outer in 4..3) { print(outer) }
    }
    print("/{}\n", outer)
    """, "15/25/3\n32/caught\n10431043/10\n")
    emit(r"""
    list items = [int64(10), int64(20), int64(30), int64(40)]
    range<int64> bounds = int64(3)..int64(1)
    list copy = items[bounds]
    items[3] = int64(99)
    for (v in copy) { print(v) }
    copy[1] = int64(88)
    int64 original = items[2]
    print("/{}\n", original)
    list negative = items[-1..-2]
    for (v in negative) { print(v) }
    print("\n")
    Box box = Box(7)
    list refs = [box]
    list refsCopy = refs[0..0]
    Box shared = refsCopy[0]
    shared.value = 9
    print("{}\n", box.value)
    buffer data = buffer[10, 20, 30, 40]
    buffer reversed = data[3..1]
    data[3] = 99
    reversed[1] = 88
    print("{},{},{}/{}\n", reversed[0], reversed[1], reversed[2], data[2])
    strg text = "abcd"
    strg reverseText = text[3..1]
    text.clear()
    print("{}\n", reverseText)
    print("{}\n", "abcd"[-1..-2])
    print("{}\n", "abcd"[2..2])
    print("{}\n", "aéz"[1..2])
    print("{}\n", "é"[int64(0)..uint8(1)])
    """, "403020/30\n9930\n9\n40,88,20/30\ndcb\ndc\nc\né\né\n")
    emit(r"""
    for (v in [1, 2, 3][0..2]) { print(v) }
    print("/")
    for (v in [1, 2, 3][1..1]) { print(v) }
    buffer forward = buffer[10, 20, 30][0..2]
    buffer singleton = forward[1..1]
    forward[1] = uint8(99)
    print("/{},{},{}/{}\n", forward[0], forward[1], forward[2], singleton[0])
    """, "123/2/10,99,30/20\n")
    for receiver in ("[1, 2]", "buffer[1, 2]", '"ab"', "[]", "buffer[]", '""'):
        ranges = ("0..0", "1..0") if receiver in ("[]", "buffer[]", '""') else (
            "0..2", "-3..0", "0u..18446744073709551615u",
            "-9223372036854775808..0")
        for bounds in ranges:
            emit(f"try {{ list discard = [{receiver}[{bounds}]]\n"
                 'print("BAD") }\n'
                 'except(Exception) { print("bounds\\n") }', "bounds\n")
    for bounds in ("0..0", "1..0", "0..1"):
        emit(f'try {{ strg invalid = "é"[{bounds}]\n print("BAD") }}\n'
             'except(Exception) { print("utf8\\n") }' if bounds != "0..1" else
             'print("{}\\n", "é"[0..1])', "utf8\n" if bounds != "0..1" else "é\n")
    # Colon slices and constant switch ranges stay separate from inclusive ranges.
    emit(r"""
    print("{}\n", "abcd"[1..2])
    list colon = [1, 2, 3][0:2]
    print("{}\n", colon.length)
    switch (2) {
        case (3..1, 8..5) { print("switch\n")
            next }
        default { print("group\n") }
    }
}
""", "bc\n2\nswitch\ngroup\n")

    with tempfile.TemporaryDirectory(prefix="cwhip-ranges-") as directory:
        work = Path(directory)
        program = work / "ranges.cw"
        program.write_text(source)
        for optimization in ("-O0", "-O2"):
            wrapper = work / "clang-wrapper"
            wrapper.write_text(f'#!/bin/sh\nexec "{args.clang}" {optimization} "$@"\n')
            wrapper.chmod(0o755)
            executable, llvm = work / "ranges", work / "ranges.ll"
            run([args.compiler, "-g", "--emit-llvm", str(llvm), "-o", str(executable),
                 str(program)], env=dict(os.environ, CC=str(wrapper)))
            for stress in ("0", "1"):
                output = run([str(executable)],
                             env=dict(os.environ, CWHIP_GC_STRESS=stress)).stdout
                assert output == expected, (
                    f"{optimization}, stress={stress}\nexpected:\n{expected}\nactual:\n{output}")
            ir = llvm.read_text()
            assert "range.advance" in ir and "icmp sge i65" in ir
            assert len(ir) < 2000000, "range iteration must remain constant-space"
        gdb = shutil.which("gdb")
        if gdb:
            debug_source = work / "debug-ranges.cw"
            debug_source.write_text(
                "start {\n"
                "range<int64> descending = int64(-2)..int64(-4)\n"
                "range<uint64> high = uint64(18446744073709551615u)..uint64(0)\n"
                "list stored = [high]\n"
                "print(descending)\n}\n")
            debug_executable = work / "debug-ranges"
            run([args.compiler, "-g", "-o", str(debug_executable), str(debug_source)],
                env=dict(os.environ, CC=args.clang))
            debugger_script = work / "check-ranges.gdb"
            debugger_script.write_text(
                f"break {debug_source}:5\nrun\npython\n"
                "import gdb\n"
                "assert gdb.parse_and_eval('descending').type.target().tag == 'range<int64>'\n"
                "assert gdb.parse_and_eval('high').type.target().tag == 'range<uint64>'\n"
                "native = gdb.lookup_type('CwhipRange').pointer()\n"
                "signed = gdb.lookup_type('int64_t')\n"
                "descending = gdb.parse_and_eval('descending').cast(native).dereference()\n"
                "assert int(descending['element_tag']) == 1\n"
                "assert int(descending['first'].cast(signed)) == -2\n"
                "assert int(descending['last'].cast(signed)) == -4\n"
                "high = gdb.parse_and_eval('high').cast(native).dereference()\n"
                "assert int(high['element_tag']) == 8\n"
                "assert int(high['first']) == 18446744073709551615\n"
                "assert int(high['last']) == 0\n"
                "stored = gdb.parse_and_eval('stored').cast("
                "gdb.lookup_type('CwhipArray').pointer()).dereference()\n"
                "assert int(stored['length']) == 1\n"
                "assert stored['values'][0]['tag'] == 19\n"
                "assert stored['values'][0]['pointer'] == high.address\n"
                "print('RANGE_DEBUG_PASS')\nend\n")
            result = run([gdb, "--batch", "-x", str(debugger_script), str(debug_executable)])
            assert "RANGE_DEBUG_PASS" in result.stdout, result.stdout + result.stderr
            print("PASS range DWARF types and runtime layout with real GDB values")
        else:
            print("NOT CONFIGURED range DWARF checks (gdb unavailable)")
        print(f"PASS {checks} range checks plus snapshots, GC round trips, cleanup and slices "
              "at O0/O2, normal/GC stress")


if __name__ == "__main__":
    main()
