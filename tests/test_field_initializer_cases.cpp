#include "test_cases.hpp"

#include "cwhip/CodeGenerator.hpp"

#include <algorithm>
#include <sstream>

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{18, {
    {"field initializers retain and fold compile-time values", [] {
        auto program = parse(R"(
class Values {
    public:
    enum { ANSWER = 42 }
    int64 number = ANSWER + 2 * 3
    uint64 maximum = 18446744073709551615u
    uint8 wrapped = uint8(255u) + uint8(1u)
    fp64 fraction = 1.5f64 * 2.0f64
    bool ready = !false && (2 * 3 == 6)
    int8 converted = int8(bool(1 < 2))
    strg text = "constant"
    list values = [ANSWER, 2 * 3, ["nested"]]
    dict names = ["value": ANSWER + 1]
    type descriptor = int64
    Values reference = null
    int64 zero
}
start {}
)");
        const auto owner = std::find_if(program.classes.begin(), program.classes.end(),
                                       [](const auto& item) { return item.name == "Values"; });
        require(owner != program.classes.end(), "missing Values class");
        const auto& fields = owner->fields;
        require(fields[0].initializer->kind == cwhip::ExpressionKind::Integer &&
                    fields[0].initializer->value == "48", "integer expression was not folded");
        require(fields[1].initializer->value == "18446744073709551615u",
                "uint64 initializer lost its high bit");
        require(fields[2].initializer->value == "0u", "unsigned arithmetic must wrap");
        require(fields[3].initializer->value == "3", "floating arithmetic was not folded");
        require(fields[4].initializer->value == "true", "boolean expression was not folded");
        require(fields[5].initializer->value == "1", "constant conversion was not folded");
        require(!fields.back().initializer, "uninitialized field gained an initializer");
        std::ostringstream ast;
        cwhip::dumpAst(program, ast);
        require(ast.str().find("48") != std::string::npos, "field initializer missing from AST dump");
    }},
    {"field initializers resolve enum scope and inherited constants", [] {
        expectValid(R"(
namespace Settings {
class Base {
    protected:
    enum { VALUE = 7 }
}
class Derived: Base {
    public:
    int64 inherited = VALUE * 2
    int64 qualified = Base.VALUE + 1
    enum { LOCAL = 3 }
    int64 local = LOCAL
    type owner = Derived
}
}
class External { public: int64 number = Settings.Derived.LOCAL }
start { Settings.Derived value() }
)");
        expectDiagnostic(R"(
class Base { private: enum { SECRET = 1 } }
class Derived: Base { public: int64 number = Base.SECRET }
start {}
)", "not accessible");
    }},
    {"field initializers reject runtime dependencies clearly", [] {
        for (const auto* initializer : {
                 "other", "get()", "Factory()", "Factory().VALUE",
                 "[get()]", "[\"value\": get()]", "\"value={other}\""}) {
            expectDiagnostic(
                "class Factory { public: enum { VALUE = 1 } }\n"
                "class Invalid { public: int64 other\n int64 get() { return(1) }\n"
                "int64 field = " + std::string(initializer) + "\n}\nstart {}",
                "field initializer must be a compile-time constant");
        }
        expectDiagnostic("class C { public: int64 value = missing }\nstart {}",
                         "compile-time constant");
        for (const auto* field : {
                 "list value = [get()]", "dict value = [\"key\": get()]",
                 "buffer value = buffer[get()]", "type value = type(get())"}) {
            expectDiagnostic(
                "class C { public: int64 get() { return(1) }\n" +
                    std::string(field) + "\n}\nstart {}",
                "runtime expressions are not allowed");
        }
        expectDiagnostic("class C { public: int64 value = \"text\" }\nstart {}",
                         "cannot initialize int64 field with String");
        expectDiagnostic("class C { public: int64 value = 1.0f64 / 0.0f64 }\nstart {}",
                         "invalid numeric conversion");
    }},
    {"field constant arithmetic rejects domain errors", [] {
        for (const auto& item : {
                 std::pair{"int64 value = 1 / 0", "division by zero"},
                 std::pair{"uint64 value = 1u % 0u", "division by zero"},
                 std::pair{"int64 value = int8(127) + int8(1)", "overflow"},
                 std::pair{"int64 value = 9223372036854775807 + int64(1)",
                           "overflows signed 64-bit range"},
                 std::pair{"int64 value = int64(-9223372036854775808) / int64(-1)",
                           "overflows signed 64-bit range"},
                 std::pair{"int64 value = 1 << -1", "invalid shift count"},
                 std::pair{"int64 value = int64(1) << 64", "invalid shift count"},
                 std::pair{"int64 value = int8(128.0f64)", "invalid numeric conversion"}}) {
            expectDiagnostic("class Invalid { public: " + std::string(item.first) +
                                 "\n}\nstart {}",
                             item.second);
        }
    }},
    {"field initialization lowering precedes constructor calls", [] {
        auto program = parse(R"(
class Base {
    public:
    int64 number = 37
    Base() { number += 1 }
}
class Derived: Base {
    public:
    int64 own = 41
    Derived() { super Base() }
}
start { Derived value() }
)");
        const auto ir = cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(program);
        const auto start = ir.find("define i32 @main(");
        require(start != std::string::npos, "missing main function");
        const auto main = ir.substr(start);
        const auto baseStore = main.find("store i64 37,");
        const auto ownStore = main.find("store i64 41,");
        const auto constructor = main.find("call void @cwhip.Derived.");
        require(baseStore != std::string::npos && ownStore != std::string::npos,
                "inherited/own field stores missing");
        require(constructor != std::string::npos &&
                    baseStore < constructor && ownStore < constructor,
                "initializers must precede constructor bodies");
    }},
}};
} // namespace
