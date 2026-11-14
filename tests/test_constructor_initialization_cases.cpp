#include "test_cases.hpp"

#include <string>

namespace {
using namespace cwhip_test;

const std::string bases =
    "class A { public: A() {} }\nclass B { public: B() {} }\n";

void rejectBody(const std::string& body, const std::string& diagnostic) {
    expectDiagnostic(bases + "class C: A, B { public: C() { " + body + " } }\nstart {}",
                     diagnostic);
}

const TestGroupRegistration registration{3, {
    {"protected base initialization accepts exceptional handlers", [] {
        expectValid(bases +
            "class C: A, B { public: C(bool flag) {\n"
            "try { super A()\n super B() }\n"
            "except(Exception) { if(flag) { raise() } else { "
            "raise(Exception(\"replacement\")) } }\n"
            "finally { print(\"cleanup\") }\n print(\"constructed\") } }\nstart { C c(true) }");
        expectValid(bases +
            "class C: A, B { public: C() { try { super A()\n super B() } "
            "finally { print(\"cleanup\") } } }\nstart { C c() }");
        expectValid(bases +
            "class C: A, B { public: C() { try { super A()\n super B() } "
            "except() { try { raise() } except() { raise() } } } }\nstart {}");
    }},
    {"protected base initialization rejects recovery and returns", [] {
        for (const auto& handler : {
                 "print(\"recovered\")", "return", "return\n raise()",
                 "if(true) { raise() }", "if(true) { return } else { raise() }",
                 "try { raise() } except() { print(\"swallowed\") }",
                 "while(true) { raise() }",
                 "try { return } finally { raise(Exception(\"replacement\")) }"}) {
            rejectBody("try { super A()\n super B() } except() { " +
                           std::string(handler) + " }",
                       "base initialization handler must raise or rethrow");
        }
    }},
    {"protected base initialization preserves sequence boundaries", [] {
        rejectBody("print(1)\n try { super A()\n super B() } except() { raise() }",
                   "must begin with super A");
        rejectBody("try { if(true) { super A() }\n super B() } except() { raise() }",
                   "must contain only ordered super");
        rejectBody("try { while(true) { super A() }\n super B() } except() { raise() }",
                   "must contain only ordered super");
        rejectBody("try { { super A() }\n super B() } except() { raise() }",
                   "must contain only ordered super");
        rejectBody("try { super A()\n print(1)\n super B() } except() { raise() }",
                   "must contain only ordered super");
        rejectBody("try { super A()\n super A()\n super B() } except() { raise() }",
                   "initialized once in declared order");
        rejectBody("try { super B()\n super A() } except() { raise() }",
                   "must initialize base 'A'");
        rejectBody("try { super A() } except() { raise() }",
                   "must initialize base 'B'");
        rejectBody("try { super A()\n super B() } except() { raise() }\n super B()",
                   "must be direct leading constructor");
        rejectBody("try { super A()\n super B() } except() { super B()\n raise() }",
                   "cannot appear in initialization handlers");
        rejectBody("try { super A()\n super B() } finally { super B() }",
                   "cannot appear in initialization finally");
        rejectBody("super A()\n try { super B() } except() { raise() }",
                   "must initialize base 'B'");
        rejectBody("super A()\n super B()\n super A()",
                   "initialized once in declared order");
        rejectBody("super A()\n super B()\n print(1)\n super A()",
                   "must be direct leading constructor");
    }},
    {"protected virtual initialization preserves ownership and ordering", [] {
        const std::string virtualBases =
            "class V { public: V(int64 n) {} }\nclass W { public: W(int64 n) {} }\n"
            "class L: virtual V, virtual W { public: L() {} }\n";
        expectValid(virtualBases +
            "class C: L { public: C() { try { super virtual V(1)\n super virtual W(2)\n"
            "super L() } except() { raise() } } }\nstart { C c() }");
        expectValid(virtualBases +
            "class C: L { public: C() { try { super virtual V(1)\n super virtual W(2)\n"
            "super L() } except() { raise() } } }\nclass D: C { public: D() { super C() } }\nstart {}");
        expectDiagnostic(virtualBases +
            "class C: L { public: C() { try { super virtual V(1)\n super virtual V(2)\n"
            "super L() } except() { raise() } } }\nstart {}",
            "initialized more than once");
        expectDiagnostic(virtualBases +
            "class C: L { public: C() { try { super virtual W(1)\n super virtual V(2)\n"
            "super L() } except() { raise() } } }\nstart {}",
            "must follow virtual-base construction order");
        expectDiagnostic(virtualBases +
            "class C: L { public: C() { try { super L()\n super virtual V(1) } "
            "except() { raise() } } }\nstart {}",
            "must precede direct base");
        expectDiagnostic(virtualBases +
            "class C: L { public: C() { try { super L() } except() { raise() } } }\nstart { C c() }",
            "must initialize virtual base 'V'");
        expectValid(virtualBases +
            "class C: L { public: C() }\n"
            "C C.C() { try { super virtual V(1)\n super virtual W(2)\n super L() } "
            "except() { raise() } }\nstart { C c() }");
    }},
}};
} // namespace
