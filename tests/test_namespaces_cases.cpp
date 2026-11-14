#include "test_cases.hpp"

#include "cwhip/Diagnostic.hpp"
#include "cwhip/Lexer.hpp"
#include "cwhip/Parser.hpp"
#include "cwhip/Token.hpp"

#include <algorithm>
#include <sstream>
#include <string>
#include <vector>

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{5, {
        {"namespace keyword is case-insensitive and reserved", [] {
              cwhip::Lexer lexer("NaMeSpAcE Foo { class Thing {} }\nstart {}",
                                "namespace-keyword.cw");
              const auto tokens = lexer.tokenize();
              require(tokens.front().type == cwhip::TokenType::Namespace,
                      "namespace keyword was not recognized case-insensitively");
              expectDiagnostic("start {\n int64 Namespace = 1\n}",
                               "keywords are reserved");
         }},
         {"namespace declarations require single identifiers and reopen", [] {
              const auto program = parse(
                  "namespace Alpha { namespace Beta { class First {} } }\n"
                  "namespace Alpha { namespace Beta { class Second {} } }\n"
                  "start {}");
              std::vector<std::string> declaredClasses;
              for (const auto& declaration : program.classes) {
                  if (!declaration.builtin && declaration.name != "String")
                      declaredClasses.push_back(declaration.name);
              }
              require(declaredClasses.size() == 2 &&
                          declaredClasses[0] == "Alpha.Beta.First" &&
                          declaredClasses[1] == "Alpha.Beta.Second",
                      "reopened nested namespace class paths were not merged");
              expectDiagnostic("namespace Alpha.Beta { }\nstart {}",
                               "expected '{' after namespace name");
         }},
         {"out-of-line methods resolve within their namespace", [] {
              expectValid(
                  "namespace Remote {\n"
                  "  class Method { public: int64 value() }\n"
                  "  int64 Method.value() { return(42) }\n"
                  "}\n"
                  "start { print(Remote.Method().value()) }");
         }},
         {"unqualified class names resolve through enclosing namespaces", [] {
              const auto program = parse(
                  "namespace Outer {\n"
                  "  class Common {}\n"
                  "  namespace Inner {\n"
                  "    class Consumer {\n"
                  "      public:\n      Common dependency\n"
                  "      Common create() { return(Common()) }\n"
                  "    }\n"
                  "  }\n"
                  "}\n"
                  "start {}");
              const auto consumer =
                  std::find_if(program.classes.begin(), program.classes.end(),
                               [](const auto& declaration) {
                                   return declaration.name == "Outer.Inner.Consumer";
                               });
              require(consumer != program.classes.end() &&
                          consumer->fields.front().type == "Outer.Common" &&
                          consumer->methods.front().returnType == "Outer.Common" &&
                          consumer->methods.front().body.front()
                                  .expressions.front()->value == "Outer.Common",
                      "unqualified nested type did not resolve to its enclosing namespace");
         }},
         {"qualified construction lowers to a constructor AST node", [] {
              const auto program = parse(
                  "namespace Foo { class Bar { public: int64 method() { return(42) } } }\n"
                  "start { print(Foo.Bar().method()) }");
              std::ostringstream output;
              cwhip::dumpAst(program, output);
              require(output.str().find("ConstructorCall [Foo.Bar]") != std::string::npos,
                      "qualified constructor call was not resolved in the AST");
         }},
         {"qualified class names support direct constructor declarations", [] {
              const auto program = parse(
                  "namespace Foo {\n"
                  "  class Bar {\n"
                  "    public:\n    int64 value\n"
                  "    Bar(int64 initial) { value = initial }\n"
                  "  }\n"
                  "}\n"
                  "start { Foo.Bar item(42)\n print(item.value) }");
              require(program.statements.front().kind == cwhip::StatementKind::Declaration &&
                          program.statements.front().expressions.front()->value == "Foo.Bar",
                      "qualified direct declaration did not retain its class path");
         }},
         {"namespace start declarations are rejected", [] {
              expectDiagnostic("namespace Hidden { start {} }",
                               "'start' cannot be declared inside a namespace");
         }},
         {"namespace statement bodies are rejected", [] {
              expectDiagnostic("namespace Hidden { print(1) }",
                               "namespace body may contain only namespace and class declarations");
         }},
         {"unresolved qualified class names are rejected", [] {
              expectDiagnostic(
                  "namespace Known { class Present {} }\n"
                  "start { Known.Missing value = Known.Missing() }",
                  "unknown qualified class 'Known.Missing'");
         }}
}};

} // namespace
