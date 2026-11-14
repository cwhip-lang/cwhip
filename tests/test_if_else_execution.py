#!/usr/bin/env python3
"""Execute conditional else chains at O0 and O2."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile


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
    source = r"""
class Checks {
    public:
    int64 evaluations
    bool condition(bool result) {
        evaluations += 1
        return(result)
    }
}
start {
    int a = 1
    int b = 2

    if(a == b) {
        print("a and b are equal\n")
    }
    else(a >= b) {
        print("a is greater or equal to b\n")
    }
    else(a <= b) {
        print("a is less than or equal to b\n")
    }
    else {
        print("a and b are not equal\n")
    }

    Checks checks = Checks()
    if (checks.condition(false)) {
        print("wrong first branch\n")
    }
    else (checks.condition(true)) {
        print("ordered branch\n")
    }
    else (checks.condition(true)) {
        print("wrong later branch\n")
    }
    else {
        print("wrong fallback\n")
    }
    if (checks.condition(false)) {
        print("wrong fallback condition\n")
    }
    else {
        print("fallback branch\n")
    }
    print("{}\n", checks.evaluations)
}
"""
    expected = ("a is less than or equal to b\n"
                "ordered branch\n"
                "fallback branch\n"
                "3\n")
    with tempfile.TemporaryDirectory(prefix="cwhip-if-else-") as directory:
        work = Path(directory)
        program = work / "if_else.cw"
        program.write_text(source)
        for optimization in ("-O0", "-O2"):
            wrapper = work / "clang-wrapper"
            wrapper.write_text('#!/bin/sh\nexec "' + args.clang + '" ' +
                               optimization + ' "$@"\n')
            wrapper.chmod(0o755)
            executable = work / "if_else"
            run([args.compiler, "-g", "-o", str(executable), str(program)],
                env=dict(os.environ, CC=str(wrapper)))
            output = run([str(executable)]).stdout
            assert output == expected, (
                f"{optimization}: expected:\n{expected}\nactual:\n{output}")
    print("PASS conditional else chains, ordering, laziness and fallback at O0/O2")


if __name__ == "__main__":
    main()
