#!/usr/bin/env python3
"""Execute numeric boundary cases with and without LLVM optimization."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile


def run(command, **kwargs):
    result = subprocess.run(command, text=True, capture_output=True, **kwargs)
    if result.returncode:
        raise AssertionError(f"{command}\n{result.stdout}\n{result.stderr}")
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", required=True)
    parser.add_argument("--clang", required=True)
    args = parser.parse_args()
    checks = []

    def check(expression, expected="true"):
        checks.append((expression, expected))

    for width in (8, 16, 32, 64):
        signed, unsigned = f"int{width}", f"uint{width}"
        maximum, minimum = (1 << (width - 1)) - 1, -(1 << (width - 1))
        unsigned_max = (1 << width) - 1
        check(f"{unsigned}({unsigned_max}u) + {unsigned}(1)", "0")
        check(f"{unsigned}(0) - {unsigned}(1)", str(unsigned_max))
        check(f"{unsigned}({unsigned_max}u) * {unsigned}(2)", str(unsigned_max - 1))
        check(f"{signed}(-7) / {signed}(3)", "-2")
        check(f"{signed}(-7) % {signed}(3)", "-1")
        check(f"{signed}(-1) < {unsigned}(0)")
        check(f"{signed}({maximum}) == {unsigned}({maximum}u)")
        check(f"{unsigned}({unsigned_max}u) > {signed}({maximum})")
        check(f"~{unsigned}(0)", str(unsigned_max))
        check(f"{signed}(-2) >> 1", "-1")
        check(f"{unsigned}({unsigned_max}u) >> 1", str(unsigned_max >> 1))
        check(f"{signed}(1) << {width - 1}", str(minimum))
        check(f"{unsigned}(257)", "1" if width == 8 else "257")
        check(f"{unsigned}(-1)", str(unsigned_max))
        check(f"{signed}({unsigned_max}u)", "-1")
        check(f"{unsigned}(-0.75)", "0")
        check(f"{signed}(-0.75)", "0")

    check("uint16(int8(-1))", "65535")
    check("int(7)", "7")
    check("uint(7u)", "7")
    check("float(1.5)", "1.5")
    check("type(int(7)) == int32")
    check("type(uint(7u)) == uint32")
    check("type(float(1.5)) == fp32")
    check("(uint8(1) | uint8(2) ^ uint8(3) & uint8(1))", "3")
    check("(uint8(1) << 2 + 1)", "8")
    check("fp64(0.1) != 0.1f64")
    check("(fp32(16777216) + fp32(1)) == fp32(16777216)")
    check("(1.0 / 0.0) > 0.0")
    check("(0.0 / 0.0) != (0.0 / 0.0)")
    check("bool(0.0 / 0.0)")
    check("(1.0 / -0.0) < 0.0")
    check("(1.401298464324817e-45 + 1.401298464324817e-45) > 1.401298464324817e-45")
    check("(fp32(1.00000011920928955078125) * fp32(0.99999988079071044921875) - fp32(1)) == 0.0")
    check("fp32(1e100f64) > 1e30")
    check("type([int8(1)][0]) == int8")
    check("type([uint16(1)][0]) == uint16")
    check("type([fp32(1)][0]) == fp32")
    check("type([fp64(1)][0]) == fp64")
    check("([int8(1)][0] as int8)", "1")
    check("[int8(-3)][0]", "-3")
    check("[uint8(255)][0]", "255")
    check("[fp32(1.5)][0]", "1.5")
    check("([fp32(1.5)][0] as fp32)", "1.5")
    check("fp64(int64(9007199254740993)) == 9007199254740992.0f64")
    check("fp64(18446744073709551615u) == 18446744073709551616.0f64")
    check("int64(9223372036854774784.0f64)", "9223372036854774784")
    check("uint64(18446744073709549568.0f64)", "18446744073709549568")
    check("int8(-128.9f64)", "-128")
    check("(9007199254740992.0f64 + 1.0f64) == 9007199254740992.0f64")
    check("(5e-324f64 + 5e-324f64) > 5e-324f64")
    check("(1.0f64 / fp64(-0.0)) < 0.0")
    check("(1.0 / fp32(-1e-100f64)) < 0.0")
    check("fp32(0.0f64 / 0.0f64) != fp32(0.0f64 / 0.0f64)")
    check("fp64(fp32(4611686293305294849)) == 4611686568183201792.0f64")
    check("fp64(fp32(9223372586610589697u)) == 9223373136366403584.0f64")
    check("type(buffer[255][0]) == uint8")
    check("buffer[-1][0]", "255")
    check("buffer[257][0]", "1")

    constants = [
        ("int8(127) + int8(0)", "127"),
        ("uint8(255) + uint8(1)", "0"),
        ("uint64(18446744073709551615u) * uint64(2) + uint64(2)", "0"),
        ("int8(255)", "-1"),
        ("uint16(int8(-1))", "65535"),
        ("int8(1) << 7", "-128"),
        ("int8(-2) >> 1", "-1"),
        ("~uint8(0)", "255"),
        ("uint8(7) & uint8(3) ^ uint8(1) | uint8(8)", "10"),
        ("int8(-7) / int8(3)", "-2"),
        ("int8(-7) % int8(3)", "-1"),
        ("int64(18446744073709551615u)", "-1"),
        ("uint8(-0.75)", "0"),
        ("int8(-128.9f64)", "-128"),
        ("int64(fp32(16777216) + fp32(1))", "16777216"),
        ("int64((fp32(1.00000011920928955078125) * fp32(0.99999988079071044921875)) - fp32(1))", "0"),
        ("int64(fp64(9007199254740993))", "9007199254740992"),
        ("int8(true)", "1"),
        ("int8(bool(0.0 / 0.0))", "1"),
        ("int64(fp32(true))", "1"),
        ("int64(fp32(4611686293305294849))", "4611686568183201792"),
    ]
    for index, (expression, expected_value) in enumerate(constants):
        check(f"Constants.C{index} == int64({expected_value})")
        check(f"int64({expression}) == Constants.C{index}")
    check("Constants.LAST == Constants.C0 + 1")

    types = ("int8", "uint8", "int16", "uint16", "int32", "uint32",
             "int64", "uint64", "fp32", "fp64")
    for left in types:
        for right in types:
            integer_left = not left.startswith("fp")
            integer_right = not right.startswith("fp")
            if integer_left and integer_right:
                lw = int(left.removeprefix("uint").removeprefix("int"))
                rw = int(right.removeprefix("uint").removeprefix("int"))
                ls, rs = left.startswith("int"), right.startswith("int")
                if ls != rs:
                    signed_width, unsigned_width = (lw, rw) if ls else (rw, lw)
                    candidates = [w for w in (8, 16, 32, 64)
                                  if w >= signed_width and w > unsigned_width]
                    common = f"int{min(candidates)}" if candidates else None
                else:
                    common = ("int" if ls else "uint") + str(max(lw, rw))
            else:
                integer = left if integer_left else right if integer_right else None
                common = "fp64" if "fp64" in (left, right) else "fp32"
                if integer and int(integer.removeprefix("uint").removeprefix("int")) >= 32:
                    common = "fp64"
            if common:
                check(f"({left}(1) + {right}(2)) == 3")
                check(f"type({left}(1) + {right}(2)) == {common}")
            check(f"{left}(1) < {right}(2)")
            check(f"{right}({left}(1)) == 1")
            check(f"type([{left}(1)][0]) == {left}")
            check(f"([{left}(1)][0] as {left}) == 1")

    native_class = "class Native {\npublic:\n" + "".join(
        f"{numeric} echo_{numeric}({numeric} value)\n" for numeric in types) + "}\n"
    native_class += "".join(
        f'{numeric} Native.echo_{numeric}({numeric} value) from "echo_{numeric}"\n'
        for numeric in types)
    native_class += """
class NativeAliases {
public:
int echoInt(int value)
uint echoUInt(uint value)
float echoFloat(float value)
}
int NativeAliases.echoInt(int value) from "echo_native_int"
uint NativeAliases.echoUInt(uint value) from "echo_native_uint"
float NativeAliases.echoFloat(float value) from "echo_native_float"
class AliasWorker {
public:
int echo(int value) { return(value + 1) }
}
"""
    source = "class Constants {\npublic:\nenum {\n" + "".join(
        f"C{index} = {expression}\n" for index, (expression, _) in enumerate(constants))
    source += "LAST = C0 + 1\n}\n}\n" + native_class
    source += """class Base {
public:
int8 echo(int8 value) { return(value) }
}
class Worker: Base {
public:
int8 echo(int8 value) { return(value) }
fp32 real(fp32 value) { return(value) }
uint8 bits
}
class Holder {
public:
Worker target
int64 calls
Holder() { target = Worker() }
Worker next() { calls += 1
return(target) }
}
"""
    source += "class CallbackWorker {\npublic:\n" + "".join(
        f"{numeric} echo_{numeric}({numeric} value) {{ return(value) }}\n"
        for numeric in types) + "}\nstart {\n"
    source += "".join(
        f'print("{{}}\\n", {expression})\n' for expression, _ in checks)
    expected = "".join(value + "\n" for _, value in checks)
    failures = []
    for width in (8, 16, 32, 64):
        signed, unsigned = f"int{width}", f"uint{width}"
        maximum, minimum = (1 << (width - 1)) - 1, -(1 << (width - 1))
        failures.extend((
            f"{signed}({maximum}) + {signed}(1)",
            f"{signed}({minimum}) - {signed}(1)",
            f"{signed}({maximum}) * {signed}(2)",
            f"-({signed}({minimum}))",
            f"{signed}({minimum}) / {signed}(-1)",
            f"{signed}({minimum}) % {signed}(-1)",
            f"{signed}(1) / {signed}(0)",
            f"{unsigned}(1) % {unsigned}(0)",
            f"{signed}(1) << -1",
            f"{unsigned}(1) >> {width}",
            f"{unsigned}(1) << 18446744073709551615u",
            f"{unsigned}(-1.0)",
            f"{signed}(1.0 / 0.0)",
            f"{unsigned}(0.0 / 0.0)",
        ))
    failures.extend((
        "int8(-129.0f64)", "int8(128.0f64)",
        "int64(9223372036854775808.0f64)",
        "uint64(18446744073709551616.0f64)",
        "([int8(1)][0] as int16)",
        "([fp32(1.5)][0] as fp64)",
        "([1, 2][::0]).length",
    ))
    source += "".join(
        f'try {{ print({expression}) }} except () {{ print("caught\\n") }}\n'
        for expression in failures)
    source += """
int8 nullable = null
print("{}\\n", int8(nullable) == 0)
if (false) { print(int8(127) + int8(1)) }
Native native = Native()
Worker worker = Worker()
Base base = worker
print("{}\\n", base.echo(-7))
Holder holder = Holder()
holder.next().bits += 1u
holder.next().bits <<= 2
print("{}\\n", holder.calls)
print("{}\\n", holder.target.bits)
int8<int8> action = worker.echo
fp32<fp32> realAction = worker.real
print("{}\\n", action(-7))
print("{}\\n", realAction(1.5))
uint8 bits = 255u
bits &= uint8(15)
bits ^= uint8(1)
bits |= uint8(32)
bits <<= 1
bits >>= 2
print("{}\\n", bits)
int8 capture = -2
fp32 realCapture = 1.5
inline (int8 capture, fp32 realCapture) {
*capture = -3;
*realCapture = 2.5f;
}
print("{}\\n", capture)
print("{}\\n", realCapture)
buffer bytes = buffer[0]
bytes[0] = -1
print("{}\\n", bytes[0])
bytes[0] = 257u
print("{}\\n", bytes[0])
"""
    expected += "caught\n" * len(failures) + "true\n-7\n2\n4\n-7\n1.5\n23\n-3\n2.5\n255\n1\n"
    source += "CallbackWorker callbackWorker = CallbackWorker()\n"
    for numeric in types:
        value = "-7" if numeric.startswith("int") else "250" if numeric.startswith("uint") else "1.5"
        source += f'print("{{}}\\n", native.echo_{numeric}({numeric}({value})))\n'
        expected += value + "\n"
        ctype = "float" if numeric == "fp32" else "double" if numeric == "fp64" else numeric + "_t"
        source += f"""
{numeric}<{numeric}> cb_{numeric} = callbackWorker.echo_{numeric}
{numeric} result_{numeric} = 0
inline({numeric}<{numeric}> cb_{numeric}, {numeric} result_{numeric}) {{
CwhipCallbackContext *context = cwhip_callback_acquire(*cb_{numeric}, "callback<{numeric}({numeric})>");
*result_{numeric} = (({ctype} (*)(CwhipCallbackContext *, {ctype}))
    cwhip_callback_adapter(context))(context, ({ctype})({value}));
cwhip_callback_release(context);
cwhip_callback_dispose(context);
}}
print("{{}}\\n", result_{numeric})
"""
        expected += value + "\n"
    source += """
NativeAliases aliases = NativeAliases()
print("{}\\n", aliases.echoInt(int(12)))
print("{}\\n", aliases.echoUInt(uint(17u)))
print("{}\\n", aliases.echoFloat(float(1.25)))
range<int> aliasRange = int(1)..int(3)
print("{}\\n", type(aliasRange) == range<int32>)
print("{}\\n", int(2) in aliasRange)
AliasWorker aliasWorker = AliasWorker()
int<int> aliasAction = aliasWorker.echo
print("{}\\n", type(aliasAction))
print("{}\\n", aliasAction(int(41)))
int aliasResult = 0
inline(int<int> aliasAction, int aliasResult) {
CwhipCallbackContext *context =
    cwhip_callback_acquire(*aliasAction, "callback<int32(int32)>");
cwhip_gc_collect();
*aliasResult = ((int (*)(CwhipCallbackContext *, int))
    cwhip_callback_adapter(context))(context, 41);
cwhip_callback_release(context);
cwhip_callback_dispose(context);
}
print("{}\\n", aliasResult)
}
"""
    expected += "13\n19\n1.75\ntrue\ntrue\ncallback<int32(int32)>\n42\n42\n"

    with tempfile.TemporaryDirectory(prefix="cwhip-numeric-") as directory:
        work = Path(directory)
        input_file = work / "numeric.cw"
        input_file.write_text(source)
        native = work / "native.c"
        native.write_text("#include <stdint.h>\n" + "".join(
            f"{'float' if numeric == 'fp32' else 'double' if numeric == 'fp64' else numeric + '_t'} "
            f"echo_{numeric}(void *receiver, "
            f"{'float' if numeric == 'fp32' else 'double' if numeric == 'fp64' else numeric + '_t'} value) "
            "{ (void)receiver; return value; }\n" for numeric in types) +
            "int echo_native_int(void *receiver, int value) "
            "{ (void)receiver; return value + 1; }\n"
            "unsigned int echo_native_uint(void *receiver, unsigned int value) "
            "{ (void)receiver; return value + 2; }\n"
            "float echo_native_float(void *receiver, float value) "
            "{ (void)receiver; return value + 0.5f; }\n")
        invalid_constants = [
            ("int8(127) + int8(1)", "overflow"),
            ("int8(-128) - int8(1)", "overflow"),
            ("int8(100) * int8(2)", "overflow"),
            ("-(int8(-128))", "overflow"),
            ("int8(-128) / int8(-1)", "overflow"),
            ("int8(-128) % int8(-1)", "overflow"),
            ("uint8(1) / uint8(0)", "division by zero"),
            ("int8(1) << -1", "invalid shift count"),
            ("uint8(1) >> 8", "invalid shift count"),
            ("uint8(1) << 18446744073709551615u", "invalid shift count"),
            ("int8(128.0f64)", "invalid numeric conversion"),
            ("uint64(18446744073709551616.0f64)", "invalid numeric conversion"),
            ("int8(0.0 / 0.0)", "invalid numeric conversion"),
            ("int8(1.0 / 0.0)", "invalid numeric conversion"),
            ("18446744073709551615u", "signed int64 range"),
            ("int8(1) << true", "integer constant operands required"),
            ("true << int8(1)", "integer constant operands required"),
            ("int8(1) + uint64(1)", "no common numeric type"),
            ("-uint8(1)", "unary minus requires a signed operand"),
        ]
        invalid = work / "invalid.cw"
        for expression, diagnostic in invalid_constants:
            invalid.write_text(
                f"class Invalid {{\npublic:\nenum {{ VALUE = {expression} }}\n}}\nstart {{}}\n")
            result = subprocess.run([args.compiler, "--check-only", str(invalid)],
                                    text=True, capture_output=True)
            assert result.returncode != 0 and diagnostic in result.stderr, (
                f"constant {expression}: expected {diagnostic}\n{result.stderr}")
        for optimization in ("-O0", "-O2"):
            wrapper = work / "clang-wrapper"
            wrapper.write_text(
                '#!/bin/sh\nexec "' + args.clang +
                '" ' + optimization + ' -ffp-contract=off "$@"\n')
            wrapper.chmod(0o755)
            environment = dict(os.environ, CC=str(wrapper))
            native_object = work / "native.o"
            run([args.clang, optimization, "-c", str(native), "-o", str(native_object)])
            executable, llvm = work / "numeric", work / "numeric.ll"
            run([args.compiler, "-g", "--emit-llvm", str(llvm), "-o", str(executable),
                 str(input_file), str(native_object)], env=environment)
            output = run([str(executable)]).stdout
            assert output == expected, (
                f"{optimization} output mismatch\nexpected:\n{expected}\nactual:\n{output}")
            ir = llvm.read_text()
            assert "llvm.sadd.with.overflow.i8" in ir
            assert "llvm.experimental.constrained.fmul.f32" in ir
            assert "icmp slt i65" in ir
            assert " fast " not in ir and " contract " not in ir
            for numeric in types:
                width = int(numeric.removeprefix("uint").removeprefix("int").removeprefix("fp"))
                assert f'!DIBasicType(name: "{numeric}", size: {width},' in ir
        print(f"PASS {len(checks)} numeric values and {len(failures)} catchable failures at O0/O2; "
              f"{len(invalid_constants)} required-constant diagnostics")


if __name__ == "__main__":
    main()
