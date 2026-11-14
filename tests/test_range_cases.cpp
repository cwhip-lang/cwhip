#include "test_cases.hpp"

#include "cwhip/CodeGenerator.hpp"

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{17, {
    {"first-class range types and consumers", [] {
        expectValid(R"(
class Worker {
    public:
    range<int64> saved
    range<int64> identity(range<int64> values) { saved = values
        return(saved) }
}
start {
    Worker w = Worker()
    range<int64> values = w.identity(1..3)
    list stored = [values, 3..1]
    stored.append(values)
    range<int64> restored = stored[0]
    for (i in restored) { print(i in 3..1) }
    list copy = stored[1..0]
    strg text = "abc"[2..0]
    buffer bytes = buffer[1, 2, 3][2..0]
    print(type(restored) == range<int64>)
    print(stored[0] is range<int64>)
}
)");
    }},
    {"range precedence and constant space lowering", [] {
        auto program = parse("start { print(2 in 1 + 1..3 * 2)\n"
                             "for (i in 0u..18446744073709551615u) { break } }");
        const auto& membership = *program.statements[0].expressions[0];
        require(membership.kind == cwhip::ExpressionKind::Binary &&
                    membership.value == "in" &&
                    membership.right->kind == cwhip::ExpressionKind::Range &&
                    membership.right->left->value == "+" &&
                    membership.right->right->value == "*",
                "range/membership precedence is incorrect");
        const auto ir = cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(program);
        require(ir.find("range.advance") != std::string::npos &&
                    ir.find("icmp eq i64") != std::string::npos &&
                    ir.find("call ptr @cwhip_gc_alloc_array") == std::string::npos &&
                    ir.size() < 200000,
                "range iteration must not enumerate or materialize a list");
        expectValid("start { print(2 IN 3..1) }");
    }},
    {"range endpoints require lossless integer promotion", [] {
        for (const auto& left : cwhip::numericTypes) {
            if (!cwhip::isIntegerType(left.name)) continue;
            for (const auto& right : cwhip::numericTypes) {
                if (!cwhip::isIntegerType(right.name)) continue;
                const auto endpoints = std::string(left.name) + "(0).." +
                                       std::string(right.name) + "(1)";
                const auto common = cwhip::commonIntegerType(left.name, right.name);
                if (common)
                    expectValid("start { range<" + *common + "> r = " + endpoints + " }");
                else
                    expectDiagnostic("start { print(" + endpoints + ") }",
                                     "lossless common integer type");
            }
        }
        for (const auto* endpoints : {"true..1", "1..false", "1.0..2", "1..2.0",
                                      "\"a\"..2", "null..2", "[1]..2", "1..(2..3)",
                                      "int64(0)..uint64(1)", "uint64(1)..int8(0)"})
            expectDiagnostic("start { print(" + std::string(endpoints) + ") }",
                             "lossless common integer type");
        expectValid("start { range<int16> r = int8(-1)..uint8(255)\n"
                    "print(uint64(18446744073709551615u) in r) }");
        expectDiagnostic("start { range<uint8> r = int16(0)..int16(2) }", "cannot initialize");
        expectDiagnostic("start { range<fp64> r = 1..2 }", "range element type");
        expectDiagnostic("start { print(1 is range<bool>) }", "range element type");
        expectDiagnostic("start { print(1 in 2) }", "membership requires");
        expectDiagnostic("start { print(true in 1..2) }", "membership requires");
        expectDiagnostic("class C {}\n start { print(C()..C()) }",
                         "lossless common integer type");
        expectValid("start { for (i in int8(true)..int8(2.0)) { print(i) } }");
    }},
    {"range signatures support out-of-line definitions", [] {
        expectValid(R"(
namespace N {
    class Worker {
        public:
        range<int64> identity(range<int64> values)
    }
    range<int64> Worker.identity(range<int64> values) { return(values) }
}
start {
    N.Worker w = N.Worker()
    range<int64> result = w.identity(1..3)
    print(2 in result)
}
)");
    }},
    {"range binding cannot be written or captured as a mutable alias", [] {
        for (const auto* write : {"i = 2", "i += 1", "(i) = 2",
                                 "inline(int8 i) { *i = 2; }"})
            expectDiagnostic("start { for (i in 1..3) { " + std::string(write) + " } }",
                             "range iteration binding 'i' is read-only");
        expectDiagnostic("start { try { raise(Exception(\"x\")) }\n"
                         "except(Exception) as caught { caught = null } }",
                         "exception binding 'caught' is read-only");
        expectDiagnostic("start { for (key, value in 1..3) {} }",
                         "range iteration accepts one");
        expectValid("start { int64 i = 8\n for (i in 1..3) {\n"
                    "int64 copy = i\n copy += 1\n"
                    "{ int64 i = 20\n i += 1 }\n"
                    "for (i in 5..4) { print(i) }\n"
                    "}\n i += 1 }");
    }},
    {"range slices reject assignment and unsupported receivers", [] {
        for (const auto* target : {"items[0..1]", "items[bounds]"})
            expectDiagnostic("start { list items = [1, 2]\n range<int8> bounds = 0..1\n" +
                             std::string(target) + " = [3] }", "copies and are not assignable");
        expectDiagnostic("start { dict d = [\"a\": 1]\n print(d[0..0]) }",
                         "range slicing requires");
        expectDiagnostic("start { print((1..2)[0..1]) }", "range slicing requires");
        expectDiagnostic("start { for (i in 1..2..3) {} }", "expected");
        expectDiagnostic("start { switch (1) { case (1..2..3) {} } }", "expected");
        expectDiagnostic("start { range<int8> r = 1..3\n"
                         "switch (1) { case (r) {} } }", "compile-time");
    }},
}};
} // namespace
