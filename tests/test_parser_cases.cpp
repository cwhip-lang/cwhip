#include "test_cases.hpp"

#include "cwhip/Diagnostic.hpp"
#include "cwhip/CodeGenerator.hpp"
#include "cwhip/Lexer.hpp"
#include "cwhip/Parser.hpp"
#include "cwhip/Token.hpp"

#include <algorithm>
#include <limits>
#include <sstream>
#include <string>
#include <vector>

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{1, {
        {"deep recursive syntax produces a nesting diagnostic", [] {
             const auto rejected = [](const std::string& source) {
                 try {
                     cwhip::Lexer lexer(source, "nesting.cw");
                     (void)cwhip::Parser(lexer.tokenize()).parseProgram(false);
                 } catch (const cwhip::DiagnosticError& error) {
                     require(std::string(error.what()).find("parser nesting exceeds 128") !=
                                 std::string::npos,
                             "deep syntax produced the wrong diagnostic");
                     return;
                 }
                 throw std::runtime_error("deep syntax was not rejected");
             };
             rejected("start { print(" + std::string(4000, '(') + "1" +
                      std::string(4000, ')') + ") }");
             rejected("start { print(" + std::string(4000, '-') + "1) }");
             rejected("start { print(" + std::string(4000, '!') + "true) }");
             rejected("start {" + std::string(4000, '{') + std::string(4000, '}') + "}");
             std::string namespaces;
             std::string calls;
             for (int index = 0; index < 1000; ++index) {
                 namespaces += "namespace N {";
                 calls += "f(";
             }
             rejected(namespaces + std::string(1000, '}'));
             rejected("start { print(" + calls + "1" + std::string(1000, ')') + ") }");
         }},
        {"ordinary nested syntax remains accepted", [] {
             cwhip::Lexer lexer("start { print(" + std::string(100, '(') + "1" +
                               std::string(100, ')') + ") }", "nesting.cw");
             (void)cwhip::Parser(lexer.tokenize()).parseProgram();
         }},
        {"conditional else clauses form nested if branches", [] {
             const auto program = parse(
                 "start {\n"
                 " if (false) {}\n"
                 " else (true) {}\n"
                 " else {}\n"
                 "}\n");
             const auto& first = program.statements.front();
             require(first.kind == cwhip::StatementKind::If &&
                         first.hasAlternate && first.alternate.size() == 1,
                     "first conditional branch is missing its alternate");
             const auto& second = first.alternate.front();
             require(second.kind == cwhip::StatementKind::If &&
                         second.hasAlternate && second.alternate.empty() &&
                         second.expressions.front()->location.line == 3 &&
                         second.location.line == 3,
                     "conditional else branch or its source location is incorrect");
             expectDiagnostic("start {\n if (false) {}\n else {}\n else (true) {}\n}",
                              "unconditional 'else' must be the final clause");
             expectDiagnostic("start { if (false) {} else if (true) {} }",
                              "expected '{'");
             expectDiagnostic("start { if (false) {} else () {} }",
                              "expected expression");
         }},
        {"flat expression and inline capture chains have bounded AST depth", [] {
             std::string addition = "1";
             std::string members = "value";
             for (int index = 0; index < 7000; ++index) {
                 addition += "+1";
                 members += ".field";
             }
             const auto rejected = [](const std::string& source) {
                 try {
                     cwhip::Lexer lexer(source, "tree-depth.cw");
                     (void)cwhip::Parser(lexer.tokenize()).parseProgram();
                 } catch (const cwhip::DiagnosticError& error) {
                     require(std::string(error.what()).find("expression tree depth exceeds 128") !=
                                 std::string::npos,
                             "deep expression tree produced the wrong diagnostic");
                     return;
                 }
                 throw std::runtime_error("deep expression tree was not rejected");
             };
             rejected("start { print(" + addition + ") }");
             rejected("start { print(" + members + ") }");
             rejected("start { inline(int64 " + members + ") {} }");
             std::string accepted = "1";
             for (int index = 0; index < 127; ++index) accepted += "+1";
             cwhip::Lexer lexer("start { print(" + accepted + ") }", "tree-depth.cw");
             (void)cwhip::Parser(lexer.tokenize()).parseProgram();
             rejected("start { print(" + accepted + "+1) }");
             std::string wideList = "1";
             for (int index = 0; index < 1000; ++index) wideList += ",1";
             cwhip::Lexer wideLexer("start { list values = [" + wideList + "] }",
                                   "wide-list.cw");
             (void)cwhip::Parser(wideLexer.tokenize()).parseProgram();
         }},
        {"top-level import syntax is represented in the AST", [] {
             cwhip::Lexer lexer("import network as Net\nstart {}", "import.cw");
             auto program = cwhip::Parser(lexer.tokenize()).parseProgram();
             require(program.imports.size() == 1 &&
                         program.imports.front().moduleName == "network" &&
                         program.imports.front().alias == "Net",
                     "import module name or alias missing from AST");
         }},
        {"import without an alias defers its binding to the package export", [] {
             cwhip::Lexer lexer("import network\nstart {}", "import.cw");
             const auto program = cwhip::Parser(lexer.tokenize()).parseProgram();
             require(program.imports.size() == 1 &&
                         program.imports.front().moduleName == "network" &&
                         program.imports.front().alias.empty(),
                     "an omitted alias must be resolved from the manifest export");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("Import [network]\n") != std::string::npos,
                     "AST output must not invent an empty explicit alias");
             expectDiagnostic("import network as\nstart {}", "expected import alias");
         }},
        {"import is rejected in declaration and function bodies", [] {
             expectDiagnostic("namespace Hidden { import network as Net }\nstart {}",
                              "'import' is only allowed at top level");
             expectDiagnostic("class Hidden { import network as Net }\nstart {}",
                              "'import' is only allowed at top level");
             expectDiagnostic("start { import network as Net }",
                              "'import' is only allowed at top level");
         }},
        {"create is no longer a reserved keyword", [] {
             cwhip::Lexer lexer("start {\n int64 create = 1\n print(create)\n}", "identifier.cw");
             const auto tokens = lexer.tokenize();
             require(tokens[4].type == cwhip::TokenType::Identifier &&
                         tokens[4].text == "create",
                     "create should be lexed as an identifier");
         }},
        {"strg is the primitive string type and string remains an identifier", [] {
             expectValid("class string { string() {} }\n"
                         "class Text { strg echo(strg value) { return(value) } }\n"
                         "start {\n strg text = Text().echo(\"value\")\n"
                         " int64 string = 1\n string custom = string()\n print(string)\n}");
             expectDiagnostic("start {\n string text = \"value\"\n}",
                              "unknown type or class 'string'");
         }},
        {"class-name constructor syntax", [] {
             const auto program = parse(
                 "class Box { Box() {} }\nstart { Box box = Box() }");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("ConstructorCall [Box]") != std::string::npos,
                     "class-name constructor call missing from AST");
         }},
        {"callable types use nested angle syntax and retain canonical signatures", [] {
             const auto program = parse(
                 "namespace Model { class Item {} }\n"
                 "class Worker {\n"
                 " int64 echo(int32 value) { return(value) }\n"
                 " range<int64> same(range<int64> value) { return(value) }\n"
                 " Model.Item echoItem(Model.Item value) { return(value) }\n"
                 " int64<int64<int64>> nested(int64<int64<int64>> value)\n"
                 "}\n"
                 "int64<int64<int64>> Worker.nested(int64<int64<int64>> value) {\n"
                 " return(value)\n"
                 "}\n"
                 "class CallableFields {\n"
                 " int64<int32,int8> multi\n"
                 " int64<> empty\n"
                 " int64<int64><String> nestedReturn\n"
                 " int64<range<int64>> rangeArgument\n"
                 " range<int64><range<int64><int64>> rangeClosure\n"
                 " Model.Item<Model.Item> classArgument\n"
                 " void<> noValue\n"
                 "}\n"
                 "start {\n"
                 " Worker worker = Worker()\n"
                 " int64<int32> action = worker.echo\n"
                 " bool comparison = 1 < 2\n"
                 " int64 shifted = 8 >> 1\n"
                 " int casted = int(1)\n"
                 " uint unsignedValue = uint(1u)\n"
                 " float floating = float(1.5)\n"
                 "}\n");
             const auto fields = std::find_if(
                 program.classes.begin(), program.classes.end(),
                 [](const auto& declaration) { return declaration.name == "CallableFields"; });
             require(fields != program.classes.end() && fields->fields.size() == 7,
             "callable fields missing from the parsed class");
             const std::vector<std::string> expected{
                 "callback<int64(int32,int8)>", "callback<int64()>",
                 "callback<callback<int64(int64)>(String)>",
                 "callback<int64(range<int64>)>",
                 "callback<range<int64>(callback<range<int64>(int64)>)>",
                 "callback<Model.Item(Model.Item)>", "callback<void()>"};
             for (std::size_t index = 0; index < expected.size(); ++index) {
                 require(fields->fields[index].type == expected[index],
                 "callable source type did not normalize to its canonical signature");
             }
             expectDiagnostic("class Invalid { int64<void> invalid }\nstart {}",
                      "expected type name");
             expectDiagnostic("start {\n int64 left = 1\n int64 right = 2\n"
                                  " left < right\n}\n",
                              "only method calls may be used as expression statements");
         }},
         {"class-scoped anonymous enum members parse and resolve as signed integers", [] {
              const auto program = parse(
                  "class Values {\n"
                  " enum { FIRST = 40 + 2, NEXT, TWICE = FIRST * 2, }\n"
                  " enum { ZERO, MIN = -0x8000000000000000, MAX = 0x7fffffffffffffff }\n"
                  " int64 read() { return(FIRST) }\n"
                  "}\nstart {}");
              const auto values = std::find_if(
                  program.classes.begin(), program.classes.end(),
                  [](const auto& declaration) { return declaration.name == "Values"; });
              require(values != program.classes.end() && values->enumMembers.size() == 6,
                      "enum members missing from the class AST");
              require(values->enumMembers[0].value == 42 &&
                          values->enumMembers[1].value == 43 &&
                          values->enumMembers[2].value == 84 &&
                          values->enumMembers[3].value == 0 &&
                          values->enumMembers[4].value ==
                              std::numeric_limits<std::int64_t>::min() &&
                          values->enumMembers[5].value ==
                              std::numeric_limits<std::int64_t>::max(),
                      "enum numbering or signed endpoint resolution is incorrect");
          }},
        {"enum constants add no fields to generated object layout", [] {
              const auto program = parse(
                  "class Values { enum { FIRST = 3 } }\n"
                  "start { Values value = Values()\n print(value.FIRST) }");
              const auto ir =
                  cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(program);
              require(ir.find("%Class.Values = type { ptr, ptr }") != std::string::npos,
                      "enum constants added instance storage");
          }},
         {"enum constants obey access, inheritance, and immutability rules", [] {
              expectValid(
                  "class Base { public: enum { VALUE = 7 } }\n"
                  "class Child : Base { int64 read() { return(VALUE) } }\n"
                  "start { Child child = Child()\n print(child.VALUE)\n"
                  " print(child.Base.VALUE) }\n");
              expectDiagnostic(
                  "class Box { protected: enum { VALUE = 7 } }\n"
                  "start { Box box = Box()\n print(box.VALUE) }",
                  "not accessible");
              expectDiagnostic(
                  "class Box { private: enum { VALUE = 7 } }\n"
                  "start { print(Box.VALUE) }",
                  "not accessible");
              expectDiagnostic(
                  "class Base { enum { VALUE = 7 } }\n"
                  "class Hidden : private Base {}\n"
                  "start { Hidden hidden = Hidden()\n print(hidden.VALUE) }",
                  "not accessible through this inheritance path");
              expectDiagnostic(
                  "class Box { enum { VALUE = 7 } }\n"
                  "start { Box.VALUE = 8 }",
                  "enum constants are immutable");
              expectDiagnostic(
                  "class Box { enum { VALUE = 7 } }\n"
                  "start { Box box = Box()\n box.VALUE += 1 }",
                  "enum constants are immutable");
              expectDiagnostic(
                  "class Box { enum { VALUE = 7 }\n"
                  " void update() { inline (int64 VALUE) {} } }\nstart {}",
                  "enum constants are immutable");
              expectDiagnostic(
                  "class Left { enum { VALUE = 1 } }\n"
                  "class Right { enum { VALUE = 2 } }\n"
                  "class Both : Left, Right {}\n"
                  "start { Both both = Both()\n print(both.VALUE) }",
                  "ambiguous inherited member");
          }},
         {"enum constants reject collisions and invalid values", [] {
              expectDiagnostic("class Box { enum { VALUE, VALUE } }\nstart {}",
                               "duplicate enum member");
              expectDiagnostic("class Box { int64 VALUE\nenum { VALUE } }\nstart {}",
                               "collides with another class member");
              expectDiagnostic("class Box { void VALUE() {}\nenum { VALUE } }\nstart {}",
                               "collides with another class member");
              expectDiagnostic(
                  "class Base { enum { VALUE } }\nclass Derived : Base { int64 VALUE }\nstart {}",
                  "collides with an inherited enum member");
              expectDiagnostic(
                  "class Base { enum { VALUE } }\n"
                  "class Derived : Base { int64 VALUE() { return(1) } }\nstart {}",
                  "collides with an inherited enum member");
              expectDiagnostic("class Box { enum { FIRST = LATER, LATER = 3 } }\nstart {}",
                               "cannot reference a later or cyclic");
              expectDiagnostic(
                  "class First { enum { VALUE = Second.NEXT } }\n"
                  "class Second { enum { NEXT = First.VALUE } }\nstart {}",
                  "cyclic enum constant reference");
              expectDiagnostic("class Box { enum { VALUE = call() } }\nstart {}",
                               "compile-time integer expression");
              expectDiagnostic("class Box { enum { VALUE = 1 / 0 } }\nstart {}",
                               "division by zero");
              expectDiagnostic(
                  "class Box { enum { VALUE = 0x7fffffffffffffff, NEXT } }\nstart {}",
                  "implicit enum value overflows");
              expectDiagnostic(
                  "class Box { enum { VALUE = 0x7fffffffffffffff + 1 } }\nstart {}",
                  "overflows signed 64-bit range");
          }},
        {"direct constructor declarations reuse constructor-call analysis", [] {
             const auto program = parse(
                 "class Box {\n"
                 "  Box() {}\n"
                 "  Box(int64 value) {}\n"
                 "}\n"
                 "start {\n"
                 "  Box empty()\n"
                 "  Box filled(42)\n"
                 "}");
             const auto& empty = program.statements[0];
             const auto& filled = program.statements[1];
             require(empty.kind == cwhip::StatementKind::Declaration &&
                         empty.expressions.size() == 1 &&
                         empty.expressions.front()->kind ==
                             cwhip::ExpressionKind::ConstructorCall &&
                         !empty.expressions.front()->resolvedSignature.empty(),
                     "zero-argument declaration did not preserve constructor-call AST");
             require(filled.kind == cwhip::StatementKind::Declaration &&
                         filled.expressions.size() == 1 &&
                         filled.expressions.front()->kind ==
                             cwhip::ExpressionKind::ConstructorCall &&
                         !filled.expressions.front()->resolvedSignature.empty(),
                     "overloaded declaration did not record selected constructor");
         }},
        {"direct constructor declarations reject invalid construction", [] {
             expectDiagnostic(
                 "class Box { Box(int64 value) {} }\nstart { Box item() }",
                 "constructor argument count does not match class 'Box'");
             expectDiagnostic(
                 "class Box { Box(int64 value) {} }\nstart { Box item(\"wrong\") }",
                 "constructor argument type does not match parameter 'value'");
             expectDiagnostic(
                 "class Secret { private: Secret() {} }\nstart { Secret item() }",
                 "constructor for class 'Secret' is not accessible here");
             expectDiagnostic("start { Missing item() }",
                              "unknown type or class 'Missing'");
             expectDiagnostic("start { int64 value() }",
                              "expected newline after statement");
         }},
        {"single inheritance and base constructor syntax", [] {
             const auto program = parse(
                 "class Base { Base(int64 value) {} }\n"
                 "class Child : Base { Child(int64 value) { super Base(value) } }\n"
                 "start { Child child = Child(1) }");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("Class [Child : public Base]") != std::string::npos,
                     "base class missing from AST");
             require(output.str().find("Super constructor [Base]") != std::string::npos,
                     "explicit base constructor missing from AST");
         }},
        {"virtual base initializer syntax", [] {
             const auto program = parse(
                 "class Root { Root(int64 value) {} }\n"
                 "class Leaf : virtual Root {\n"
                 "  Leaf(int64 value) { virtual super Root(value) }\n"
                 "}\n"
                 "start { Leaf leaf = Leaf(1) }");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("Super virtual constructor [Root]") !=
                         std::string::npos,
                     "virtual base initializer missing from AST");
         }},
        {"dotless base initializer modifier orders", [] {
             const auto program = parse(
                 "class Root { Root(int64 value) {} }\n"
                 "class First : virtual Root {\n"
                 "  First(int64 value) { super virtual Root(value) }\n"
                 "}\n"
                 "class Second : virtual Root {\n"
                 "  Second(int64 value) { virtual super Root(value) }\n"
                 "}\n"
                 "start { First first = First(1)\n Second second = Second(2) }");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             const auto tree = output.str();
             const auto first = tree.find("Super virtual constructor [Root]");
             require(first != std::string::npos &&
                         tree.find("Super virtual constructor [Root]", first + 1) !=
                             std::string::npos,
                     "both virtual initializer modifier orders should appear in the AST");
         }},
        {"dotted base initializer syntax is rejected", [] {
             expectDiagnostic(
                 "class Base {}\n"
                 "class Child : Base { Child() { super.Base() } }\n"
                 "start {}",
                 "base class name after super");
             expectDiagnostic(
                 "class Root {}\n"
                 "class Leaf : virtual Root { Leaf() { super.virtual Root() } }\n"
                 "start {}",
                 "base class name after super");
         }},
        {"malformed virtual base initializer modifier order is rejected", [] {
             expectDiagnostic(
                 "class Root {}\n"
                 "class Leaf : virtual Root { Leaf() { virtual Root() } }\n"
                 "start {}",
                 "'super' after virtual");
         }},
        {"virtual base syntax is retained in AST", [] {
             const auto program = parse(
                 "class Root {}\n"
                 "class Left : public virtual Root {}\n"
                 "class Other : virtual public Root {}\n"
                 "start {}");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("Class [Left : public virtual Root]") !=
                         std::string::npos,
                     "virtual base modifier missing from AST");
             require(output.str().find("Class [Other : public virtual Root]") !=
                         std::string::npos,
                     "virtual/access modifier ordering was not accepted");
         }},
        {"parser precedence and AST", [] {
             const auto program = parse("start {\n int64 x = 1 + 2 * 3\n print(x)\n}");
             require(program.statements.size() == 2, "expected declaration and print");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             const auto tree = output.str();
             require(tree.find("Binary [+]") != std::string::npos, "addition absent from AST");
             require(tree.find("Binary [*]") != std::string::npos, "multiplication absent from AST");
         }},
        {"compound assignments are assignment statements in the AST", [] {
             cwhip::Lexer lexer(
                 "start {\n int64 value = 12\n value += 1\n value -= 1\n value *= 2\n"
                 " value /= 2\n value %= 3\n}",
                 "compound-assignment.cw");
             const auto program = cwhip::Parser(lexer.tokenize()).parseProgram();
             require(program.statements.size() == 6,
                     "compound assignments did not parse as separate statements");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             for (const auto* operation : {"+=", "-=", "*=", "/=", "%="}) {
                 require(output.str().find("Assignment [" + std::string(operation) + "]") !=
                             std::string::npos,
                         "compound assignment operator missing from AST");
             }
         }},
        {"dict literals are represented in the AST", [] {
             const auto program = parse(
                 "start {\n dict values = [\"answer\": 42]\n}");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("MapLiteral") != std::string::npos,
                     "dict literal missing from AST");
         }},
        {"buffer literals are expressions and preserve bare buffer type values", [] {
             const auto program = parse(
                 "start {\n"
                 "  buffer empty = buffer[]\n"
                 "  buffer bytes = buffer[1, 2u]\n"
                 "  type bufferType = buffer\n"
                 "  print(bytes[0])\n"
                 "}");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("BufferLiteral") != std::string::npos &&
                         output.str().find("TypeName [buffer]") != std::string::npos &&
                         output.str().find("ArrayLiteral") == std::string::npos,
                     "buffer literals, bare type values, or list distinction were not preserved");
         }},
        {"buffer literals reject non-integer element types", [] {
             expectDiagnostic("start { buffer bytes = buffer[true] }",
                              "buffer literal elements must have an integer type");
             expectDiagnostic("start { buffer bytes = buffer[1.5] }",
                              "buffer literal elements must have an integer type");
             expectDiagnostic("start { buffer bytes = buffer[\"byte\"] }",
                              "buffer literal elements must have an integer type");
         }},
        {"raise, catch-all, and finally syntax", [] {
             const auto program = parse(
                 "class Failure : Exception {\n"
                 "  Failure(strg text) { super Exception(text) }\n"
                 "}\n"
                 "start {\n"
                 "  try { raise(Failure(\"failure\")) } except() { print(\"caught\") } "
                 "finally { print(\"done\") }\n"
                 "}");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("Try") != std::string::npos &&
                         output.str().find("Raise") != std::string::npos &&
                         output.str().find("Except") != std::string::npos &&
                         output.str().find("Finally") != std::string::npos,
                     "exception constructs missing from AST");
         }},
        {"except may bind a read-only exception string", [] {
             const auto program = parse(
                 "start {\n try { raise(Exception(\"message\")) } "
                 "except() as error { print(error) }\n}");
             const auto& handlers = program.statements.front().exceptionHandlers;
             require(handlers.size() == 1 && handlers.front().hasBinding &&
                         handlers.front().name == "error",
                     "except binding missing from AST");
         }},
        {"try supports ordered typed exception clauses", [] {
             const auto program = parse(
                 "class Parent : Exception { Parent(strg text) { super Exception(text) } }\n"
                 "class Child : Parent { Child(strg text) { super Parent(text) } }\n"
                 "start {\n"
                 " try { raise(Child(\"message\")) }\n"
                 " except(Parent) as parent { print(parent.message) }\n"
                 " except() { print(\"fallback\") }\n"
                 " finally { print(\"done\") }\n"
                 "}");
             const auto& handlers = program.statements.front().exceptionHandlers;
             require(handlers.size() == 2 && handlers[0].exceptionType == "Parent" &&
                         handlers[0].hasBinding && handlers[1].exceptionType.empty(),
                     "ordered except clauses missing from AST");
         }},
        {"catch-all exception clause must be last", [] {
             expectDiagnostic(
                 "start {\n try { print(1) }\n"
                 " except() { print(2) }\n"
                 " except(Exception) { print(3) }\n}",
                 "catch-all except clause must be last");
         }},
        {"duplicate catch-all exception clauses are rejected", [] {
             expectDiagnostic(
                 "start {\n try { print(1) }\n"
                 " except() { print(2) }\n"
                 " except() { print(3) }\n}",
                 "duplicate catch-all except clause");
         }},
        {"subclass exception clause after base is unreachable", [] {
             expectDiagnostic(
                 "class Parent : Exception { Parent(strg text) { super Exception(text) } }\n"
                 "class Child : Parent { Child(strg text) { super Parent(text) } }\n"
                 "start {\n try { print(1) }\n"
                 " except(Parent) { print(2) }\n"
                 " except(Child) { print(3) }\n}",
                 "unreachable after earlier 'Parent' clause");
         }},
        {"catch-all after Exception clause is unreachable", [] {
             expectDiagnostic(
                 "start {\n try { print(1) }\n"
                 " except(Exception) { print(2) }\n"
                 " except() { print(3) }\n}",
                 "catch-all except clause is unreachable after 'Exception'");
         }},
        {"try requires a handler or finally", [] {
             expectDiagnostic("start { try { print(1) } }",
                              "requires an 'except' or 'finally' block");
         }},
        {"except requires parenthesized filter", [] {
             expectDiagnostic("start { try { print(1) } except { print(2) } }",
                              "'(' after except");
             expectDiagnostic("start { try { print(1) } except as error { print(error) } }",
                              "'(' after except");
             expectDiagnostic("start { try { print(1) } except Exception { print(2) } }",
                              "'(' after except");
             expectDiagnostic("start { try { print(1) } except Exception as error { print(error.message) } }",
                              "'(' after except");
             expectDiagnostic("start { try { print(1) } except(Exception { print(2) } }",
                              "')' after exception class name");
         }},
        {"except accepts qualified class paths", [] {
             const auto program = parse(
                 "namespace errors {\n"
                 " class Failure : Exception { Failure(strg text) { super Exception(text) } }\n"
                 "}\n"
                 "start { try { raise(errors.Failure(\"message\")) } "
                 "except(errors.Failure) as caught { print(caught.message) } }\n");
             const auto& handlers = program.statements.front().exceptionHandlers;
             require(handlers.size() == 1 &&
                         handlers.front().exceptionType == "errors.Failure" &&
                         handlers.front().hasBinding,
                     "qualified exception filter missing from AST");
         }},
        {"raise requires a concrete exception constructor", [] {
             expectDiagnostic("start { raise(\"message\") }",
                              "raise requires a constructor expression");
             expectDiagnostic("start { raise(null) }",
                              "raise requires a constructor expression");
        }},
        {"raise without an expression requires an active handler", [] {
             expectDiagnostic("start { raise() }",
                              "raise() is only valid inside an except handler");
         }},
        {"newline statement boundaries", [] {
             const auto program = parse(
                 "class Base {\n"
                 "  int64 value\n"
                 "  Base(int64 initial) {\n"
                 "    value = initial\n"
                 "  }\n"
                 "}\n"
                 "class Child : Base {\n"
                 "  Child(int64 initial) {\n"
                 "    super Base(initial)\n"
                 "  }\n"
                 "  int64 read() {\n"
                 "    return(value)\n"
                 "  }\n"
                 "}\n"
                 "start {\n"
                 "  Child child = Child(40)\n"
                 "  child.value = child.read() + 2\n"
                 "  print(child.value)\n"
                 "}");
             require(program.statements.size() == 3,
                     "expected semicolon-free declarations, assignment, and print");
         }},
        {"adjacent statements without a boundary are rejected", [] {
             expectDiagnostic("start {\n int64 first = 1 int64 second = 2\n}",
                              "expected newline after statement");
         }},
        {"const prefixes a local declaration", [] {
             const auto program = parse(
                 "class Box {\n"
                 " Box(int64 initial) {\n"
                 "  const int64 seed = initial\n"
                 " }\n"
                 " int64 read() {\n"
                 "  const int64 amount\n"
                 "  amount = 1\n"
                 "  return(amount)\n"
                 " }\n"
                 "}\n"
                 "start {\n"
                 " const int64 fixed = 1\n"
                 " const int64 later\n"
                 " const Box item(2)\n"
                 " Box plain(3)\n"
                 "}");
             require(program.statements.size() == 4, "start declarations missing");
             require(program.statements[0].constant &&
                         program.statements[0].declaredType == "int64" &&
                         program.statements[0].name == "fixed" &&
                         program.statements[0].expressions.size() == 1,
                     "initialized const local missing");
             require(program.statements[1].constant &&
                         program.statements[1].expressions.empty() &&
                         program.statements[1].name == "later",
                     "bare const local missing");
             require(program.statements[2].constant &&
                         program.statements[2].name == "item" &&
                         program.statements[2].expressions.size() == 1 &&
                         program.statements[2].expressions.front()->kind ==
                             cwhip::ExpressionKind::ConstructorCall,
                     "const constructor declaration missing");
             require(!program.statements[3].constant && program.statements[3].name == "plain",
                     "ordinary local was marked const");
             const auto box = std::find_if(program.classes.begin(), program.classes.end(),
                 [](const auto& declaration) { return declaration.name == "Box"; });
             require(box != program.classes.end(), "Box class missing");
             const auto& methods = box->methods;
             require(methods.size() == 2 && methods[0].constructor &&
                         methods[0].body.front().constant &&
                         methods[1].body.front().constant &&
                         methods[1].body.front().expressions.empty(),
                     "const locals missing from constructor or method");
             std::ostringstream output;
             cwhip::dumpAst(program, output);
             require(output.str().find("Declaration [const int64 fixed]") != std::string::npos,
                     "const flag missing from AST dump");
         }},
        {"parser trace", [] {
             cwhip::Lexer lexer("start {}", "trace.cw");
             std::ostringstream trace;
             cwhip::Parser parser(lexer.tokenize(), &trace);
             parser.parseProgram();
             require(trace.str().find("[parser]") != std::string::npos, "parser trace was empty");
         }}
}};

} // namespace
