#include "test_cases.hpp"

#include "cwhip/CodeGenerator.hpp"

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{2, {
    {"parenthesized cast receivers support standalone void method calls", [] {
         expectValid(R"(class Bar {
             public:
             int64 val
             Bar(int64 v) { val = v }
             void show() { print(format("class Bar {}", val)) }
         }
         class Foo {
             public:
             list flarp
             Foo() {
                 flarp = []
                 int64 i = 0
                 while (i <= 10) {
                     flarp.append(Bar(i))
                     i += 1
                 }
             }
         }
         start {
             Foo f()
             (f.flarp[1] as Bar).show()
         })");
     }},
    {"parenthesized noncalls remain invalid expression statements", [] {
         for (const auto& expression : {"(1)", "(1 + 2)", "(b)", "(b.val)",
                                        "(b as Bar)", "(values[0] as Bar)", "(Bar())"}) {
             expectDiagnostic(
                 "class Bar { public: int64 val }\nstart {\n Bar b()\n list values = [b]\n " +
                     std::string(expression) + "\n}",
                 "only method calls may be used as expression statements");
         }
     }},
    {"parenthesized statement routing preserves assignments and ordinary calls", [] {
         expectValid(R"(class Bar { public: int64 val
             void show() {}
             void invoke() { (show()) }
         }
         start {
             Bar b()
             int64 value = 1
             value += 1
             b.val = value
             (b).val += 1
             (b.val) = 3
             (b.show())
             ((b)).show()
             b.show()
         })");
     }},
    {"checked object casts accept class references, null, and collection values", [] {
         expectValid(R"(class Foo { public: int64 read() { return(7) } }
             class Bar : Foo {}
             class Other {}
             start {
                 list values = [Foo(), Bar(), null, 7]
                 dict mapping = ["value": Bar()]
                 Foo exact = values[0] as Foo
                 Foo base = values[1] as Foo
                 Foo empty = null as Foo
                 Foo unrelated = Other() as Foo
                 Foo scalar = values[3] as Foo
                 print((mapping["value"] as Foo).read())
                 print((base as Bar).read())
                 print((Bar() as Foo as Bar).read())
             })");
     }},
    {"checked casts support collection payload types and aliases", [] {
         expectValid(R"(class Foo {}
             start {
                 list values = [1, 2u, true, 3.5, "text", [4], ["x": 5],
                                buffer(1), type(int64), Foo(), null]
                 int64 i = values[0] as int64
                 uint64 u = values[1] as uint64
                 bool b = values[2] as bool
                 fp64 f = values[3] as fp64
                 strg s = values[4] as strg
                 list l = values[5] as list
                 dict d = values[6] as dict
                 buffer bytes = values[7] as buffer
                 type descriptor = values[8] as type
                 Foo object = values[9] as Foo
                 print(i)
                 print(u)
                 print(b)
                 print(f)
                 print(s)
                 print(l.length)
                 print(d.length)
                 print(bytes.length)
                 print(descriptor)
                 print(object is Foo)
                 print(type(values[10] as null))
                 print(values[10] as any)
                 strg alias = values[4] as String
                 print(alias)
             })");
     }},
    {"checked casts reject impossible sources and targets", [] {
         expectDiagnostic("class Foo {}\nstart { print(1 as Foo) }",
                          "checked cast from 'int8' to 'Foo' is impossible");
         expectDiagnostic("class Foo {}\nstart { print(Foo() as int64) }",
                          "checked cast from 'Foo' to 'int64' is impossible");
         expectDiagnostic("class Foo {}\nstart { print(Foo() as void) }",
                          "checked cast target 'void' is not supported");
         expectDiagnostic("class Foo {}\nstart { print(Foo() as Missing) }",
                          "unknown type name 'Missing'");
         expectDiagnostic("class Foo {}\nstart { print(null is null) }",
                          "expected type name after 'is'");
         expectDiagnostic("class Foo { public: void noValue() {} }\n"
                          "start { print(Foo().noValue() as int64) }",
                          "checked cast does not support source type 'void'");
         expectDiagnostic("class Foo {}\nstart { print(Foo() as) }",
                          "expected type name after 'as'");
         expectDiagnostic("class Foo {}\nstart { Foo value = Foo(Foo()) }",
                          "constructor");
     }},
    {"checked object casts normalize qualified namespace targets", [] {
         expectValid(R"(namespace model {
             class Foo { public: int64 read() { return(7) } }
             class Casts {
                 public:
                 Foo convert(list values) { return(values[0] as Foo) }
             }
         }
         start { print(([model.Foo()][0] as model.Foo).read()) })");
     }},
    {"checked object casts have postfix precedence and compose with calls", [] {
         auto program = parse(R"(class Foo { public: int64 read() { return(7) } }
             start { print(([Foo()][0] as Foo).read() + 1) })");
         const auto& sum = *program.statements.front().expressions.front();
         require(sum.kind == cwhip::ExpressionKind::Binary, "addition must be outside cast");
         require(sum.left->kind == cwhip::ExpressionKind::Call, "cast must compose with call");
         const auto& cast = *sum.left->left->left;
         require(cast.kind == cwhip::ExpressionKind::ObjectCast, "expected explicit object cast");
         require(cast.left->kind == cwhip::ExpressionKind::Index, "index must bind before cast");
         const auto ir = cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(program);
         require(ir.find("call ptr @cwhip_value_cast_class") != std::string::npos,
                 "cast must invoke returning runtime check");
     }},
}};
} // namespace
