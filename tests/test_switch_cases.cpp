#include "test_cases.hpp"

#include "cwhip/CodeGenerator.hpp"
#include "cwhip/Diagnostic.hpp"
#include "cwhip/Lexer.hpp"

#include <array>
#include <sstream>

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{16, {
    {"switch range lexing preserves float forms", [] {
        const auto tokens = cwhip::Lexer(
            "1..20 0x1..0xF 1u..20u .5 5. 1.e2 1.5f64 1...5", "ranges.cw").tokenize();
        using T = cwhip::TokenType;
        const std::array expected{
            T::Integer, T::DotDot, T::Integer, T::Integer, T::DotDot, T::Integer,
            T::UnsignedInteger, T::DotDot, T::UnsignedInteger,
            T::Float, T::Float, T::Float, T::Float, T::Integer, T::DotDot, T::Float, T::End};
        require(tokens.size() == expected.size(), "wrong range/float token count");
        for (std::size_t index = 0; index < expected.size(); ++index) {
            require(tokens[index].type == expected[index],
                    "wrong range/float token at " + std::to_string(index));
        }
        const auto keywords = cwhip::Lexer("SwItCh CaSe DeFaUlT NeXt", "keywords.cw").tokenize();
        require(keywords[0].type == T::Switch && keywords[1].type == T::Case &&
                    keywords[2].type == T::Default && keywords[3].type == T::Identifier,
                "switch keywords should be case insensitive");
        expectValid("class C { public: enum { NEXT = 1 }\n int64 next() { return(NEXT) } }\n"
                    "start { C c = C()\n int64 next = c.next()\n next += 1\n"
                    "switch (next) { case (2) { NeXt } default {} } }");
    }},
    {"switch AST and interval lowering", [] {
        auto program = parse(R"(
start {
    switch (uint64(18446744073709551615u)) {
        case (0, 2..4) { next }
        case (5..18446744073709551615u) { print(1) }
        default { print(2) }
    }
}
)");
        const auto& branches = program.statements.front().switchBranches;
        require(branches.size() == 3 && branches[0].labels.size() == 2 &&
                    branches.back().isDefault, "lost switch branches/alternatives");
        require(branches[1].labels[0].upperValue == "18446744073709551615",
                "uint64 bound was truncated");
        std::ostringstream ast;
        cwhip::dumpAst(program, ast);
        for (const auto* node : {"Switch", "Case", "Range", "Value", "Next", "Default"})
            require(ast.str().find(node) != std::string::npos, "missing switch AST node");
        const auto ir = cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(program);
        require(ir.find("icmp ule i64") != std::string::npos,
                "unsigned interval comparison missing");
        require(ir.size() < 100000, "wide interval must not enumerate its values");
    }},
    {"switch selectors and labels require integers", [] {
        for (const auto* selector : {"1.0", "true", "\"text\"", "[1]", "null"}) {
            expectDiagnostic("start { switch (" + std::string(selector) +
                             ") { default {} } }", "selector must have an integer type");
        }
        for (const auto* label : {"1.0", "true", "\"text\"", "1..2.0", "1.0..2"}) {
            expectDiagnostic("start { switch (1) { case (" + std::string(label) +
                             ") {} } }", "compile-time integer expression");
        }
        expectDiagnostic("start { int64 value = 1\n"
                         "switch (value) { case (value) {} } }", "compile-time");
        expectDiagnostic("class C { public: int64 get() { return(1) } }\n"
                         "start { C c = C()\n switch (1) { case (c.get()) {} } }",
                         "compile-time");
        expectDiagnostic("class C { public: enum { VALUE = 1 }\n C get() { return(C()) } }\n"
                         "start { C c = C()\n switch (1) { case (c.get().VALUE) {} } }",
                         "not an instance expression");
    }},
    {"switch mandatory delimiters and final default", [] {
        expectDiagnostic("start { switch 1 {} }", "'(' after switch");
        expectDiagnostic("start { switch (1) case (1) {} }", "'{' after switch");
        expectDiagnostic("start { switch (1) { case 1 {} } }", "'(' after case");
        expectDiagnostic("start { switch (1) { case (1) print(1) } }", "'{'");
        expectDiagnostic("start { switch (1) { case () {} } }", "expected expression");
        expectDiagnostic("start { switch (1) { case (1,) {} } }", "expected expression");
        expectDiagnostic("start { switch (1) { default() {} } }", "'{'");
        expectDiagnostic("start { switch (1) { default {} case (1) {} } }", "final");
        expectDiagnostic("start { switch (1) { default {} default {} } }", "final");
        expectDiagnostic("start { switch (1) { print(1) } }", "expected case or default");
        expectDiagnostic("start { switch (1) { case (1) { print(1) next } case (2) {} } }",
                         "newline after statement");
        expectValid("start { switch (1) {} switch (1) { default {} } }");
    }},
    {"switch next is only final and direct", [] {
        expectDiagnostic("start { next }", "final direct statement");
        expectDiagnostic("start { switch (1) { case (1) { next } } }",
                         "requires a following");
        expectDiagnostic("start { switch (1) { default { next } } }",
                         "requires a following");
        for (const auto* body : {"next\nprint(1)", "if (true) { next }",
                                "{ next }", "while (true) { next }",
                                "try { next } finally {}", "try {} finally { next }"}) {
            expectDiagnostic("start { switch (1) { case (1) { " + std::string(body) +
                             " } case (2) {} } }", "final direct statement");
        }
        expectValid("start { switch (1) { case (1) { next } case (2) { next } default {} } }");
    }},
    {"switch branches isolate loop transfers", [] {
        for (const auto* transfer : {"break", "continue"}) {
            expectDiagnostic("start { while (true) { switch (1) { case (1) { " +
                             std::string(transfer) + " } } } }", "outside of a loop");
            expectDiagnostic("start { while (true) { switch (1) { default { if (true) { " +
                             std::string(transfer) + " } } } } }", "outside of a loop");
            expectDiagnostic("start { switch (1) { case (1) { while (true) {"
                             " switch (1) { default { " + std::string(transfer) +
                             " } } } } } }", "outside of a loop");
            expectValid("start { while (true) { switch (1) { default { while (true) { " +
                        std::string(transfer) + " } } } break } }");
        }
        expectValid("start { switch (1) { case (1) { switch (2) { case (2) { next }"
                    " default {} } next } default {} } }");
    }},
    {"switch labels are converted without narrowing", [] {
        const std::array<std::array<const char*, 5>, 8> types{{
            {{"int8", "-128", "127", "-129", "128"}},
            {{"uint8", "0", "255", "-1", "256"}},
            {{"int16", "-32768", "32767", "-32769", "32768"}},
            {{"uint16", "0", "65535", "-1", "65536"}},
            {{"int32", "-2147483648", "2147483647", "-2147483649", "2147483648"}},
            {{"uint32", "0", "4294967295", "-1", "4294967296"}},
            {{"int64", "-9223372036854775808", "9223372036854775807",
              "9223372036854775808u", "18446744073709551615u"}},
            {{"uint64", "0", "18446744073709551615u", "-1", "-9223372036854775808"}}
        }};
        for (const auto& type : types) {
            const auto prefix = "start { switch (" + std::string(type[0]) + "(0)) { case (";
            expectValid(prefix + type[1] + ".." + type[2] + ") {} } }");
            expectValid(prefix + type[2] + ".." + type[1] + ") {} } }");
            expectDiagnostic(prefix + type[3] + ") {} } }", "losslessly representable");
            expectDiagnostic(prefix + type[4] + ") {} } }", "losslessly representable");
            expectDiagnostic(prefix + type[1] + ".." + type[3] + ") {} } }",
                             "losslessly representable");
            expectDiagnostic(prefix + type[3] + ".." + type[1] + ") {} } }",
                             "losslessly representable");
        }
    }},
    {"switch duplicate and overlap diagnostics", [] {
        for (const auto* labels : {"case (1, 1) {}", "case (1) {} case (1u) {}",
                                  "case (1..5, 3) {}", "case (1..5) {} case (5..6) {}",
                                  "case (-5..5) {} case (-6..-5) {}",
                                  "case (1..10) {} case (2..3) {} case (8..9) {}",
                                  "case (3..1, 1..3) {}", "case (3..1, 3u..5u) {}",
                                  "case (5..-5) {} case (-6..-5) {}",
                                  "case (3..1, 8..5) {} case (7) {}",
                                  "case (5..1) {} case (3..2) {}",
                                  "case (uint8(-1)) {} case (255) {}"}) {
            expectDiagnostic("start { switch (int64(1)) { " + std::string(labels) + " } }",
                             "duplicate or overlapping");
        }
        expectDiagnostic("start { switch (uint64(0)) {"
                         "case (0..18446744073709551615u) {}"
                         "case (18446744073709551615u) {} } }", "overlapping");
        expectValid("start { switch (int64(1)) { case (2..-2) {} } }");
        expectValid("start { switch (uint64(1)) {"
                    "case (18446744073709551615u..0) {} } }");
        expectDiagnostic("start { switch (uint64(0)) {"
                         "case (18446744073709551615u..0) {} case (0) {} } }", "overlapping");
        expectDiagnostic("start { switch (int64(0)) {"
                         "case (9223372036854775807..-9223372036854775808) {}"
                         "case (-9223372036854775808) {} } }", "overlapping");
        expectValid("start { switch (int64(0)) { case (-5..-1) {} case (0..5) {} } }");
        try {
            parse("start {\n switch (1) {\n case (1, 1u) {}\n }\n}\n", "duplicate.cw");
            require(false, "duplicate label was accepted");
        } catch (const cwhip::DiagnosticError& error) {
            require(error.location().file == "duplicate.cw" && error.location().line == 3,
                    "duplicate diagnostic lost the label source location");
        }
    }},
    {"switch grouped ranges normalize without changing source endpoints", [] {
        for (const auto* labels : {"1..3, 5..8", "3..1, 8..5", "1..3, 8..5, 10",
                                  "-1..-3, 2..-0"}) {
            expectValid("start { switch (int64(1)) { case(" + std::string(labels) +
                        ") {} } }");
        }
        auto program = parse("class A { public: enum { FIRST = -3 } }\n"
                             "class B { public: enum { LAST = 8 } }\n"
                             "start {\n switch (int64(1)) {\n"
                             " case(B.LAST..A.FIRST) {}\n }\n}", "endpoints.cw");
        const auto& label = program.statements.front().switchBranches.front().labels.front();
        require(label.lowerValue == "-3" && label.upperValue == "8",
                "evaluated enum endpoints were not normalized");
        require(label.lower->value == "8" && label.upper->value == "-3" &&
                    label.lower->location.line == 5 && label.lower->location.column == 9 &&
                    label.upper->location.line == 5 && label.upper->location.column == 17,
                "source endpoints or locations were swapped");
        expectDiagnostic("class A { public: enum { FIRST = -3 } }\n"
                         "class B { public: enum { LAST = 8 } }\n"
                         "start { switch (int64(1)) {"
                         "case(B.LAST..A.FIRST) {} case (-3) {} } }", "overlapping");
    }},
    {"switch constant expressions preserve numeric semantics", [] {
        expectValid("class C { public: enum { ONE = 1, THREE = ONE + 2 }\n"
                    "int64 f(int64 x) { switch (x) { case (ONE + 1) { return(2) }"
                    " case (C.THREE) { next } default { return(3) } } } }\n"
                    "start { switch (uint8(0)) {"
                    " case (uint8(255) + uint8(1)) {}"
                    " case (int16(1) << 2, ~uint8(0), int64(3.0)) {} } }");
        expectDiagnostic("start { switch (1) { case (1 / 0) {} } }", "division by zero");
        expectDiagnostic("start { switch (1) { case (int8(127) + int8(1)) {} } }", "overflow");
        expectDiagnostic("start { switch (1) { case (1 << 8) {} } }", "shift count");
        expectDiagnostic("class C { private: enum { HIDDEN = 1 } }\n"
                         "start { switch (1) { case (C.HIDDEN) {} } }", "not accessible");
    }},
    {"switch branch scopes initialization and return reachability", [] {
        expectValid("namespace N { class C {} class D {"
                    "public: int64 run(int64 x) { switch (x) {"
                    " case (1) { C local = C()\n next }"
                    " case (2) { C local = C()\n return(2) }"
                    " default { return(3) } } } } }\nstart {}");
        expectValid("start { int64 x\n switch (1) {"
                    " case (1) { x = 1 } default { x = 2 } } print(x) }");
        expectDiagnostic("start { int64 x\n switch (1) {"
                         " case (1) { x = 1 } } print(x) }", "uninitialized");
        expectDiagnostic("start { switch (1) {"
                         " case (1) { int64 x = 1\n next } default { print(x) } } }",
                         "undefined variable");
        expectDiagnostic("class C { public: int64 f(int64 x) { switch (x) {"
                         " case (1) { return(1) } } } }\nstart {}", "return");
        expectDiagnostic("class C { public: int64 f(int64 x) { switch (x) {"
                         " case (1) { next } default {} } } }\nstart {}", "return");
        expectValid("class C { public: C() { switch (1) { default { return } } } }\nstart {}");
        expectDiagnostic("class B { public: B() {} }\n class C: B { public: C() {"
                         " try { super B() } except() {"
                         " switch (1) { default { return } } raise() } } }\nstart {}",
                         "base initialization handler");
        expectDiagnostic("class B { public: B() {} }\n class C: B { public: C() {"
                         " super B()\n switch (1) { default { super B() } } } }\nstart {}",
                         "direct leading constructor");
        expectDiagnostic("class C { public: int64 f() { try {} finally {"
                         " switch (1) { default { return(1) } } } return(2) } }\nstart {}",
                         "return is not allowed inside finally");
    }},
}};
} // namespace
