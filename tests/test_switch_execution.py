#!/usr/bin/env python3
"""Execute switch dispatch, numeric boundaries and cleanup at O0 and O2."""
import argparse
import os
from pathlib import Path
import re
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
    keywords = {entry.text for entry in spec.findall(".//keyword")}
    assert {"switch", "case", "default", "next"} <= keywords
    number = spec.find(".//context[@id='number']/match").text
    matches = [match.group() for match in re.finditer(
        number, "1..20 0x1..0xF .5 5. 1.e2 1.5f64", re.VERBOSE)]
    assert matches == ["1", "20", "0x1", "0xF", ".5", "5.", "1.e2", "1.5f64"], matches
    source = r"""
import enum_values as Values
namespace N {
    class Labels { public: enum { LOW = -3, HIGH = LOW + 2, SINGLE = 30 } }
    class OtherLabels { public: enum { HIGH = 3 } }
    class Payload {
        public:
        int64 value
        Payload(int64 n) { value = n }
        destroy { print("destroyed/") }
    }
    class Worker {
        public:
        int64 evaluations
        int64 selector(int64 n) { evaluations += 1
            return(n) }
        int64 dispatch(int64 n) {
            switch (selector(n)) {
                case (Labels.LOW..Labels.HIGH) { return(10) }
                case (0, 2, 4) { return(20) }
                case (10..20, Labels.SINGLE) { return(30) }
                default { return(40) }
            }
        }
        int64 returning(int64 n) {
            try {
                switch (n) {
                    case (0) {
                        try { return(selector(42)) }
                        finally { print("inner/") }
                    }
                    case (1) {
                        try { raise(Exception("raised/")) }
                        finally { print("throw/") }
                    }
                    default { return(99) }
                }
            } finally { print("outer/") }
        }
        Payload rooted(int64 n) {
            switch (n) {
                case (0) { next }
                default {
                    try { return(Payload(77)) }
                    finally {
                        int64 i = 0
                        while (i < 200) {
                            strg churn = format("temporary {}", i)
                            i += 1
                        }
                    }
                }
            }
        }
        void early() {
            switch (1) { case (1) { return } }
            print("BAD")
        }
    }
}
start {
    N.Worker worker = N.Worker()
"""
    expected = ""
    checks = 0

    def check(expression, value="true"):
        nonlocal source, expected, checks
        source += f'print("{{}}\\n", {expression})\n'
        expected += value + "\n"
        checks += 1

    for value in (-4, -3, -2, -1, 0, 1, 2, 3, 4, 9, 10, 15, 20, 21, 30, 31):
        result = 10 if -3 <= value <= -1 else 20 if value in (0, 2, 4) else (
            30 if 10 <= value <= 20 or value == 30 else 40)
        check(f"worker.dispatch({value}) == {result}")
    check("worker.evaluations == 16")
    source += r"""
    switch (worker.selector(123)) {}
    switch (worker.selector(123)) { case (1) { print("BAD") } }
    switch (worker.selector(123)) { default { print("default/") } }
    int64 same = 100
    try {
        switch (worker.selector(1)) {
            case (1) {
                int64 same = 1
                print(same)
                try { raise(Exception("handled")) }
                except(Exception) as caught { print(caught.message) }
                finally { print("/") }
                next
            }
            case (99) {
                int64 same = 2
                print(same)
                switch (7) {
                    case (7) { print("nested/")
                        next }
                    default { print("nested-default/") }
                }
                next
            }
            default { print("chain/") }
        }
    } finally { print("finally/") }
    print("{}\n", same)
    switch (1) { case (1) { print("only/\n") } case (2) { print("BAD") } }
    int64 outer = 0
    while (outer < 2) {
        switch (outer) {
            case (0) {
                int64 inner = 0
                while (inner < 3) {
                    try {
                        inner += 1
                        if (inner == 1) { continue }
                        break
                    } finally { print(inner) }
                }
                for (item in [1, 2]) { print("for/")
                    break }
                do { print("do/")
                    break } while (true)
                next
            }
            default { print("body/") }
        }
        outer += 1
        if (outer == 1) { continue }
        break
    }
    print("{}\n", outer)
    print("{}\n", worker.returning(0))
    try { print(worker.returning(1)) }
    except(Exception) as caught { print("{}\n", caught.message) }
    print("{}\n", worker.returning(2))
    worker.early()
    N.Payload payload = worker.rooted(0)
    print("{}\n", payload.value)
    switch (1) {
        case (1) { payload.destroy()
            next }
        default { print("after-destroy/\n") }
    }
    try {
        try { raise(Exception("rethrow/")) }
        except(Exception) {
            switch (1) { case (1) { raise() } }
        }
    } except(Exception) as caught { print("{}\n", caught.message) }
    switch (Values.NEXT) {
        case (Values.FIRST..Values.NEXT) { print("imported-enum\n") }
        default { print("BAD") }
    }
"""
    expected += ("default/1handled/2nested/nested-default/chain/finally/100\n"
                 "only/\n12for/do/body/body/2\ninner/outer/42\n"
                 "throw/outer/raised/\nouter/99\n77\ndestroyed/after-destroy/\n"
                 "rethrow/\nimported-enum\n")
    check("worker.evaluations == 21")

    groups = (
        ("1..3,5..8", {1, 2, 3, 5, 6, 7, 8}),
        ("3..1,8..5", {1, 2, 3, 5, 6, 7, 8}),
        ("1..3,8..5,10", {1, 2, 3, 5, 6, 7, 8, 10}),
        ("N.OtherLabels.HIGH..N.Labels.LOW,8..5", set(range(-3, 4)) | set(range(5, 9))),
        ("N.Labels.LOW..N.OtherLabels.HIGH,5..8", set(range(-3, 4)) | set(range(5, 9))),
    )
    for labels, members in groups:
        for value in range(-4, 12):
            source += (f"switch (int64({value})) {{\n"
                       f'case({labels}) {{ print("member\\n") }}\n'
                       'default { print("miss\\n") }\n}\n')
            expected += "member\n" if value in members else "miss\n"
            checks += 1

    for width in (8, 16, 32, 64):
        for signed in (True, False):
            numeric = ("int" if signed else "uint") + str(width)
            minimum = -(1 << (width - 1)) if signed else 0
            maximum = (1 << (width - (1 if signed else 0))) - 1
            suffix = "" if signed else "u"
            for value in (minimum, minimum + 1, maximum - 1, maximum):
                source += (f"switch ({numeric}({value}{suffix})) {{\n"
                           f'case ({minimum}{suffix}, {maximum}{suffix}) {{ print("edge\\n") }}\n'
                           f'case ({minimum + 1}{suffix}..{maximum - 1}{suffix}) '
                           '{ print("interior\\n") }\n'
                           'default { print("BAD") }\n}\n')
                expected += "edge\n" if value in (minimum, maximum) else "interior\n"
                checks += 1
            for descending in (False, True):
                first, last = (maximum, minimum) if descending else (minimum, maximum)
                for value in (minimum, minimum + 1, 0, maximum - 1, maximum):
                    source += (f"switch ({numeric}({value}{suffix})) {{\n"
                               f'case ({first}{suffix}..{last}{suffix}) '
                               '{ print("full-width\\n") }\n'
                               'default { print("BAD") }\n}\n')
                    expected += "full-width\n"
                    checks += 1
    source += r"""
    switch (uint64(18446744073709551615u)) {
        case (0..18446744073709551615u) { print("wide-unsigned\n") }
    }
    switch (int64(-9223372036854775808)) {
        case (-9223372036854775808..9223372036854775807) { print("wide-signed\n") }
    }
    switch (uint8(0)) {
        case (uint8(255) + uint8(1)) { print("constant-wrap\n") }
    }
}
"""
    expected += "wide-unsigned\nwide-signed\nconstant-wrap\n"

    with tempfile.TemporaryDirectory(prefix="cwhip-switch-") as directory:
        work = Path(directory)
        program = work / "switch.cw"
        program.write_text(source)
        for optimization in ("-O0", "-O2"):
            wrapper = work / "clang-wrapper"
            wrapper.write_text('#!/bin/sh\nexec "' + args.clang + '" ' +
                               optimization + ' "$@"\n')
            wrapper.chmod(0o755)
            executable, llvm = work / "switch", work / "switch.ll"
            run([args.compiler, "-g", "-M", str(root / "tests/functional/modules/packages"),
                 "--emit-llvm", str(llvm), "-o", str(executable),
                 str(program)], env=dict(os.environ, CC=str(wrapper)))
            output = run([str(executable)]).stdout
            assert output == expected, (
                f"{optimization}: expected:\n{expected}\nactual:\n{output}")
            ir = llvm.read_text()
            assert "switch.body" in ir and "icmp ule i64" in ir and "icmp sge i64" in ir
            assert len(ir) < 1000000, "wide switch intervals must not enumerate values"
        print(f"PASS {checks} dispatch/evaluation checks plus next, scopes, loops, "
              "return, throw, finally and destruction at O0/O2")


if __name__ == "__main__":
    main()
