#include "test_cases.hpp"

#include "cwhip/Diagnostic.hpp"
#include "cwhip/Lexer.hpp"
#include "cwhip/Parser.hpp"
#include "cwhip/Token.hpp"

#include <algorithm>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace {
using namespace cwhip_test;

const TestGroupRegistration registration{0, {
        {"lexer keywords and strings", [] {
             cwhip::Lexer lexer("StArT {\n INT n = 12\n StRg s = \"a\\n\"\n}", "lexer.cw");
             const auto tokens = lexer.tokenize();
             require(tokens[0].type == cwhip::TokenType::Start, "START keyword not recognized");
             require(tokens[3].type == cwhip::TokenType::NativeInt,
                     "native INT spelling was not recognized");
             require(tokens[5].type == cwhip::TokenType::Equal, "assignment token missing");
             require(tokens[6].type == cwhip::TokenType::Integer && tokens[6].text == "12",
                     "integer token incorrect");
             require(tokens[8].type == cwhip::TokenType::StrgType,
                     "STRG type keyword not recognized");
             require(tokens[11].type == cwhip::TokenType::String &&
                         tokens[11].text == "a\n" && tokens[11].formattedString,
                     "escaped formatted string incorrect");
         }},
        {"single-quoted strings are literal", [] {
             cwhip::Lexer lexer("start {\n print('a\\n')\n}", "single-quoted.cw");
             const auto tokens = lexer.tokenize();
             require(tokens[5].type == cwhip::TokenType::String, "single-quoted token missing");
             require(tokens[5].text == "a\\n", "single-quoted backslash was interpreted");
             require(!tokens[5].formattedString, "single-quoted token was marked formatted");
         }},
        {"double-quoted escape e produces ESC only", [] {
             cwhip::Lexer lexer("start { print(\"a\\e\") print('a\\e') }",
                               "escape-e.cw");
             const auto tokens = lexer.tokenize();
             const auto expected = std::string("a") + static_cast<char>(0x1b);
             require(tokens[4].type == cwhip::TokenType::String &&
                         tokens[4].text == expected,
                     "double-quoted \\\\e did not produce byte 0x1b");
             require(tokens[8].type == cwhip::TokenType::String &&
                         tokens[8].text == "a\\e",
                     "single-quoted \\\\e did not preserve its backslash");
         }},
        {"semicolon is not a line comment", [] {
             expectDiagnostic("start {\n print(1) ; not a comment\n print(2)\n}",
                              "unknown character ';': ';' is not a comment; use '#' or '//'");
         }},
        {"hash line comments", [] {
             cwhip::Lexer lexer("start {\n # comment\n print(2)\n}", "hash-comment.cw");
             const auto tokens = lexer.tokenize();
             bool foundPrint = false;
             for (const auto& token : tokens) foundPrint |= token.type == cwhip::TokenType::Print;
             require(foundPrint,
                     "hash comment did not preserve the following line");
         }},
        {"slash line comments", [] {
             cwhip::Lexer lexer("start {\n // comment\n print(2)\n}", "slash-comment.cw");
             const auto tokens = lexer.tokenize();
             bool foundPrint = false;
             for (const auto& token : tokens) foundPrint |= token.type == cwhip::TokenType::Print;
             require(foundPrint,
                     "slash comment did not preserve the following line");
         }},
        {"block comments preserve statement boundaries", [] {
             cwhip::Lexer lexer("start {\n int64 value = 1 /* comment\ncontinued */\n print(value)\n}",
                               "block-comment.cw");
             const auto tokens = lexer.tokenize();
             std::size_t newlines = 0;
             for (const auto& token : tokens) {
                 if (token.type == cwhip::TokenType::Newline) ++newlines;
             }
             require(newlines >= 3, "block comment swallowed statement-boundary newlines");
         }},
        {"unterminated block comment diagnostic", [] {
             expectDiagnostic("start {\n /* comment", "unterminated block comment");
         }},
        {"reserved keywords", [] {
             expectDiagnostic("start {\n bool While = false\n}", "keywords are reserved");
             expectDiagnostic("start {\n int64 const = 1\n}", "keywords are reserved");
             expectDiagnostic("start {\n int64 CONST = 1\n}", "keywords are reserved");
         }},
        {"const is a case-insensitive keyword", [] {
             cwhip::Lexer lexer("start { CONST value = 1 const other = 2 }", "const.cw");
             const auto tokens = lexer.tokenize();
             int consts = 0;
             for (const auto& token : tokens) {
                 if (token.type == cwhip::TokenType::Const) ++consts;
             }
             require(consts == 2, "CONST and const were not both keywords");
         }},
        {"callback is an ordinary identifier", [] {
             cwhip::Lexer lexer("class callback {}\nstart { callback value = callback() }",
                               "callback-identifier.cw");
             const auto tokens = lexer.tokenize();
             require(tokens[1].type == cwhip::TokenType::Identifier &&
                         tokens[1].text == "callback",
                     "callback should be lexed as an identifier");
             expectValid("namespace callback {\n"
                         " class Item {\n"
                         "  int32 callback\n"
                         "  int32 method(int32 callback) { return(callback) }\n"
                         " }\n"
                         "}\n"
                         "class Methods { int32 callback() { return(1) } }\n"
                         "start {\n"
                         " callback.Item item = callback.Item()\n"
                         " callback.Item callback = item\n"
                         " Methods methods = Methods()\n"
                         " int32 result = methods.callback()\n"
                         "}");
         }},
         {"old string spelling is an identifier", [] {
              cwhip::Lexer lexer("start { int64 string = 1 }", "string-identifier.cw");
              const auto tokens = lexer.tokenize();
              require(tokens[3].type == cwhip::TokenType::Identifier &&
                          tokens[3].text == "string",
                      "lowercase string was treated as a keyword");
          }},
        {"scalar keywords and literals", [] {
             cwhip::Lexer lexer("start { bool ready = true fp64 value = 3.14 "
                               "uint64 count = 42u FLOAT oldFloat = 1.0 "
                               "UNSIGNED oldUnsigned = 42u }", "scalar.cw");
             const auto tokens = lexer.tokenize();
             bool foundTrue = false;
             bool foundFloat = false;
             bool foundNativeFloat = false;
             bool foundRemovedUnsigned = false;
             for (const auto& token : tokens) {
                 foundTrue |= token.type == cwhip::TokenType::True;
                 foundFloat |= token.type == cwhip::TokenType::Float && token.text == "3.14";
                 foundNativeFloat |= token.type == cwhip::TokenType::NativeFloat;
                 foundRemovedUnsigned |= token.type == cwhip::TokenType::RemovedUnsigned;
             }
             require(foundTrue && foundFloat && foundNativeFloat &&
                         foundRemovedUnsigned,
                     "boolean, numeric type, or removed unsigned type token missing");
         }},
        {"scalar compound-assignment operators", [] {
             cwhip::Lexer lexer("a += 1 a -= 1 a *= 1 a /= 1 a %= 1",
                               "compound-assignment.cw");
             const auto tokens = lexer.tokenize();
             const std::vector<cwhip::TokenType> expected{
                 cwhip::TokenType::Identifier, cwhip::TokenType::PlusEqual,
                 cwhip::TokenType::Integer, cwhip::TokenType::Identifier,
                 cwhip::TokenType::MinusEqual, cwhip::TokenType::Integer,
                 cwhip::TokenType::Identifier, cwhip::TokenType::StarEqual,
                 cwhip::TokenType::Integer, cwhip::TokenType::Identifier,
                 cwhip::TokenType::SlashEqual, cwhip::TokenType::Integer,
                 cwhip::TokenType::Identifier, cwhip::TokenType::PercentEqual,
                 cwhip::TokenType::Integer};
             for (std::size_t index = 0; index < expected.size(); ++index) {
                 require(tokens[index].type == expected[index],
                         "compound-assignment token sequence is incorrect");
             }
             require(tokens[1].text == "+=" && tokens[4].text == "-=" &&
                         tokens[7].text == "*=" && tokens[10].text == "/=" &&
                         tokens[13].text == "%=",
                     "compound-assignment token spelling was not retained");
         }},
        {"hexadecimal integer spellings", [] {
             cwhip::Lexer lexer("start { int64 a = 0x1234 int64 b = 0XAbCd "
                               "uint64 c = 0xFFu uint64 d = 0XfFU }",
                               "hexadecimal.cw");
             const auto tokens = lexer.tokenize();
             std::vector<std::pair<cwhip::TokenType, std::string>> literals;
             for (const auto& token : tokens) {
                 if (token.type == cwhip::TokenType::Integer ||
                     token.type == cwhip::TokenType::UnsignedInteger) {
                     literals.emplace_back(token.type, token.text);
                 }
             }
             require(literals.size() == 4, "hexadecimal integer tokens missing");
             require(literals[0].first == cwhip::TokenType::Integer &&
                         literals[0].second == "0x1234" &&
                         literals[1].first == cwhip::TokenType::Integer &&
                         literals[1].second == "0XAbCd" &&
                         literals[2].first == cwhip::TokenType::UnsignedInteger &&
                         literals[2].second == "0xFFu" &&
                         literals[3].first == cwhip::TokenType::UnsignedInteger &&
                         literals[3].second == "0XfFU",
                     "hexadecimal literal spelling or suffix was changed");
         }},
        {"malformed hexadecimal literals are source-located", [] {
             for (const auto& literal : {"0x", "0x1g", "0x1ufoo"}) {
                 try {
                     cwhip::Lexer lexer("start {\n int64 value = " + std::string(literal) +
                                           "\n}",
                                       "malformed-hex.cw");
                     lexer.tokenize();
                 } catch (const cwhip::DiagnosticError& error) {
                     require(std::string(error.what()).find(
                                 "malformed hexadecimal integer literal") !=
                                 std::string::npos,
                             "malformed hex diagnostic message incorrect");
                     require(error.location().file == "malformed-hex.cw" &&
                                 error.location().line == 2 &&
                         error.location().column == 16,
                             "malformed hex diagnostic has incorrect source location");
                     continue;
                 }
                 throw std::runtime_error("malformed hexadecimal literal was accepted");
             }
         }},
        {"hexadecimal integer range and unary minimum", [] {
             expectValid("start {\n"
                         " int64 maximum = 0x7FFFFFFFFFFFFFFF\n"
                         " int64 minimum = -0x8000000000000000\n"
                         " uint64 maximumUnsigned = 0xFFFFFFFFFFFFFFFFu\n"
                         " uint64 contextualUnsigned = uint64(0xFFFFFFFFFFFFFFFFu)\n"
                         "}\n");
             const auto checkLocation = [](const std::string& source,
                                           const std::string& message) {
                 try {
                     parse(source, "hex-range.cw");
                 } catch (const cwhip::DiagnosticError& error) {
                     require(std::string(error.what()).find(message) != std::string::npos,
                             "hex range diagnostic message incorrect");
                     require(error.location().file == "hex-range.cw" &&
                                 error.location().line == 2,
                             "hex range diagnostic has incorrect source location");
                     return;
                 }
                 throw std::runtime_error("out-of-range hexadecimal literal was accepted");
             };
             checkLocation("start {\n int64 value = 0x8000000000000000\n}\n",
                           "integer literal is outside the signed 64-bit range");
             checkLocation("start {\n uint64 value = 0x10000000000000000u\n}\n",
                           "unsigned literal is outside the 64-bit range");
             checkLocation("start {\n int64 value = -0x8000000000000001\n}\n",
                           "integer literal is outside the signed 64-bit range");
             expectValid("start {\n"
                              " list values = [1, 2]\n"
                              " list invalid = values[::0x0]\n"
                              "}\n");
         }},
        {"import keyword is case-insensitive and reserved", [] {
             cwhip::Lexer lexer("IMPORT network AS Net\nstart {}", "import-keyword.cw");
             const auto tokens = lexer.tokenize();
             require(tokens[0].type == cwhip::TokenType::Import &&
                         tokens[2].type == cwhip::TokenType::As,
                     "import keywords were not recognized case-insensitively");
         }}
}};

} // namespace
