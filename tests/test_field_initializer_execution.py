#!/usr/bin/env python3
"""Exercise field defaults on allocation paths, inheritance, and GC stress."""
import argparse
import os
from pathlib import Path
import shlex
import subprocess


SOURCE = r"""
class Plain {
    public:
    enum { VALUE = 42 }
    int64 number = VALUE
    strg text = "initialized"
    list values = [1, int64(2 * 3), ["nested"]]
    dict names = ["count": int64(2)]
    buffer bytes = buffer[3, 4]
    bool ready = !false && (2 < 3)
    uint64 maximum = 18446744073709551615u
    fp64 fraction = 1.5f64 * 2.0f64
    fp64 infinity = 1.0f64 / 0.0f64
    fp64 notANumber = 0.0f64 / 0.0f64
    fp32 negativeZero = -0.0
    bool mixedComparison = -1 < 18446744073709551615u
    int64 zero
    strg empty
    int64 scalarNull = null
    type descriptor = int64
}
class Base {
    public:
    int64 number = 11
    Base() {
        print("{}\n", number == 11)
        number = 12
        print("{}\n", read() == 17)
    }
    int64 read() { return(number) }
}
class Derived: Base {
    public:
    int64 own = 17
    Derived() {
        super Base()
        print("{}\n", number == 12 && own == 17)
    }
    int64 read() { return(own) }
}
class Root {
    public:
    int64 value = 10
    Root() { print("{}\n", value == 10) }
}
class Left: virtual Root {
    public:
    Left() {
        print("{}\n", Root.value == 10)
        Root.value = 11
    }
}
class Right: virtual Root {
    public:
    Right() {
        print("{}\n", Root.value == 11)
        Root.value = 12
    }
}
class Diamond: Left, Right {
    public:
    Diamond() {
        super Left()
        super Right()
        print("{}\n", Left.Root.value == 12 && Right.Root.value == 12)
    }
}
class Automatic: virtual Root {}
class RepeatedRoot { public: int64 value = 7 }
class RepeatedLeft: RepeatedRoot {}
class RepeatedRight: RepeatedRoot {}
class Repeated: RepeatedLeft, RepeatedRight {}
class Overloaded {
    public:
    int64 value = 19
    Overloaded() { print("{}\n", value == 19) }
    Overloaded(int64 argument) {
        print("{}\n", value == 19)
        value = argument
    }
}
class OutOfLine {
    public:
    int64 value = 23
    OutOfLine()
}
OutOfLine OutOfLine.OutOfLine() { print("{}\n", value == 23) }
class Maker {
    public:
    Plain make() { return(Plain()) }
    int64 argument(Plain item) { return(item.number) }
}
start {
    Plain first()
    Plain second = Plain()
    print("{}\n", first.number == 42 && second.number == 42)
    print("{}\n", first.text.length == 11)
    print("{}\n", first.ready && first.maximum == 18446744073709551615u)
    print("{}\n", first.fraction == 3.0f64 && first.zero == 0)
    print("{}\n", first.empty == null && first.scalarNull == 0)
    print("{}\n", first.descriptor == int64)
    print("{}\n", first.infinity > 0.0f64 && first.notANumber != first.notANumber)
    print("{}\n", (1.0f64 / first.negativeZero) < 0.0f64 && first.mixedComparison)
    first.values.append(9)
    first.names["count"] = 9
    first.bytes[0] = 9
    print("{}\n", second.values.length == 3 && (second.values[1] as int64) == 6)
    print("{}\n", (second.names["count"] as int64) == 2 && second.bytes[0] == 3)
    Derived derived()
    Diamond diamond()
    Automatic automatic()
    print("{}\n", automatic.value == 10)
    Repeated repeated()
    repeated.RepeatedLeft.RepeatedRoot.value = 8
    print("{}\n", repeated.RepeatedRight.RepeatedRoot.value == 7)
    Overloaded normal()
    Overloaded changed(29)
    print("{}\n", changed.value == 29)
    OutOfLine out()
    Maker maker()
    Plain returned = maker.make()
    print("{}\n", returned.number == 42 && maker.argument(Plain()) == 42)
    list objects = [Plain(), Plain()]
    Plain listed = objects[1] as Plain
    print("{}\n", listed.number == 42)
    int64 index = 0
    while (index < 3) {
        Plain local()
        print("{}\n", local.number == 42)
        local.number = 0
        index += 1
    }
}
"""


def run(command, environment):
    result = subprocess.run(command, text=True, capture_output=True, env=environment)
    if result.returncode:
        raise AssertionError(f"{command}\n{result.stdout}\n{result.stderr}")
    return result.stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", required=True)
    parser.add_argument("--clang", required=True)
    parser.add_argument("--work-dir", required=True)
    parser.add_argument("--sanitize", default="")
    args = parser.parse_args()
    work = Path(args.work_dir).resolve()
    work.mkdir(parents=True, exist_ok=True)
    source = work / "field-initializers.cw"
    wrapper = work / "field-clang"
    source.write_text(SOURCE)
    sanitizer_flags = (
        ["-fsanitize=" + args.sanitize, "-fno-omit-frame-pointer", "-g"]
        if args.sanitize else []
    )
    for optimization in ("-O0", "-O2"):
        wrapper.write_text(
            "#!/bin/sh\nexec " + shlex.join(
                [args.clang, optimization, "-ffp-contract=off", *sanitizer_flags]
            ) + ' "$@"\n')
        wrapper.chmod(0o755)
        environment = dict(os.environ, CC=str(wrapper), CWHIP_GC_STRESS="1")
        executable = work / "field-initializers"
        llvm = work / "field-initializers.ll"
        run([args.compiler, "--emit-llvm", str(llvm), "-o", str(executable), str(source)],
            environment)
        output = run([str(executable)], environment)
        assert output == "true\n" * 29, f"{optimization} output mismatch:\n{output}"
    print("PASS 29 field initialization checks at O0/O2 with GC stress")


if __name__ == "__main__":
    main()
