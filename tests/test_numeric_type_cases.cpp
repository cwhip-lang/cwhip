#include "test_cases.hpp"

#include "cwhip/CodeGenerator.hpp"
#include "cwhip/Diagnostic.hpp"
#include "cwhip/Lexer.hpp"
#include "cwhip/NumericType.hpp"
#include "cwhip/Parser.hpp"
#include "cwhip/SemanticAnalyzer.hpp"

#include <array>
#include <string>

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{9, {
        {"numeric type descriptors", [] {
             require(cwhip::numericTypes.size() == 10,
                     "numeric descriptor table should contain all ten types");
             for (const auto& type : cwhip::numericTypes) {
                 require(!type.name.empty() && !type.range.minimum.empty() &&
                             !type.range.maximum.empty() && !type.llvmType.empty(),
                         "numeric descriptor omitted its name, range, or LLVM type");
                 const auto expectedSignedness =
                     type.category == cwhip::NumericCategory::SignedInteger
                         ? cwhip::NumericSignedness::Signed
                     : type.category == cwhip::NumericCategory::UnsignedInteger
                         ? cwhip::NumericSignedness::Unsigned
                         : cwhip::NumericSignedness::NotApplicable;
                 require(type.signedness == expectedSignedness,
                         std::string("inconsistent signedness for ") + std::string(type.name));
             }
         }},
        {"numeric arithmetic pair matrix", [] {
             constexpr std::array<const char*, 10> types{
                 "int8", "uint8", "int16", "uint16", "int32",
                 "uint32", "int64", "uint64", "fp32", "fp64"};
             for (const auto* left : types) {
                 for (const auto* right : types) {
                     const auto source = "start {\n" + std::string(left) +
                         " lhs = 1\n" + right + " rhs = 2\n" + left +
                         " result = lhs + rhs\n}\n";
                     const auto common = cwhip::commonNumericType(left, right);
                     try {
                         auto program = parse(source, "numeric-pairs.cw");
                         require(common.has_value(),
                                 std::string("accepted arithmetic without a common type: ") +
                                     left + " + " + right);
                         require(program.statements[2].expressions.front()->resolvedType ==
                                     *common,
                                 std::string("wrong common type for ") + left + " + " + right);
                     } catch (const cwhip::DiagnosticError& error) {
                         require(!common.has_value(), error.what());
                     }
                 }
             }
         }},
        {"numeric comparison and conversion pair matrices", [] {
             constexpr std::array<const char*, 10> types{
                 "int8", "uint8", "int16", "uint16", "int32",
                 "uint32", "int64", "uint64", "fp32", "fp64"};
             const auto warningCount = [](const std::string& source) {
                 cwhip::Lexer lexer(source, "numeric-conversion-matrix.cw");
                 auto program = cwhip::Parser(lexer.tokenize()).parseProgram();
                 cwhip::SemanticAnalyzer analyzer;
                 analyzer.analyze(program);
                 return analyzer.warnings().size();
             };
             for (const auto* sourceType : types) {
                 for (const auto* targetType : types) {
                     const auto comparison = "start {\n" + std::string(sourceType) +
                         " lhs = 1\n" + targetType + " rhs = 2\n"
                         "bool result = lhs < rhs\n}\n";
                     auto compared = parse(comparison, "numeric-comparison.cw");
                     require(compared.statements[2].expressions.front()->resolvedType == "bool",
                             std::string("comparison rejected for ") + sourceType + " and " +
                                 targetType);

                     const auto conversion = "start {\n" + std::string(sourceType) +
                         " source = " + sourceType + "(1)\n" + targetType +
                         " converted = source\n}\n";
                     (void)parse(conversion, "numeric-conversion.cw");
                     const auto lossy = !cwhip::isLosslessNumericConversion(
                         targetType, sourceType);
                     const auto assignmentWarnings = warningCount(conversion);
                     require(assignmentWarnings == (lossy ? 1U : 0U),
                             std::string("wrong assignment-conversion warning for ") +
                                 sourceType + " to " + targetType + ": got " +
                                 std::to_string(assignmentWarnings));

                     const auto callAndReturn =
                         "class Converter {\npublic:\n" + std::string(targetType) +
                         " fromSource(" + sourceType +
                         " value) { return(value) }\n" + targetType +
                         " fromArgument(" + targetType +
                         " value) { return(value) }\n}\nstart {\n" +
                         sourceType + " value = " + sourceType +
                         "(1)\nConverter converter = Converter()\n" +
                         targetType +
                         " returned = converter.fromSource(value)\n" +
                         targetType + " argument = converter.fromArgument(value)\n}\n";
                     require(warningCount(callAndReturn) == (lossy ? 2U : 0U),
                             std::string("wrong argument/return-conversion warnings for ") +
                                 sourceType + " to " + targetType);

                     const auto explicitCast =
                         "start {\n" + std::string(sourceType) + " value = " +
                         sourceType + "(1)\n" + targetType +
                         " converted = " + targetType + "(value)\n}\n";
                     require(warningCount(explicitCast) == 0,
                             std::string("explicit cast warned for ") + sourceType +
                                 " to " + targetType);
                 }
             }
             expectDiagnostic("start {\n int64 lhs = 1\n uint64 rhs = 2u\n"
                              " print(lhs + rhs)\n}\n",
                              "no common numeric type");
         }},
        {"integer literal width boundaries", [] {
             const auto literalType = [](const std::string& literal) {
                 const auto program = parse("start {\n print(" + literal + ")\n}\n",
                                            "integer-width.cw");
                 return program.statements.front().expressions.front()->resolvedType;
             };
             const std::array<std::pair<const char*, const char*>, 12> cases{{
                 {"0", "int8"}, {"127", "int8"}, {"128", "int16"},
                 {"32767", "int16"}, {"32768", "int32"},
                 {"2147483647", "int32"}, {"2147483648", "int64"},
                 {"-128", "int8"}, {"-129", "int16"},
                 {"-32768", "int16"}, {"-32769", "int32"},
                 {"-9223372036854775808", "int64"},
             }};
             for (const auto& test : cases) {
                 require(literalType(test.first) == test.second,
                         std::string("wrong inferred type for literal ") + test.first);
             }
             require(literalType("255u") == "uint8", "255u should be uint8");
             require(literalType("256u") == "uint16", "256u should be uint16");
             require(literalType("4294967296u") == "uint64",
                     "4294967296u should be uint64");
             require(literalType("18446744073709551615u") == "uint64",
                     "uint64 maximum was rejected");
             require(literalType("0xf64") == "int16",
                     "hexadecimal f64 digits were treated as a float suffix");
             expectDiagnostic("start {\n print(9223372036854775808)\n}\n",
                              "append 'u'");
             expectDiagnostic("start {\n print(18446744073709551616u)\n}\n",
                              "unsigned literal is outside the 64-bit range");
         }},
        {"floating literal format selection", [] {
             const auto literalType = [](const std::string& literal) {
                 const auto program = parse("start {\n print(" + literal + ")\n}\n",
                                            "floating-width.cw");
                 return program.statements.front().expressions.front()->resolvedType;
             };
             require(literalType("3.0") == "fp32", "unsuffixed float should default to fp32");
             require(literalType("0.1f64") == "fp64", "f64 suffix was not recognized");
             require(literalType("1e100") == "fp64", "fp32 overflow should fall back to fp64");
             require(literalType("1e-100") == "fp64", "fp32 underflow should fall back to fp64");
             expectDiagnostic("start {\n print(1e400)\n}\n",
                              "outside the finite fp64 range");
         }},
        {"implicit conversion warning policy", [] {
             const auto analyzeWarnings = [](const std::string& source) {
                 cwhip::Lexer lexer(source, "numeric-warning.cw");
                 auto program = cwhip::Parser(lexer.tokenize()).parseProgram();
                 cwhip::SemanticAnalyzer analyzer;
                 analyzer.analyze(program);
                 return analyzer.warnings();
             };
             const auto safe = analyzeWarnings(
                 "start {\n int8 narrow = 1\n int64 wide = narrow\n}\n");
             require(safe.empty(), "lossless integer widening emitted a warning");

             const auto lossy = analyzeWarnings(
                 "start {\n int64 wide = 1\n int8 narrow = wide\n}\n");
             require(lossy.size() == 1 &&
                         lossy.front().message.find("int64") != std::string::npos &&
                         lossy.front().message.find("int8") != std::string::npos &&
                         lossy.front().message.find("explicit int8(...)") != std::string::npos,
                     "lossy assignment did not produce an actionable conversion warning");

             const auto promotion = analyzeWarnings(
                 "start {\n int64 wide = 1\n fp64 real = 1.0\n"
                 " print(wide + real)\n}\n");
             require(promotion.size() == 1 &&
                         promotion.front().message.find("int64") != std::string::npos &&
                         promotion.front().message.find("fp64") != std::string::npos,
                     "lossy arithmetic promotion did not warn once");

             const auto explicitCast = analyzeWarnings(
                 "start {\n int64 wide = 1\n int8 narrow = int8(wide)\n}\n");
             require(explicitCast.empty(), "explicit numeric cast emitted an implicit warning");
         }},
        {"native numeric aliases preserve fixed-width identities", [] {
             expectValid("start {\n int signedValue = int(7)\n"
                         " uint unsignedValue = uint(9u)\n"
                         " float realValue = float(1.5)\n"
                         " int32 fixedSigned = signedValue\n"
                         " uint32 fixedUnsigned = unsignedValue\n"
                         " fp32 fixedReal = realValue\n}\n");
             const auto aliases = parse(
                 "start {\n int signedValue = 7\n uint unsignedValue = 9u\n"
                 " float realValue = 1.5\n}\n", "native-aliases.cw");
             const auto aliasIr =
                 cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(aliases);
             require(aliasIr.find("alloca i32") != std::string::npos &&
                         aliasIr.find("alloca float") != std::string::npos,
                     "native aliases did not use the existing fixed-width LLVM types");
         }},
        {"unsigned remains a removed reserved name", [] {
             for (const auto* name : {"unsigned", "Unsigned"}) {
                 bool migrationFound = false;
                 try {
                     (void)parse("start {\n " + std::string(name) + " value = 1\n}\n",
                                 "removed-type.cw");
                 } catch (const cwhip::DiagnosticError& error) {
                     migrationFound = true;
                     require(std::string(error.what()).find(
                                 "use 'uint64'") != std::string::npos,
                             "removed type diagnostic omitted its migration replacement");
                 }
                 require(migrationFound, "removed type name was accepted");
                 expectDiagnostic("start {\n int64 " + std::string(name) + " = 1\n}\n",
                                  "removed numeric type name");
                 expectDiagnostic("start {\n print(" + std::string(name) + ")\n}\n",
                                  "removed numeric type name");
                 expectDiagnostic("class " + std::string(name) + " {}\nstart {}\n",
                                  "removed numeric type name");
                 expectDiagnostic("class Holder { " + std::string(name) +
                                      " field }\nstart {}\n",
                                  "removed numeric type name");
                 expectDiagnostic("class Holder { public: void " + std::string(name) +
                                      "() {} }\nstart {}\n",
                                  "removed numeric type name");
                 expectDiagnostic("class Holder { public: void use(" + std::string(name) +
                                      " value) {} }\nstart {}\n",
                                  "removed numeric type name");
             }
             expectDiagnostic("start {\n float32 value = 1.0\n}\n", "unknown type or class");
             auto narrow = parse("start {\n int8 value\n}\n", "backend-boundary.cw");
             const auto ir = cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(narrow);
             require(ir.find("alloca i8") != std::string::npos,
                     "int8 local did not retain its LLVM storage width");

             auto stringOnly = parse("start {\n print(\"ok\")\n}\n", "string-only.cw");
             (void)cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(stringOnly);

             auto numericResult = parse(
                 "start {\n list values = []\n print(values.length)\n}\n",
                 "numeric-member-result.cw");
             (void)cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(numericResult);

             auto externalNumeric = parse(
                 "class Native {\n public:\n int8 read()\n}\n"
                 "int8 Native.read() from \"native_read\"\nstart {}\n",
                 "external-numeric.cw");
             const auto externalIr =
                 cwhip::CodeGenerator("x86_64-unknown-linux-gnu").generate(externalNumeric);
             require(externalIr.find("declare signext i8 @native_read(ptr)") !=
                         std::string::npos,
                     "int8 native return is missing its ABI extension attribute");
         }}
}};

} // namespace
