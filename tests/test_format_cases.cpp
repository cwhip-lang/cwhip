#include "test_cases.hpp"

#include "cwhip/format/Format.hpp"
#include "cwhip/format/Style.hpp"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <string>
#include <unistd.h>

namespace {
using namespace cwhip_test;

const char* const kLongCall =
    "start {\n"
    "    print(alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, kappa, lambda, mu)\n"
    "}\n";

const char* const kWrappedCall =
    "start {\n"
    "    print(\n"
    "            alpha,\n"
    "            beta,\n"
    "            gamma,\n"
    "            delta,\n"
    "            epsilon,\n"
    "            zeta,\n"
    "            eta,\n"
    "            theta,\n"
    "            iota,\n"
    "            kappa,\n"
    "            lambda,\n"
    "            mu)\n"
    "}\n";

std::string formatted(const std::string& source, const cwhip::Style& style = cwhip::builtinStyle()) {
    const auto result = cwhip::formatSource(source, style, "fixture.cw");
    require(result.ok, result.diagnostic.empty() ? "format failed" : result.diagnostic);
    return result.text;
}

void expectSame(const std::string& source) {
    require(formatted(source) == source, "formatted text changed:\n" + formatted(source));
}

void expectSame(const std::string& source, const cwhip::Style& style) {
    const auto text = formatted(source, style);
    require(text == source, "formatted text changed:\n" + text);
}

cwhip::StyleLoadResult parseStyle(const std::string& text) {
    return cwhip::parseStyleText(text, "style.cwhip-format");
}

void writeFile(const std::filesystem::path& path, const std::string& text) {
    std::filesystem::create_directories(path.parent_path());
    std::ofstream output(path, std::ios::binary);
    require(static_cast<bool>(output), "cannot write " + path.string());
    output << text;
}

struct EnvGuard {
    bool had = false;
    std::string value;
    explicit EnvGuard(const char* name) : name_(name) {
        if (const char* current = std::getenv(name)) {
            had = true;
            value = current;
        }
    }
    ~EnvGuard() {
        if (had) setenv(name_.c_str(), value.c_str(), 1);
        else unsetenv(name_.c_str());
    }
    void set(const std::string& next) const { setenv(name_.c_str(), next.c_str(), 1); }
    void clear() const { unsetenv(name_.c_str()); }
    std::string name_;
};

const TestGroupRegistration registration{50, {
    {"builtin style leaves the open keys unset", [] {
         const auto style = cwhip::builtinStyle();
         require(style.indentWidth == 4, "indent width");
         require(style.continuationIndentWidth == 8, "continuation indent");
         require(style.columnLimit == 80, "column limit");
         require(!style.breakBeforeBinaryOperators.has_value(), "binary break is unset");
         require(!style.spaceBeforeParens.has_value(), "paren space is unset");
         require(!style.commentPragmas.has_value(), "comment pragma is unset");
         require(!style.braceBinding.has_value(), "brace binding is unset");
         require(style.allowShortFunctions == cwhip::AllowShortFunctions::None, "short functions");
         require(style.allowShortBlocks == cwhip::AllowShortBlocks::Never, "short blocks");
         require(!style.allowShortLoops, "short loops");
         require(!style.allowShortEnums, "short enums");
         require(style.reflowComments, "reflow");
         require(style.blankLinesAroundLongControlStatement, "long control blanks");
         require(style.longControlStatementLines == 10, "long control length");
     }},
    {"style file accepts a short override and rejects unknown keys", [] {
         const auto limit = parseStyle("ColumnLimit: 0\n");
         require(limit.ok, limit.diagnostic);
         require(limit.style.columnLimit == 0, "zero is unlimited");
         require(!limit.style.breakBeforeBinaryOperators.has_value(), "open key stayed unset");
         const auto negative = parseStyle("ColumnLimit: -1\n");
         require(!negative.ok, "negative column limit");
         require(negative.diagnostic.find("negative integer") != std::string::npos, negative.diagnostic);
         const auto unknown = parseStyle("TabWidth: 4\n");
         require(!unknown.ok, "unknown key");
         require(unknown.diagnostic.find("unknown key: TabWidth") != std::string::npos,
                 unknown.diagnostic);
         const auto based = parseStyle("BasedOnStyle: LLVM\n");
         require(!based.ok, "BasedOnStyle");
         require(based.diagnostic.find("unknown key: BasedOnStyle") != std::string::npos,
                 based.diagnostic);
         const auto duplicate = parseStyle("ColumnLimit: 80\nColumnLimit: 0\n");
         require(!duplicate.ok, "duplicate");
         require(duplicate.diagnostic.find("duplicate key: ColumnLimit") != std::string::npos,
                 duplicate.diagnostic);
         const auto language = parseStyle("Language: Cwhip\nColumnLimit: 40\n");
         require(language.ok, language.diagnostic);
         require(language.style.columnLimit == 40, "language file");
         const auto other = parseStyle("Language: Cpp\n");
         require(!other.ok, "other language");
         const auto both = parseStyle(
             "BreakBeforeBinaryOperators: NonAssignment\n"
             "SpaceBeforeParens: ControlStatements\n"
             "CommentPragmas: '^test:'\n"
             "BraceBinding: Custom\n");
         require(both.ok, both.diagnostic);
         require(both.style.breakBeforeBinaryOperators ==
                     cwhip::BreakBeforeBinaryOperators::NonAssignment,
                 "NonAssignment");
         const auto after = parseStyle("BreakBeforeBinaryOperators: None\n");
         require(after.ok && after.style.breakBeforeBinaryOperators ==
                                 cwhip::BreakBeforeBinaryOperators::None,
                 "None");
         const auto falseValue = parseStyle("BreakBeforeBinaryOperators: false\n");
         require(falseValue.ok && falseValue.style.breakBeforeBinaryOperators ==
                                      cwhip::BreakBeforeBinaryOperators::None,
                 "false is None");
         const auto never = parseStyle("SpaceBeforeParens: Never\n");
         require(never.ok && never.style.spaceBeforeParens == cwhip::SpaceBeforeParens::Never,
                 "Never");
         const auto preserve = parseStyle("BraceBinding: PreserveWhereLegal\n");
         require(preserve.ok &&
                     preserve.style.braceBinding == cwhip::BraceBinding::PreserveWhereLegal,
                 "PreserveWhereLegal");
         const auto emptyPragma = parseStyle("CommentPragmas: ''\n");
         require(emptyPragma.ok && emptyPragma.style.commentPragmas &&
                     emptyPragma.style.commentPragmas->empty(),
                 "empty pragma");
         const auto badPragma = parseStyle("CommentPragmas: '('\n");
         require(!badPragma.ok, "invalid pragma");
     }},
    {"style search stops at five parents and falls back to home", [] {
         EnvGuard home("HOME");
         const auto root = std::filesystem::temp_directory_path() /
                           ("cwhip-format-" + std::to_string(static_cast<long long>(getpid())));
         std::filesystem::remove_all(root);
         const auto here = root / "a" / "b" / "c" / "d" / "e" / "f";
         writeFile(root / ".cwhip-format", "ColumnLimit: 50\n");
         writeFile(root / "a" / ".cwhip-format", "ColumnLimit: 0\n");
         writeFile(here / ".cwhip-format", "ColumnLimit: 7\n");
         writeFile(root / "home" / ".config" / "cwhip" / ".cwhip-format", "ColumnLimit: 3\n");
         home.set((root / "home").string());
         const auto nearest = cwhip::loadStyleAt(here.string());
         require(nearest.ok && nearest.found && nearest.style.columnLimit == 7, nearest.diagnostic);
         std::filesystem::remove(here / ".cwhip-format");
         const auto fifth = cwhip::loadStyleAt(here.string());
         require(fifth.ok && fifth.found && fifth.style.columnLimit == 0,
                 "fifth parent was not used: " + fifth.diagnostic +
                     " limit " + std::to_string(fifth.style.columnLimit));
         std::filesystem::remove(root / "a" / ".cwhip-format");
         home.clear();
         const auto builtin = cwhip::loadStyleAt(here.string());
         require(builtin.ok && !builtin.found && builtin.style.columnLimit == 80,
                 "walk passed the fifth parent");
         std::filesystem::remove(root / ".cwhip-format");
         home.set((root / "home").string());
         const auto fromHome = cwhip::loadStyleAt(here.string());
         require(fromHome.ok && fromHome.found && fromHome.style.columnLimit == 3,
                 fromHome.diagnostic);
         home.clear();
         const auto noHome = cwhip::loadStyleAt(here.string());
         require(noHome.ok && !noHome.found && noHome.style.columnLimit == 80, "HOME was consulted");
         writeFile(root / "blocked" / "child" / "note.txt", "x");
         std::filesystem::create_directory(root / "blocked" / ".cwhip-format");
         writeFile(root / "blocked-parent" / ".cwhip-format", "ColumnLimit: 9\n");
         const auto directory = cwhip::loadStyleAt((root / "blocked").string());
         require(!directory.ok, "a directory named .cwhip-format");
         require(directory.diagnostic.find("not a regular file") != std::string::npos,
                 directory.diagnostic);
         std::filesystem::remove_all(root);
     }},
    {"reprint keeps include, operators, strings, comments, and spellings", [] {
         expectSame(
             "include \"other.cw\"\n"
             "\n"
             "START {\n"
             "    strg word\n"
             "    String text\n"
             "    int64<int64<String>> nested\n"
             "    print(\"a\\n\\\"b\")\n"
             "    print('a\\n')\n"
             "    print(1..20)\n"
             "    print(.5)\n"
             "    print(1.)\n"
             "    print(int8(-2) >> 1)\n"
             "    if (ready and set) {\n"
             "        print(1)\n"
             "    }\n"
             "    if (ready && set) {\n"
             "        print(2)\n"
             "    }\n"
             "    # hash\n"
             "    // slash\n"
             "    print(1) /* comment\n"
             "still a comment */ print(2)\n"
             "}\n");
         expectSame(
             "class Box {\n"
             "    int64 value()\n"
             "}\n"
             "\n"
             "int64 Box.value()\n"
             "    from \"box_value\"\n");
         expectSame(
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    else (other) {\n"
             "        print(2)\n"
             "    }\n"
             "}\n");
         expectSame(
             "start {\n"
             "    strg text inline {\n"
             "        const char *s = \"{\";\n"
             "    }\n"
             "}\n");
     }},
    {"a failed walk leaves the bytes unchanged", [] {
         const std::string joined = "start {\n    print(1) print(2)\n}\n";
         const auto result = cwhip::formatSource(joined, cwhip::builtinStyle(), "joined.cw");
         require(!result.ok, "two statements on one line");
         require(result.text == joined, "failed walk rewrote the file");
         require(result.diagnostic.find("joined.cw:") == 0, result.diagnostic);
         const std::string splitClass = "class Box\n{\n    int64 value\n}\n";
         const auto moved = cwhip::formatSource(splitClass, cwhip::builtinStyle(), "class.cw");
         require(!moved.ok && moved.text == splitClass, "class brace was accepted");
         const std::string method =
             "class Box {\n    int64 value()\n    {\n        return(1)\n    }\n}\n";
         const auto body = cwhip::formatSource(method, cwhip::builtinStyle(), "method.cw");
         require(!body.ok && body.text == method, "in-class brace was accepted");
     }},
    {"short blocks expand and braces stay put while binding is unset", [] {
         require(formatted("start {\n    if (ready) { print(1) }\n}\n") ==
                     "start {\n    if (ready) {\n        print(1)\n    }\n}\n",
                 "if block");
         require(formatted("start {\n    if (ready) {}\n}\n") ==
                     "start {\n    if (ready) {\n    }\n}\n",
                 "empty block");
         require(formatted("start {\n    while (ready) { print(1) }\n}\n") ==
                     "start {\n    while (ready) {\n        print(1)\n    }\n}\n",
                 "loop");
         require(formatted("class Box {\n    enum { A, B }\n}\n") ==
                     "class Box {\n    enum {\n        A, B\n    }\n}\n",
                 "enum");
         require(formatted("class Box {\n    int64 value() { return(1) }\n}\n") ==
                     "class Box {\n    int64 value() {\n        return(1)\n    }\n}\n",
                 "method");
         const std::string kept =
             "class Box {\n"
             "    int64 value() {\n"
             "        return(1)\n"
             "    }\n"
             "}\n";
         expectSame(kept);
         auto allowed = cwhip::builtinStyle();
         allowed.allowShortBlocks = cwhip::AllowShortBlocks::Other;
         allowed.allowShortFunctions = cwhip::AllowShortFunctions::Other;
         allowed.allowShortIf = cwhip::AllowShortIf::Other;
         allowed.allowShortLoops = true;
         allowed.allowShortEnums = true;
         expectSame("class Box {\n    int64 value() { return(1) }\n}\n", allowed);
         expectSame("class Box {\n    enum { A, B }\n}\n", allowed);
     }},
    {"column limit wraps parenthesized lists and leaves unbreakable lines", [] {
         const std::string call = kLongCall;
         const auto lineEnd = call.find('\n', call.find('\n') + 1);
         const auto line = call.substr(call.find('\n') + 1, lineEnd - (call.find('\n') + 1));
         require(line.size() > 80, "long call is not over 80");
         require(formatted(call) == kWrappedCall, formatted(call));
         expectSame("start {\n    print(alpha, beta)\n}\n");
         auto unlimited = cwhip::builtinStyle();
         unlimited.columnLimit = 0;
         expectSame(call, unlimited);
         const std::string generic =
             "start {\n"
             "    dict<VeryLongTypeNameThatPushesThisGenericWellPastTheColumnLimit, AnotherLongTypeNameHere> item\n"
             "}\n";
         require(generic.find('\n') != std::string::npos, "generic fixture");
         const auto genericLine = generic.substr(generic.find('\n') + 1);
         require(genericLine.find('\n') > 80, "generic line is short");
         expectSame(generic);
         const std::string assigned =
             "start {\n"
             "    int64 value = call(alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, kappa, lambda, mu)\n"
             "}\n";
         expectSame(assigned);
         const std::string field =
             "class Box {\n"
             "    int64 value = call(alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, kappa, lambda, mu)\n"
             "}\n";
         expectSame(field);
         const std::string base =
             "class Child: VeryLongBaseName, AnotherVeryLongBaseName, ThirdVeryLongBaseName, FourthVeryLongBaseName {\n"
             "    int64 value\n"
             "}\n";
         require(std::string(base).substr(0, base.find('\n')).size() > 80, "base list is short");
         expectSame(base);
     }},
    {"configured open options wrap, space, protect, and bind", [] {
         const std::string condition =
             "start {\n"
             "    if (conditionThatIsAlreadyIndented && anotherClauseOnTheNextLinePlusExtraWordsHere) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         expectSame(condition);
         auto before = cwhip::builtinStyle();
         before.breakBeforeBinaryOperators = cwhip::BreakBeforeBinaryOperators::NonAssignment;
         const auto brokenBefore = formatted(condition, before);
         require(brokenBefore.find("\n            && ") != std::string::npos, brokenBefore);
         require(brokenBefore.find("if (") != std::string::npos, brokenBefore);
         auto after = cwhip::builtinStyle();
         after.breakBeforeBinaryOperators = cwhip::BreakBeforeBinaryOperators::None;
         const auto brokenAfter = formatted(condition, after);
         require(brokenAfter.find("&&\n            ") != std::string::npos, brokenAfter);
         const std::string spaced =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    print (2)\n"
             "}\n";
         expectSame(spaced);
         auto never = cwhip::builtinStyle();
         never.spaceBeforeParens = cwhip::SpaceBeforeParens::Never;
         require(formatted(spaced, never).find("if(ready)") != std::string::npos, "Never if");
         require(formatted(spaced, never).find("print(2)") != std::string::npos, "Never print");
         auto controls = cwhip::builtinStyle();
         controls.spaceBeforeParens = cwhip::SpaceBeforeParens::ControlStatements;
         const auto controlled = formatted(spaced, controls);
         require(controlled.find("if (ready)") != std::string::npos, controlled);
         require(controlled.find("print (2)") != std::string::npos, controlled);
         const std::string prose =
             "alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron";
         const std::string comments =
             "start {\n"
             "    // test: " + prose + "\n"
             "    // ordinary " + prose + "\n"
             "    # hash " + prose + "\n"
             "    print(1)\n"
             "}\n";
         const auto reflowed = formatted(comments);
         require(reflowed != comments, "long comments stayed on one line");
         require(reflowed.find("// test:") != std::string::npos, reflowed);
         require(reflowed.find("# hash") != std::string::npos, reflowed);
         auto frozen = cwhip::builtinStyle();
         frozen.commentPragmas = "^test:";
         const auto kept = formatted(comments, frozen);
         require(kept.find("    // test: " + prose) != std::string::npos, kept);
         require(kept.find("    // ordinary " + prose) == std::string::npos, kept);
         auto empty = cwhip::builtinStyle();
         empty.commentPragmas = "";
         require(formatted(comments, empty).find("    // test: " + prose) == std::string::npos,
                 "empty pragma protected a comment");
         const std::string braces =
             "start {\n"
             "    if (ready)\n"
             "    {\n"
             "        print(1)\n"
             "    } else (other) {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         expectSame(braces);
         auto preserve = cwhip::builtinStyle();
         preserve.braceBinding = cwhip::BraceBinding::PreserveWhereLegal;
         expectSame(braces, preserve);
         auto custom = cwhip::builtinStyle();
         custom.braceBinding = cwhip::BraceBinding::Custom;
         const auto bound = formatted(braces, custom);
         require(bound.find("    if (ready) {\n") != std::string::npos, bound);
         require(bound.find("    }\n    else (other) {\n") != std::string::npos, bound);
         const std::string blankBrace =
             "start {\n"
             "    if (ready)\n"
             "\n"
             "    {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         expectSame(blankBrace, custom);
         expectSame("class Box {\n    int64 value\n}\n", custom);
     }},
    {"long controls gain a blank line without deleting others", [] {
         const std::string longIf =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "        print(2)\n"
             "        print(3)\n"
             "        print(4)\n"
             "        print(5)\n"
             "        print(6)\n"
             "        print(7)\n"
             "        print(8)\n"
             "        print(9)\n"
             "    }\n"
             "    print(0)\n"
             "}\n";
         const std::string expected =
             "start {\n"
             "\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "        print(2)\n"
             "        print(3)\n"
             "        print(4)\n"
             "        print(5)\n"
             "        print(6)\n"
             "        print(7)\n"
             "        print(8)\n"
             "        print(9)\n"
             "    }\n"
             "\n"
             "    print(0)\n"
             "}\n";
         require(formatted(longIf) == expected, formatted(longIf));
         const std::string declared =
             "start {\n"
             "    int64 value\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "        print(2)\n"
             "        print(3)\n"
             "        print(4)\n"
             "        print(5)\n"
             "        print(6)\n"
             "        print(7)\n"
             "        print(8)\n"
             "        print(9)\n"
             "    }\n"
             "    print(0)\n"
             "}\n";
         const auto withValue = formatted(declared);
         require(withValue.find("start {\n\n    int64 value\n    if (ready)") != std::string::npos,
                 withValue);
         require(withValue.find("int64 value\n\n    if") == std::string::npos, withValue);
         const std::string shortIf =
             "start {\n"
             "\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "\n"
             "    print(0)\n"
             "}\n";
         expectSame(shortIf);
     }},
}};

} // namespace
