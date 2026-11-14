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

const char* const kBuiltinConfig =
    "# Language of the file. Cwhip is the only accepted value.\n"
    "Language: Cwhip\n"
    "# Spaces for each indent level.\n"
    "IndentWidth: 4\n"
    "# Inserted indent uses spaces.\n"
    "UseTab: Never\n"
    "# Extra spaces past the block indent on a wrapped line.\n"
    "ContinuationIndentWidth: 8\n"
    "# Do not line up an operand with the operator.\n"
    "AlignOperands: DontAlign\n"
    "# Preferred line length. 0 means do not wrap.\n"
    "ColumnLimit: 80\n"
    "# Do not split a string literal across lines.\n"
    "BreakStringLiterals: false\n"
    "# Allow a function body on one line. None does not.\n"
    "AllowShortFunctionsOnASingleLine: None\n"
    "# Allow a block on one line. Never does not.\n"
    "AllowShortBlocksOnASingleLine: Never\n"
    "# Allow an if body on one line. Never does not.\n"
    "AllowShortIfStatementsOnASingleLine: Never\n"
    "# Allow a loop body on one line.\n"
    "AllowShortLoopsOnASingleLine: false\n"
    "# Allow an enum body on one line.\n"
    "AllowShortEnumsOnASingleLine: false\n"
    "# Put { on the next line. False keeps the source break.\n"
    "NewlineBeforeOpenBrace: false\n"
    "# Put the token after { on the next line.\n"
    "NewlineAfterOpenBrace: true\n"
    "# Put the token after } on the next line.\n"
    "NewlineAfterCloseBrace: true\n"
    "# Put else on the line after }. False leaves it on the } line.\n"
    "NewlineBeforeElse: true\n"
    "# Break a long parenthesized list after the opening parenthesis.\n"
    "WrapLongParenthesizedList: BreakAfterOpenParen\n"
    "# Pack wrapped parameters onto one line.\n"
    "BinPackParameters: false\n"
    "# Pack wrapped arguments onto one line.\n"
    "BinPackArguments: false\n"
    "# Insert a blank line around a long control statement.\n"
    "BlankLinesAroundLongControlStatement: true\n"
    "# A control statement longer than this many lines is long.\n"
    "LongControlStatementLines: 10\n"
    "# Reflow hash and slash comments to the column limit.\n"
    "ReflowComments: true\n"
    "# A newline ends a statement.\n"
    "StatementTerminator: Newline\n"
    "# Do not insert semicolons.\n"
    "InsertSemicolons: false\n"
    "# Allow more than one statement on a line.\n"
    "AllowMultipleStatementsPerLine: false\n"
    "# Wrap only inside parentheses and brackets.\n"
    "WrapOnlyInsideParensAndBrackets: true\n"
    "# Keep else and its parenthesis on one line.\n"
    "KeepElseParenOnSameLine: true\n"
    "# Do not write else if.\n"
    "ForbidElseIf: true\n"
    "# Keep and, or, and not as written.\n"
    "PreserveLogicalSpelling: true\n"
    "# Keep keyword capitalization as written.\n"
    "PreserveKeywordCase: true\n"
    "# Keep int, strg, and other type spellings as written.\n"
    "PreserveTypeAliasSpelling: true\n"
    "# Keep numeric spellings as written.\n"
    "PreserveNumericSpelling: true\n"
    "# Copy string text without re-escaping.\n"
    "PreserveStringLexeme: true\n"
    "# Keep parentheses that are in the source.\n"
    "PreserveParentheses: true\n"
    "# Do not split the .. operator.\n"
    "SplitDotDot: false\n"
    "# Do not split the >> operator.\n"
    "SplitShiftRight: false\n"
    "# Do not expand include directives.\n"
    "ExpandIncludes: false\n"
    "# Do not reorder include directives.\n"
    "ReorderIncludes: false\n"
    "# Do not format an inline C body.\n"
    "FormatInlineC: false\n"
    "# Keep newlines inside block comments.\n"
    "PreserveBlockCommentNewlines: true\n";

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

void requireBuiltin(const cwhip::Style& style) {
    const auto builtin = cwhip::builtinStyle();
    require(style.indentWidth == builtin.indentWidth, "indent width");
    require(style.continuationIndentWidth == builtin.continuationIndentWidth, "continuation");
    require(style.columnLimit == builtin.columnLimit, "column limit");
    require(style.breakStringLiterals == builtin.breakStringLiterals, "string breaks");
    require(style.allowShortFunctions == builtin.allowShortFunctions, "short functions");
    require(style.allowShortBlocks == builtin.allowShortBlocks, "short blocks");
    require(style.allowShortIf == builtin.allowShortIf, "short if");
    require(style.allowShortLoops == builtin.allowShortLoops, "short loops");
    require(style.allowShortEnums == builtin.allowShortEnums, "short enums");
    require(style.reflowComments == builtin.reflowComments, "reflow");
    require(style.blankLinesAroundLongControlStatement ==
                builtin.blankLinesAroundLongControlStatement,
            "long control blanks");
    require(style.longControlStatementLines == builtin.longControlStatementLines,
            "long control length");
    require(!style.breakBeforeBinaryOperators.has_value(), "binary break is unset");
    require(!style.spaceBeforeParens.has_value(), "paren space is unset");
    require(!style.commentPragmas.has_value(), "comment pragma is unset");
    require(!style.braceBinding.has_value(), "brace binding is unset");
    require(style.breakBeforeBinaryOperators == builtin.breakBeforeBinaryOperators, "binary");
    require(style.spaceBeforeParens == builtin.spaceBeforeParens, "parens");
    require(style.commentPragmas == builtin.commentPragmas, "pragma");
    require(style.braceBinding == builtin.braceBinding, "brace");
    require(style.newlineBeforeOpenBrace == builtin.newlineBeforeOpenBrace, "newline before {");
    require(style.newlineAfterOpenBrace == builtin.newlineAfterOpenBrace, "newline after {");
    require(style.newlineAfterCloseBrace == builtin.newlineAfterCloseBrace, "newline after }");
    require(style.newlineBeforeElse == builtin.newlineBeforeElse, "newline before else");
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
         require(!style.newlineBeforeOpenBrace, "newline before open brace");
         require(style.newlineAfterOpenBrace, "newline after open brace");
         require(style.newlineAfterCloseBrace, "newline after close brace");
         require(style.newlineBeforeElse, "newline before else");
     }},
    {"builtin config text parses back and omits the open keys", [] {
         const auto text = cwhip::builtinConfigText();
         require(text == kBuiltinConfig, "builtin config text:\n" + text);
         require(text.find("BreakBeforeBinaryOperators") == std::string::npos, "binary key");
         require(text.find("BraceBinding") == std::string::npos, "brace key");
         require(text.find("CommentPragmas") == std::string::npos, "pragma key");
         require(text.find("SpaceBeforeParens") == std::string::npos, "paren key");
         require(text.find("ContinuationIndentWidth: 8\n") != std::string::npos, "continuation 8");
         require(text.find("ColumnLimit: 80\n") != std::string::npos, "column 80");
         const auto loaded = parseStyle(text);
         require(loaded.ok, loaded.diagnostic);
         requireBuiltin(loaded.style);
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
         const std::string bracesElseSplit =
             "start {\n"
             "    if (ready)\n"
             "    {\n"
             "        print(1)\n"
             "    }\n"
             "    else (other) {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         require(formatted(braces) == bracesElseSplit, formatted(braces));
         auto preserve = cwhip::builtinStyle();
         preserve.braceBinding = cwhip::BraceBinding::PreserveWhereLegal;
         require(formatted(braces, preserve) == bracesElseSplit, formatted(braces, preserve));
         auto held = cwhip::builtinStyle();
         held.newlineBeforeElse = false;
         expectSame(braces, held);
         auto preserveHeld = held;
         preserveHeld.braceBinding = cwhip::BraceBinding::PreserveWhereLegal;
         expectSame(braces, preserveHeld);
         auto custom = held;
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
    {"newline after open and close braces", [] {
         const std::string kept =
             "start { # note\n"
             "    print(1)\n"
             "} # done\n";
         expectSame(kept);
         const std::string partial = "start { print(1)\n}\n";
         require(formatted(partial) == "start {\n    print(1)\n}\n", formatted(partial));
         const std::string oneLine = "start { print(1) }\n";
         require(formatted(oneLine) == "start {\n    print(1)\n}\n", "default open");
         const std::string nested =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    } }\n";
         const std::string nestedSplit =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         require(formatted(nested) == nestedSplit, formatted(nested));
         const std::string commentedClose =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    } /* stay */ }\n";
         const auto commented = formatted(commentedClose);
         require(commented.find("/* stay */") != std::string::npos, commented);
         require(commented.find("} /* stay */ }") == std::string::npos, commented);
         const std::string attached =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    } else (other) {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         const std::string attachedSplit =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    else (other) {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         require(formatted(attached) == attachedSplit, formatted(attached));
         require(formatted("start {\n    do { print(1) } while (ready)\n}\n") ==
                     "start {\n    do {\n        print(1)\n    } while (ready)\n}\n",
                 "do/while stays on the close brace");
         require(formatted("start {\n    try { print(1) } except(Exception) { print(2) }\n}\n") ==
                     "start {\n"
                     "    try {\n"
                     "        print(1)\n"
                     "    } except(Exception) {\n"
                     "        print(2)\n"
                     "    }\n"
                     "}\n",
                 "except stays on the close brace");
         const std::string header =
             "start {\n"
             "    if (ready)\n"
             "    {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         expectSame(header);
         const std::string onHeader =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         expectSame(onHeader);

         auto openOff = cwhip::builtinStyle();
         openOff.newlineAfterOpenBrace = false;
         expectSame(partial, openOff);
         require(formatted(oneLine, openOff) == "start { print(1)\n}\n", formatted(oneLine, openOff));
         require(formatted("start {}\n", openOff) == "start {}\n", "empty body stays");
         const std::string noted = "start { print(1) # note\n}\n";
         expectSame(noted, openOff);
         require(formatted(noted).find("# note") != std::string::npos, "hash comment dropped");
         expectSame(header, openOff);
         expectSame(onHeader, openOff);
         require(formatted(attached, openOff) == attachedSplit, formatted(attached, openOff));

         auto closeOff = cwhip::builtinStyle();
         closeOff.newlineAfterCloseBrace = false;
         expectSame(nested, closeOff);
         expectSame(commentedClose, closeOff);
         require(formatted(attached, closeOff) == attachedSplit, formatted(attached, closeOff));
         expectSame(header, closeOff);
         expectSame(onHeader, closeOff);
         require(formatted(oneLine, closeOff) == "start {\n    print(1)\n}\n",
                 "close false still expands a one-line body");

         auto bothOn = cwhip::builtinStyle();
         bothOn.newlineAfterOpenBrace = true;
         bothOn.newlineAfterCloseBrace = true;
         require(formatted(partial, bothOn) == formatted(partial), "explicit true matches default");
         require(formatted(nested, bothOn) == nestedSplit, "explicit close true");

         const auto commentedStyle = parseStyle(
             "# NewlineAfterOpenBrace: true\n"
             "NewlineAfterOpenBrace: false # body may stay\n"
             "NewlineAfterCloseBrace: false\n");
         require(commentedStyle.ok, commentedStyle.diagnostic);
         require(!commentedStyle.style.newlineAfterOpenBrace, "open comment");
         require(!commentedStyle.style.newlineAfterCloseBrace, "close comment");
         expectSame(partial, commentedStyle.style);
         expectSame(nested, commentedStyle.style);
         const auto invalid = parseStyle("NewlineAfterOpenBrace: Never\n");
         require(!invalid.ok, "Never is not a bool");
         require(invalid.diagnostic.find("NewlineAfterOpenBrace") != std::string::npos,
                 invalid.diagnostic);

         auto custom = cwhip::builtinStyle();
         custom.braceBinding = cwhip::BraceBinding::Custom;
         custom.newlineAfterCloseBrace = false;
         custom.newlineBeforeElse = false;
         const std::string splitHeader =
             "start {\n"
             "    if (ready)\n"
             "    {\n"
             "        print(1)\n"
             "    } else (other) {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         const auto bound = formatted(splitHeader, custom);
         require(bound.find("    if (ready) {\n") != std::string::npos, bound);
         require(bound.find("    }\n    else (other) {\n") != std::string::npos, bound);
     }},
    {"newline before open brace leaves the source break", [] {
         const std::string attached = "start {\n    if (ready) { print(1) }\n}\n";
         const std::string expanded =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         require(formatted(attached) == expanded, formatted(attached));
         auto off = cwhip::builtinStyle();
         off.newlineBeforeOpenBrace = false;
         require(formatted(attached, off) == expanded, "false keeps { on the header");
         const std::string allman =
             "start {\n"
             "    if (ready) # note\n"
             "    {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         expectSame(allman);
         expectSame(allman, off);
         auto on = cwhip::builtinStyle();
         on.newlineBeforeOpenBrace = true;
         const std::string allmanMoved =
             "start\n"
             "{\n"
             "    if (ready) # note\n"
             "    {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         require(formatted(allman, on) == allmanMoved, formatted(allman, on));
         const std::string moved =
             "start\n"
             "{\n"
             "    if (ready)\n"
             "    {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         require(formatted(attached, on) == moved, formatted(attached, on));
         const std::string noted = "start {\n    if (ready) { # note\n        print(1)\n    }\n}\n";
         const auto withNote = formatted(noted, on);
         require(withNote.find("# note") != std::string::npos, withNote);
         require(withNote.find("    if (ready)\n") != std::string::npos, withNote);
         const std::string klass =
             "class Box {\n"
             "    int64 value() { return(1) }\n"
             "    destroy { return }\n"
             "    enum { A, B }\n"
             "}\n";
         require(formatted(klass, on) == formatted(klass), formatted(klass, on));
         require(formatted(klass, on).find("class Box {") != std::string::npos, "class brace moved");
         require(formatted(klass, on).find("value() {") != std::string::npos, "method brace moved");
         require(formatted(klass, on).find("destroy {") != std::string::npos, "destroy brace moved");
         require(formatted(klass, on).find("enum {") != std::string::npos, "enum brace moved");
         const std::string method = "int64 Box.value() { return(1) }\n";
         require(formatted(method) == "int64 Box.value() {\n    return(1)\n}\n",
                 formatted(method));
         require(formatted(method, on) == "int64 Box.value()\n{\n    return(1)\n}\n",
                 formatted(method, on));
         const std::string space = "namespace Foo { class Bar { int64 value } }\n";
         const auto names = formatted(space, on);
         require(names.find("namespace Foo\n{\n") != std::string::npos, names);
         require(names.find("class Bar {") != std::string::npos, names);
         const auto commented = parseStyle(
             "# NewlineBeforeOpenBrace: false\n"
             "NewlineBeforeOpenBrace: true # next line\n");
         require(commented.ok, commented.diagnostic);
         require(commented.style.newlineBeforeOpenBrace, "hash comment hid the key");
         const auto invalid = parseStyle("NewlineBeforeOpenBrace: Never\n");
         require(!invalid.ok, "Never is not a bool");
         require(invalid.diagnostic.find("NewlineBeforeOpenBrace") != std::string::npos,
                 invalid.diagnostic);
     }},
    {"newline before else follows its own key", [] {
         const std::string chain =
             "start {\n"
             "    if (ready) { print(1) } else (other) { print(2) } else { print(3) }\n"
             "}\n";
         const std::string split =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    else (other) {\n"
             "        print(2)\n"
             "    }\n"
             "    else {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         const std::string joined =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    } else (other) {\n"
             "        print(2)\n"
             "    } else {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         require(formatted(chain) == split, formatted(chain));
         expectSame(split);
         auto off = cwhip::builtinStyle();
         off.newlineBeforeElse = false;
         require(formatted(chain, off) == joined, formatted(chain, off));
         expectSame(split, off);
         expectSame(joined, off);

         auto closeOff = cwhip::builtinStyle();
         closeOff.newlineAfterCloseBrace = false;
         require(formatted(chain, closeOff) == split, "else breaks with close brace newlines off");
         auto bothOff = closeOff;
         bothOff.newlineBeforeElse = false;
         require(formatted(chain, bothOff) == joined, formatted(chain, bothOff));
         auto closeOn = off;
         closeOn.newlineAfterCloseBrace = true;
         require(formatted(chain, closeOn) == joined, "false keeps else on the brace line");

         const std::string doWhile = "start {\n    do { print(1) } while (ready)\n}\n";
         const std::string doWhileOut =
             "start {\n    do {\n        print(1)\n    } while (ready)\n}\n";
         const std::string handler =
             "start {\n    try { print(1) } except(Exception) { print(2) } finally { print(3) }\n}\n";
         const std::string handlerOut =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    } except(Exception) {\n"
             "        print(2)\n"
             "    } finally {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         require(formatted(doWhile) == doWhileOut, formatted(doWhile));
         require(formatted(doWhile, off) == doWhileOut, "do/while changed with else off");
         require(formatted(handler) == handlerOut, formatted(handler));
         require(formatted(handler, off) == handlerOut, "except or finally changed");

         const auto commented = parseStyle(
             "# NewlineBeforeElse: false\n"
             "NewlineBeforeElse: true # next line\n");
         require(commented.ok, commented.diagnostic);
         require(commented.style.newlineBeforeElse, "hash comment hid the key");
         const auto disabled = parseStyle("NewlineBeforeElse: false\n");
         require(disabled.ok, disabled.diagnostic);
         require(!disabled.style.newlineBeforeElse, "false did not parse");
         const auto invalid = parseStyle("NewlineBeforeElse: Never\n");
         require(!invalid.ok, "Never is not a bool");
         require(invalid.diagnostic.find("NewlineBeforeElse") != std::string::npos,
                 invalid.diagnostic);
         const auto dumped = parseStyle(cwhip::builtinConfigText());
         require(dumped.ok, dumped.diagnostic);
         require(dumped.style.newlineBeforeElse, "dumped default is not true");
         require(cwhip::builtinConfigText().find(
                     "# Put else on the line after }. False leaves it on the } line.\n"
                     "NewlineBeforeElse: true\n") != std::string::npos,
                 "dump comment");
     }},
}};

} // namespace
