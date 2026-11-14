#include "test_cases.hpp"

#include <algorithm>

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{1, {
    {"inline capture paths preserve the C parameter name", [] {
        auto program = parse(
            "class Base { public: int64 value }\n"
            "class Child : Base {\n"
            " public:\n void update() {\n"
            "  inline (int64 Base.value) { *value = 7; }\n"
            "  int64 value = 1\n"
            "  inline (int64 .value) { *value += 2; }\n"
            "  inline (int64 value) { *value = 3; }\n"
            " }\n}\nstart {}");
        const auto child = std::find_if(program.classes.begin(), program.classes.end(),
            [](const auto& owner) { return owner.name == "Child"; });
        require(child != program.classes.end(), "Child class missing");
        const auto& body = child->methods[0].body;
        require(body.size() == 4, "capture statements missing");
        require(body[0].inlineCaptures[0].name == "value" &&
                    body[0].inlineCaptures[0].target->kind == cwhip::ExpressionKind::Member,
                "qualified field capture AST missing");
        require(body[2].inlineCaptures[0].target->left->kind ==
                    cwhip::ExpressionKind::ImplicitThis &&
                    body[3].inlineCaptures[0].target->kind == cwhip::ExpressionKind::Identifier,
                "explicit receiver or local precedence lost");
    }},
    {"inline captures use field access checks and exact types", [] {
        expectDiagnostic(
            "class Base { private: int64 value }\n"
            "class Child : Base { public: void update() { inline (int64 value) {} } }\nstart {}",
            "field 'value' is not accessible");
        expectDiagnostic(
            "class Base { private: int64 value }\n"
            "class Child : Base { public: void update() { inline (int64 Base.value) {} } }\nstart {}",
            "field 'value' is not accessible");
        expectDiagnostic(
            "class A { public: int64 value }\nclass B { public: int64 value }\n"
            "class C : A, B { public: void update() { inline (int64 value) {} } }\nstart {}",
            "ambiguous inherited field 'value'");
        expectDiagnostic(
            "class Box { public: int64 value\nvoid update() { inline (fp64 value) {} } }\nstart {}",
            "inline capture type 'fp64' does not match int64");
        expectDiagnostic("start { inline (int64 .value) {} }",
                         "instance field inline capture requires an instance context");
        expectDiagnostic("start { inline (int64 value) {} }", "undefined inline capture");
        expectDiagnostic("start {\n const int64 value = 1\n inline (int64 value) {}\n}",
                         "const variable 'value' cannot be captured by inline C");
        expectDiagnostic("start {\n const int64 value inline {}\n}",
                         "const variable 'value' cannot be captured by inline C");
        expectValid("start {\n int64 value = 1\n inline (int64 value) { *value = 2; }\n}");
        expectDiagnostic(
            "class Box { public: int64 value }\nstart { Box box = Box()\n"
            " inline (int64 box.value) {} }",
            "instance field inline capture requires an instance context");
        expectDiagnostic(
            "class Box { public: int64 value\nvoid update(Box other) { inline (int64 other.value) {} } }\n"
            "start {}",
            "qualified inline capture must name an instance field");
        expectDiagnostic(
            "class Inner { public: int64 value }\n"
            "class Outer { public: Inner item\nvoid update() { inline (int64 .item.value) {} } }\n"
            "start {}",
            "inline capture field path must contain only base classes");
        expectDiagnostic(
            "class A { public: int64 value }\nclass B : A {\n"
            " public:\n void update() { inline (int64 value, int64 A.value) {} }\n}\nstart {}",
            "duplicate inline capture 'value'");
        expectDiagnostic("start { inline (int64 .) {} }", "expected capture name");
        expectDiagnostic(
            "class Box { public: int64 value\nvoid update() { inline (int64 .missing) {} } }\nstart {}",
            "has no field 'missing'");
    }},
    {"inline fields respect private inheritance and parameter shadowing", [] {
        expectDiagnostic(
            "class A { public: int64 value }\nclass B : private A {}\n"
            "class C : B { public: void update() { inline (int64 B.A.value) {} } }\nstart {}",
            "field 'value' is not accessible");
        expectValid(
            "class A { private: int64 value }\nclass B : A {\n"
            " public:\n void update(fp64 value) { inline (fp64 value) { *value += 1.0; } }\n"
            "}\nstart {}");
        expectValid(
            "namespace N {\nclass Base { public: int64 value }\n"
            "class Child : Base { public: void update() { inline (int64 N.Base.value) {} } }\n"
            "}\nstart {}");
    }},
}};
}
