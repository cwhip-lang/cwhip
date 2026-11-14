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

const TestGroupRegistration registration{4, {
        {"list literals accept mixed int64, string, and class values", [] {
             expectValid(
                 "class Widget {\n  public:\n  int64 id\n  Widget(int64 initial) { id = initial }\n}\n"
                 "start {\n"
                 "  list bag = [1, \"two\", Widget(3), null]\n"
                 "  print(bag.length)\n"
                 "}");
         }},
        {"list is the collection type spelling", [] {
             expectValid("start {\n"
                         "  list values = [1, \"two\"]\n"
                         "  list alias = values\n"
                         "  print(alias.length)\n"
                         "}");
         }},
        {"removed collection type spellings are not accepted", [] {
             expectDiagnostic("start {\n  array values = []\n}",
                              "unknown type or class 'array'");
             expectDiagnostic("start {\n  map values = [:]\n}",
                              "unknown type or class 'map'");
         }},
        {"removed collection type spellings are ordinary identifiers", [] {
             expectValid("start {\n"
                         "  int64 array = 1\n"
                         "  int64 map = array\n"
                         "  print(map)\n"
                         "}");
         }},
        {"list element values can be extracted directly into concrete types", [] {
             expectValid("start {\n"
                         "  list bag = [1, \"two\"]\n"
                         "  int64 extracted = bag[0]\n"
                         "  strg second = bag[1]\n"
                         "  print(extracted)\n"
                         "  print(second)\n"
                         "}");
         }},
        {"list element assignment accepts any supported value type", [] {
             expectValid("start {\n"
                         "  list bag = [1, \"two\"]\n"
                         "  bag[0] = \"now a string\"\n"
                         "  bag[1] = 42\n"
                         "  print(bag.length)\n"
                         "}");
         }},
        {"legacy 'int64[]' list syntax is rejected", [] {
             expectDiagnostic("start {\n  int64[] values = [1, 2]\n}",
                              "expected identifier (keywords are reserved)");
         }},
        {"legacy 'string[]' list syntax is rejected", [] {
             expectDiagnostic("start {\n  strg[] values = [\"a\"]\n}",
                              "expected identifier (keywords are reserved)");
         }},
        {"legacy 'Class[]' list syntax is rejected", [] {
             expectDiagnostic(
                 "class Widget {\n  public:\n  int64 id\n  Widget(int64 initial) { id = initial }\n}\n"
                 "start {\n  Widget[] values = [Widget(1)]\n}",
                 "expected expression");
         }},
        {"nested list literals are accepted", [] {
             expectValid("start {\n  list inner = [2, 3]\n"
                         "  list bag = [1, inner, [4, 5]]\n}");
         }},
        {"'any' has no members until extracted", [] {
             expectDiagnostic("start {\n  list bag = [[1]]\n"
                              "  print(bag[0].length)\n}",
                              "'any' values cannot be used for member access");
         }},
        {"internal dynamic values cannot receive method calls", [] {
              expectDiagnostic("class Widget {\n  public:\n  int64 value\n  int64 get() { return(value) }\n}\n"
                               "start {\n  list bag = [Widget()]\n"
                               "  int64 value = bag[0].get()\n}",
                               "'any' values cannot be used for method calls");
         }},
        {"list and 'any' equality is rejected", [] {
             expectDiagnostic("start {\n  list bag = [1]\n  list other = [1]\n"
                              "  int64 same = bag == other\n}",
                              "equality requires numeric operands of any supported width");
         }},
        {"dict type and literal keys are accepted", [] {
             expectValid("start {\n"
                         "  dict values = [\"answer\": 42, 'label': \"ok\"]\n"
                         "  dict alias = values\n"
                         "  int64 result = alias[\"answer\"]\n"
                         "  alias[\"answer\"] = \"changed\"\n"
                         "  print(alias.length)\n"
                         "}");
         }},
        {"dict indexing accepts string expressions", [] {
             expectValid("start {\n dict values = [:]\n strg key = \"x\"\n"
                         " strg value = values[key]\n}");
         }},
        {"dict literal keys must be string literals", [] {
             expectDiagnostic("start { dict values = [1: \"value\"] }",
                              "dict keys must have type strg");
         }},
        {"dict length is read-only", [] {
             expectDiagnostic("start {\n dict values = [:]\n values.length = 1\n}",
                              "dict length is read-only");
         }},
        {"dict equality is rejected", [] {
             expectDiagnostic("start {\n dict values = [:]\n dict other = [:]\n"
                              " int64 same = values == other\n}",
                              "equality requires numeric operands of any supported width");
         }},
        {"'any' equality is rejected", [] {
             expectDiagnostic("start {\n list values = [1]\n"
                              " bool same = values[0] == values[0]\n}",
                              "equality requires numeric operands of any supported width");
         }},
        {"internal dynamic values may be compared with null", [] {
             expectValid("start {\n list values = [null]\n"
                         " bool missing = values[0] == null\n}");
         }},
        {"internal dynamic values support the approved typed contexts", [] {
             expectValid("class Reader {\n"
                         "  public:\n  int64 value\n"
                         "  void set(int64 input) { value = input }\n"
                         "  int64 get() { return(value) }\n"
                         "  int64 read(list values) { return(values[0]) }\n"
                         "}\n"
                         "start {\n"
                         "  list values = [42]\n"
                         "  int64 extracted = values[0]\n"
                         "  Reader reader = Reader()\n"
                         "  reader.value = values[0]\n"
                         "  reader.set(values[0])\n"
                         "  int64 returned = reader.read(values)\n"
                         "  list nested = [values[0]]\n"
                         "  nested.append(values[0])\n"
                         "  nested[0] = values[0]\n"
                         "  dict mapped = [\"value\": values[0]]\n"
                         "  mapped[\"value\"] = values[0]\n"
                         "  print(values[0])\n"
                         "  print(format(\"value {}\", values[0]))\n"
                         "  bool isInteger = values[0] is int64\n"
                         "  type dynamicType = type(values[0])\n"
                         "  bool isNull = values[0] == null\n"
                         "}");
         }},
        {"dict slicing accepts integer insertion-order bounds", [] {
             expectValid("start {\n dict values = [\"a\": 1, \"b\": 2]\n"
                         " dict copy = values[0:1]\n"
                         " print(copy.length)\n}");
         }},
        {"dict removal accepts one string key", [] {
             expectValid("start {\n dict values = [\"a\": 1]\n"
                         " int64 removed = values.remove(\"a\")\n"
                         " print(removed)\n}");
         }},
        {"dict removal rejects a non-string key", [] {
             expectDiagnostic("start {\n dict values = [:]\n"
                              " int64 removed = values.remove(1)\n}",
                              "dict key must have type strg");
         }},
        {"dict removal rejects incorrect arity", [] {
             expectDiagnostic("start {\n dict values = [:]\n"
                              " int64 removed = values.remove()\n}",
                              "dict 'remove' expects one strg key");
         }},
        {"dict slice bounds require integers", [] {
             expectDiagnostic("start {\n dict values = [:]\n"
                              " dict copy = values[\"a\":\"z\"]\n}",
                              "dict index and slice bounds must be integers");
         }},
         {"dict contains and collection iteration are accepted", [] {
              expectValid("start {\n"
                          "  dict values = [\"one\": 1]\n"
                          "  strg key = \"one\"\n"
                          "  int64 present = values.contains(key)\n"
                          "  for (name, value in values) { print(name) }\n"
                          "  list items = [1, \"two\"]\n"
                          "  for (item in items) { print(item) }\n"
                          "}");
         }},
         {"dict iteration supports value-only and key/value bindings", [] {
              expectValid("start {\n"
                          "  dict values = [\"one\": 1]\n"
                          "  for (value in values) { print(value) }\n"
                          "  for (key, value in values) { print(key) }\n"
                          "}");
         }},
         {"list iteration accepts one value variable", [] {
              expectDiagnostic("start {\n list values = []\n"
                               " for (key, value in values) { print(value) }\n}",
                               "list iteration accepts one value variable");
         }},
         {"dict keys must be statically typed strings", [] {
               expectDiagnostic("start {\n dict values = [:]\n list keys = [\"x\"]\n"
                                " dict value = values[keys[0]]\n}",
                               "dict keys must have type strg");
         }}
}};

} // namespace
