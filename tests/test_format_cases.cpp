#include "test_cases.hpp"

#include "cwhip/format/Format.hpp"
#include "cwhip/format/Style.hpp"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <string>
#include <unistd.h>

namespace cwhip {
StyleLoadResult styleFor(const std::string& stylePath);
}

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
    "# Put } on its own line. False leaves it at the end of the line.\n"
    "NewlineBeforeCloseBrace: true\n"
    "# Put else on the line after }. False leaves it on the } line.\n"
    "NewlineBeforeElse: true\n"
    "# Put except on the line after }. Also applies to finally. False leaves it on the } line.\n"
    "NewlineBeforeExcept: true\n"
    "# Break a long parenthesized list after the opening parenthesis.\n"
    "WrapLongParenthesizedList: BreakAfterOpenParen\n"
    "# Wrapped parameters stay one per line.\n"
    "BinPackParameters: false\n"
    "# Wrapped arguments stay one per line.\n"
    "BinPackArguments: false\n"
    "# Insert a blank line around a long control statement.\n"
    "BlankLinesAroundLongControlStatement: true\n"
    "# A control statement longer than this many lines is long.\n"
    "LongControlStatementLines: 10\n"
    "# Reflow hash and slash comments to the column limit.\n"
    "ReflowComments: true\n"
    "# Reflow block comments to the column limit.\n"
    "ReflowBlockComments: false\n"
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
    require(style.reflowBlockComments == builtin.reflowBlockComments, "reflow block");
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
    require(style.newlineBeforeCloseBrace == builtin.newlineBeforeCloseBrace,
            "newline before }");
    require(style.newlineBeforeElse == builtin.newlineBeforeElse, "newline before else");
    require(style.newlineBeforeExcept == builtin.newlineBeforeExcept, "newline before except");
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

struct CwdGuard {
    std::filesystem::path previous;
    CwdGuard() : previous(std::filesystem::current_path()) {}
    ~CwdGuard() {
        std::error_code error;
        std::filesystem::current_path(previous, error);
    }
};

struct PermGuard {
    std::filesystem::path path;
    std::filesystem::perms previous;
    explicit PermGuard(std::filesystem::path target)
        : path(std::move(target)), previous(std::filesystem::status(path).permissions()) {}
    ~PermGuard() {
        std::error_code error;
        std::filesystem::permissions(path, previous, error);
    }
    void deny() const { std::filesystem::permissions(path, std::filesystem::perms::none); }
};

std::string controlWithPrints(const std::string& header, int count, const std::string& afterBrace,
                              bool blanks) {
    std::string text = "start {\n";
    if (blanks) text += "\n";
    text += "    " + header + " {\n";
    for (int index = 1; index <= count; ++index) {
        text += "        print(" + std::to_string(index) + ")\n";
    }
    text += "    }";
    text += afterBrace;
    text += "\n";
    if (blanks) text += "\n";
    text += "    print(0)\n}\n";
    return text;
}

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
         require(!style.reflowBlockComments, "block comments stay put");
         require(style.blankLinesAroundLongControlStatement, "long control blanks");
         require(style.longControlStatementLines == 10, "long control length");
         require(!style.newlineBeforeOpenBrace, "newline before open brace");
         require(style.newlineAfterOpenBrace, "newline after open brace");
         require(style.newlineAfterCloseBrace, "newline after close brace");
         require(style.newlineBeforeCloseBrace, "newline before close brace");
         require(style.newlineBeforeElse, "newline before else");
         require(style.newlineBeforeExcept, "newline before except");
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
             "from \"box_value\"\n");
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
         allowed.newlineBeforeCloseBrace = false;
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
         expectSame("start {\n    const int64 value = 1\n    const int64 later\n    value = later\n}\n");
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
        const std::string assignedWrapped =
            "start {\n"
            "    int64 value = call(\n"
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
        require(formatted(assigned) == assignedWrapped, formatted(assigned));
        const std::string field =
            "class Box {\n"
            "    int64 value = call(alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, kappa, lambda, mu)\n"
            "}\n";
        const std::string fieldWrapped =
            "class Box {\n"
            "    int64 value = call(\n"
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
        require(formatted(field) == fieldWrapped, formatted(field));
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
                     "    }\n"
                     "    except(Exception) {\n"
                     "        print(2)\n"
                     "    }\n"
                     "}\n",
                 "except moves off the close brace");
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
         openOff.newlineBeforeCloseBrace = false;
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
         closeOff.newlineBeforeCloseBrace = false;
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
             "NewlineBeforeCloseBrace: false\n"
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
             "    }\n"
             "    except(Exception) {\n"
             "        print(2)\n"
             "    }\n"
             "    finally {\n"
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
    {"an else clause resets indent", [] {
         const std::string flat =
             "start {\n"
             "    if (left) { print(1) }\n"
             "    else { if (middle) { print(2) }\n"
             "    else { if (right) { print(3) }\n"
             "    else { print(4) } } }\n"
             "}\n";
         const std::string reset =
             "start {\n"
             "    if (left) {\n"
             "        print(1)\n"
             "    }\n"
             "    else {\n"
             "        if (middle) {\n"
             "            print(2)\n"
             "        }\n"
             "        else {\n"
             "            if (right) {\n"
             "                print(3)\n"
             "            }\n"
             "            else {\n"
             "                print(4)\n"
             "            }\n"
             "        }\n"
             "    }\n"
             "}\n";
         auto quiet = cwhip::builtinStyle();
         quiet.blankLinesAroundLongControlStatement = false;
         require(formatted(flat, quiet) == reset, formatted(flat, quiet));
         expectSame(reset, quiet);
         const std::string withBlanks =
             "start {\n"
             "\n"
             "    if (left) {\n"
             "        print(1)\n"
             "    }\n"
             "    else {\n"
             "\n"
             "        if (middle) {\n"
             "            print(2)\n"
             "        }\n"
             "        else {\n"
             "            if (right) {\n"
             "                print(3)\n"
             "            }\n"
             "            else {\n"
             "                print(4)\n"
             "            }\n"
             "        }\n"
             "\n"
             "    }\n"
             "\n"
             "}\n";
         require(formatted(flat) == withBlanks, formatted(flat));
         expectSame(withBlanks);
         const std::string over =
             "start {\n"
             "    if (left) {\n"
             "        print(1)\n"
             "    }\n"
             "            else {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         const std::string aligned =
             "start {\n"
             "    if (left) {\n"
             "        print(1)\n"
             "    }\n"
             "    else {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         require(formatted(over) == aligned, formatted(over));
         expectSame(aligned);
     }},
    {"newline before except follows its own key", [] {
         const std::string chain =
             "start {\n"
             "    try { print(1) } except(Exception) { print(2) } finally { print(3) }\n"
             "}\n";
         const std::string split =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    }\n"
             "    except(Exception) {\n"
             "        print(2)\n"
             "    }\n"
             "    finally {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         const std::string joined =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    } except(Exception) {\n"
             "        print(2)\n"
             "    } finally {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         require(formatted(chain) == split, formatted(chain));
         expectSame(split);
         auto off = cwhip::builtinStyle();
         off.newlineBeforeExcept = false;
         require(formatted(chain, off) == joined, formatted(chain, off));
         expectSame(split, off);
         expectSame(joined, off);

         const std::string finallyOnly = "start {\n    try { print(1) } finally { print(2) }\n}\n";
         const std::string finallySplit =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    }\n"
             "    finally {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         const std::string finallyJoined =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    } finally {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         require(formatted(finallyOnly) == finallySplit, formatted(finallyOnly));
         require(formatted(finallyOnly, off) == finallyJoined, formatted(finallyOnly, off));
         expectSame(finallySplit, off);

         auto closeOff = cwhip::builtinStyle();
         closeOff.newlineAfterCloseBrace = false;
         require(formatted(chain, closeOff) == split,
                 "except breaks with close brace newlines off");
         auto bothOff = closeOff;
         bothOff.newlineBeforeExcept = false;
         require(formatted(chain, bothOff) == joined, formatted(chain, bothOff));
         auto closeOn = off;
         closeOn.newlineAfterCloseBrace = true;
         require(formatted(chain, closeOn) == joined, "false keeps except on the brace line");

         auto elseOff = cwhip::builtinStyle();
         elseOff.newlineBeforeElse = false;
         require(formatted(chain, elseOff) == split, "else key moved except or finally");
         auto elseOn = off;
         elseOn.newlineBeforeElse = true;
         require(formatted(chain, elseOn) == joined, "except false moved with else");

         const std::string elseChain =
             "start {\n"
             "    if (ready) { print(1) } else { print(2) }\n"
             "    try { print(3) } except(Exception) { print(4) } finally { print(5) }\n"
             "    do { print(6) } while (ready)\n"
             "}\n";
         const std::string elseHeld =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    } else {\n"
             "        print(2)\n"
             "    }\n"
             "    try {\n"
             "        print(3)\n"
             "    }\n"
             "    except(Exception) {\n"
             "        print(4)\n"
             "    }\n"
             "    finally {\n"
             "        print(5)\n"
             "    }\n"
             "    do {\n"
             "        print(6)\n"
             "    } while (ready)\n"
             "}\n";
         const std::string exceptHeld =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    else {\n"
             "        print(2)\n"
             "    }\n"
             "    try {\n"
             "        print(3)\n"
             "    } except(Exception) {\n"
             "        print(4)\n"
             "    } finally {\n"
             "        print(5)\n"
             "    }\n"
             "    do {\n"
             "        print(6)\n"
             "    } while (ready)\n"
             "}\n";
         require(formatted(elseChain, elseOff) == elseHeld, formatted(elseChain, elseOff));
         require(formatted(elseChain, off) == exceptHeld, formatted(elseChain, off));

         const std::string doWhile = "start {\n    do { print(1) } while (ready)\n}\n";
         const std::string doWhileOut =
             "start {\n    do {\n        print(1)\n    } while (ready)\n}\n";
         require(formatted(doWhile) == doWhileOut, formatted(doWhile));
         require(formatted(doWhile, off) == doWhileOut, "do/while changed");

         const auto commented = parseStyle(
             "# NewlineBeforeExcept: false\n"
             "NewlineBeforeExcept: true # next line\n");
         require(commented.ok, commented.diagnostic);
         require(commented.style.newlineBeforeExcept, "hash comment hid the key");
         const auto disabled = parseStyle("NewlineBeforeExcept: false\n");
         require(disabled.ok, disabled.diagnostic);
         require(!disabled.style.newlineBeforeExcept, "false did not parse");
         const auto invalid = parseStyle("NewlineBeforeExcept: Never\n");
         require(!invalid.ok, "Never is not a bool");
         require(invalid.diagnostic.find("NewlineBeforeExcept") != std::string::npos,
                 invalid.diagnostic);
         const auto dumped = parseStyle(cwhip::builtinConfigText());
         require(dumped.ok, dumped.diagnostic);
         require(dumped.style.newlineBeforeExcept, "dumped default is not true");
         require(cwhip::builtinConfigText().find(
                     "# Put except on the line after }. Also applies to finally. "
                     "False leaves it on the } line.\n"
                     "NewlineBeforeExcept: true\n") != std::string::npos,
                 "dump comment");
     }},
    {"newline before close brace follows its own key", [] {
         const std::string trailing =
             "start {\n"
             "    print(1) }\n";
         const std::string trailingSplit =
             "start {\n"
             "    print(1)\n"
             "}\n";
         require(formatted(trailing) == trailingSplit, formatted(trailing));
         expectSame(trailingSplit);
         auto off = cwhip::builtinStyle();
         off.newlineBeforeCloseBrace = false;
         expectSame(trailing, off);

         const std::string shortBlock = "start { print(1) }\n";
         const std::string shortHeld = shortBlock;
         const std::string shortSplit = "start { print(1)\n}\n";
         auto kept = off;
         kept.allowShortBlocks = cwhip::AllowShortBlocks::Other;
         expectSame(shortHeld, kept);
         auto keptOn = kept;
         keptOn.newlineBeforeCloseBrace = true;
         require(formatted(shortBlock, keptOn) == shortSplit, formatted(shortBlock, keptOn));
         expectSame(shortSplit, keptOn);
         require(formatted(shortBlock) == "start {\n    print(1)\n}\n",
                 "default still expands a one-line block");

         const std::string method = "class Box {\n    int64 value() { return(1) }\n}\n";
         const std::string methodHeld = method;
         const std::string methodSplit =
             "class Box {\n"
             "    int64 value() { return(1)\n"
             "    }\n"
             "}\n";
         auto functions = kept;
         functions.allowShortFunctions = cwhip::AllowShortFunctions::Other;
         expectSame(methodHeld, functions);
         auto functionsOn = functions;
         functionsOn.newlineBeforeCloseBrace = true;
         require(formatted(method, functionsOn) == methodSplit, formatted(method, functionsOn));
         expectSame(methodSplit, functionsOn);

         const std::string enumeration = "class Box {\n    enum { A, B }\n}\n";
         const std::string enumSplit =
             "class Box {\n"
             "    enum { A, B\n"
             "    }\n"
             "}\n";
         auto enums = off;
         enums.allowShortEnums = true;
         expectSame(enumeration, enums);
         auto enumsOn = enums;
         enumsOn.newlineBeforeCloseBrace = true;
         require(formatted(enumeration, enumsOn) == enumSplit, formatted(enumeration, enumsOn));
         expectSame(enumSplit, enumsOn);

         const std::string doLine = "start {\n    do { print(1) } while (ready)\n}\n";
         const std::string doSplit =
             "start {\n"
             "    do { print(1)\n"
             "    } while (ready)\n"
             "}\n";
         auto loops = kept;
         loops.allowShortLoops = true;
         expectSame(doLine, loops);
         auto loopsOn = loops;
         loopsOn.newlineBeforeCloseBrace = true;
         require(formatted(doLine, loopsOn) == doSplit, formatted(doLine, loopsOn));
         expectSame(doSplit, loopsOn);

         const std::string empty = "start {}\n";
         auto openOff = off;
         openOff.newlineAfterOpenBrace = false;
         require(formatted(empty, openOff) == empty, "false leaves an empty brace pair");
         auto openOn = openOff;
         openOn.newlineBeforeCloseBrace = true;
         require(formatted(empty, openOn) == "start {\n}\n", formatted(empty, openOn));

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
         auto closeOff = off;
         closeOff.newlineAfterCloseBrace = false;
         expectSame(nested, closeOff);
         auto closeOn = closeOff;
         closeOn.newlineBeforeCloseBrace = true;
         require(formatted(nested, closeOn) == nestedSplit, formatted(nested, closeOn));

         const std::string commented =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    } /* stay */ }\n";
         expectSame(commented, closeOff);
         const auto moved = formatted(commented, closeOn);
         require(moved.find("} /* stay */ }") == std::string::npos, moved);
         require(moved.find("/* stay */") != std::string::npos, moved);
         require(moved.find("\n} /* stay */ }") == std::string::npos, moved);

         const std::string doWhile = "start {\n    do { print(1) } while (ready)\n}\n";
         const std::string doWhileOut =
             "start {\n    do {\n        print(1)\n    } while (ready)\n}\n";
         require(formatted(doWhile) == doWhileOut, formatted(doWhile));
         require(formatted(doWhile, off) == doWhileOut, "false moved while");
         expectSame(doWhileOut);
         expectSame(doWhileOut, off);

         const auto commentedStyle = parseStyle(
             "# NewlineBeforeCloseBrace: false\n"
             "NewlineBeforeCloseBrace: true # next line\n");
         require(commentedStyle.ok, commentedStyle.diagnostic);
         require(commentedStyle.style.newlineBeforeCloseBrace, "hash comment hid the key");
         const auto disabled = parseStyle("NewlineBeforeCloseBrace: false\n");
         require(disabled.ok, disabled.diagnostic);
         require(!disabled.style.newlineBeforeCloseBrace, "false did not parse");
         const auto invalid = parseStyle("NewlineBeforeCloseBrace: Never\n");
         require(!invalid.ok, "Never is not a bool");
         require(invalid.diagnostic.find("NewlineBeforeCloseBrace") != std::string::npos,
                 invalid.diagnostic);
         const auto dumped = parseStyle(cwhip::builtinConfigText());
         require(dumped.ok, dumped.diagnostic);
         require(dumped.style.newlineBeforeCloseBrace, "dumped default is not true");
         require(cwhip::builtinConfigText().find(
                     "# Put } on its own line. False leaves it at the end of the line.\n"
                     "NewlineBeforeCloseBrace: true\n") != std::string::npos,
                 "dump comment");
     }},
    {"reflow block comments follows its own key", [] {
         const std::string block =
             "start {\n"
             "    /* alpha beta gamma delta epsilon zeta\n"
             "       eta theta iota kappa */\n"
             "    print(1)\n"
             "}\n";
         const std::string reflowedBlock =
             "start {\n"
             "    /* alpha beta gamma delta epsilon\n"
             "     * zeta eta theta iota kappa */\n"
             "    print(1)\n"
             "}\n";
         expectSame(block);
         auto on = cwhip::builtinStyle();
         on.reflowBlockComments = true;
         on.columnLimit = 40;
         require(formatted(block, on) == reflowedBlock, formatted(block, on));
         require(formatted(reflowedBlock, on) == reflowedBlock, "reflow was not stable");
         const std::string joined =
             "start {\n"
             "    /* alpha beta\n"
             "       gamma */\n"
             "    print(1)\n"
             "}\n";
         const std::string joinedOut =
             "start {\n"
             "    /* alpha beta gamma */\n"
             "    print(1)\n"
             "}\n";
         auto wide = cwhip::builtinStyle();
         wide.reflowBlockComments = true;
         require(formatted(joined, wide) == joinedOut, formatted(joined, wide));
         require(formatted(joinedOut, wide) == joinedOut, "joined reflow was not stable");
         const std::string inside =
             "start {\n"
             "    print(/* alpha beta\n"
             "            gamma */ 1)\n"
             "}\n";
         const std::string insideOut =
             "start {\n"
             "    print(/* alpha beta gamma */ 1)\n"
             "}\n";
         require(formatted(inside, wide) == insideOut, formatted(inside, wide));
         auto off = on;
         off.reflowBlockComments = false;
         expectSame(block, off);

         const std::string line =
             "start {\n"
             "    /* alpha beta gamma delta epsilon zeta eta theta iota kappa */\n"
             "    print(1)\n"
             "}\n";
         require(formatted(line, on) == reflowedBlock, formatted(line, on));
         expectSame(line, off);

         const std::string mixed =
             "start {\n"
             "    // alpha beta gamma delta epsilon zeta eta\n"
             "    /* alpha beta gamma delta epsilon zeta\n"
             "       eta theta iota kappa */\n"
             "    print(1)\n"
             "}\n";
         const std::string mixedReflowedLines =
             "start {\n"
             "    // alpha beta gamma delta epsilon\n"
             "    // zeta eta\n"
             "    /* alpha beta gamma delta epsilon zeta\n"
             "       eta theta iota kappa */\n"
             "    print(1)\n"
             "}\n";
         const std::string mixedReflowedBlock =
             "start {\n"
             "    // alpha beta gamma delta epsilon zeta eta\n"
             "    /* alpha beta gamma delta epsilon\n"
             "     * zeta eta theta iota kappa */\n"
             "    print(1)\n"
             "}\n";
         auto linesOnly = on;
         linesOnly.reflowBlockComments = false;
         require(formatted(mixed, linesOnly) == mixedReflowedLines, formatted(mixed, linesOnly));
         auto blocksOnly = on;
         blocksOnly.reflowComments = false;
         require(formatted(mixed, blocksOnly) == mixedReflowedBlock, formatted(mixed, blocksOnly));

         const std::string fitting = "start {\n    print(1) /* stay */\n}\n";
         expectSame(fitting, on);
         auto unlimited = on;
         unlimited.columnLimit = 0;
         expectSame(block, unlimited);

         const std::string straddling =
             "start {\n"
             "    print(1) /* comment\n"
             "still a comment */ print(2)\n"
             "}\n";
         expectSame(straddling, on);

         const auto enabled = parseStyle("ReflowBlockComments: true\n");
         require(enabled.ok, enabled.diagnostic);
         require(enabled.style.reflowBlockComments, "true did not parse");
         const auto disabled = parseStyle("ReflowBlockComments: false\n");
         require(disabled.ok, disabled.diagnostic);
         require(!disabled.style.reflowBlockComments, "false did not parse");
         const auto dumped = parseStyle(cwhip::builtinConfigText());
         require(dumped.ok, dumped.diagnostic);
         require(!dumped.style.reflowBlockComments, "dumped default is not false");
         require(cwhip::builtinConfigText().find(
                     "# Reflow block comments to the column limit.\n"
                     "ReflowBlockComments: false\n") != std::string::npos,
                 "dump comment");
     }},
    {"long controls respect the blank line switch and the line count", [] {
         const std::string longIf = controlWithPrints("if (ready)", 9, "", false);
         const std::string longIfBlanks = controlWithPrints("if (ready)", 9, "", true);
         require(formatted(longIf) == longIfBlanks, formatted(longIf));
         auto off = cwhip::builtinStyle();
         off.blankLinesAroundLongControlStatement = false;
         require(formatted(longIf, off) == longIf, formatted(longIf, off));
         expectSame(longIfBlanks, off);
         const std::string exact = controlWithPrints("if (ready)", 8, "", false);
         expectSame(exact);
         auto three = cwhip::builtinStyle();
         three.longControlStatementLines = 3;
         const std::string four = controlWithPrints("if (ready)", 2, "", false);
         const std::string fourBlanks = controlWithPrints("if (ready)", 2, "", true);
         const std::string threeLines = controlWithPrints("if (ready)", 1, "", false);
         require(formatted(four, three) == fourBlanks, formatted(four, three));
         expectSame(threeLines, three);
         const std::string longWhile = controlWithPrints("while (ready)", 9, "", false);
         const std::string longFor = controlWithPrints("for (value in items)", 9, "", false);
         const std::string longDo = controlWithPrints("do", 9, " while (ready)", false);
         require(formatted(longWhile) == controlWithPrints("while (ready)", 9, "", true),
                 formatted(longWhile));
         require(formatted(longFor) == controlWithPrints("for (value in items)", 9, "", true),
                 formatted(longFor));
         require(formatted(longDo) == controlWithPrints("do", 9, " while (ready)", true),
                 formatted(longDo));
         require(formatted(longWhile, off) == longWhile, "false inserted a blank around while");
         const std::string longSwitch =
             "start {\n"
             "    switch (value) {\n"
             "        case (1) {\n"
             "            print(1)\n"
             "            print(2)\n"
             "            print(3)\n"
             "            print(4)\n"
             "            print(5)\n"
             "            print(6)\n"
             "            print(7)\n"
             "        }\n"
             "    }\n"
             "    print(0)\n"
             "}\n";
         const std::string longSwitchBlanks =
             "start {\n"
             "\n"
             "    switch (value) {\n"
             "        case (1) {\n"
             "            print(1)\n"
             "            print(2)\n"
             "            print(3)\n"
             "            print(4)\n"
             "            print(5)\n"
             "            print(6)\n"
             "            print(7)\n"
             "        }\n"
             "    }\n"
             "\n"
             "    print(0)\n"
             "}\n";
         require(formatted(longSwitch) == longSwitchBlanks, formatted(longSwitch));
         require(formatted(longSwitch, off) == longSwitch, formatted(longSwitch, off));
     }},
    {"short blocks and short statements stay together on their own keys", [] {
         const std::string start = "start { print(1) }\n";
         const std::string startSplit = "start {\n    print(1)\n}\n";
         const std::string ifLine = "start {\n    if (ready) { print(1) }\n}\n";
         const std::string ifSplit =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         const std::string whileLine = "start {\n    while (ready) { print(1) }\n}\n";
         const std::string whileSplit =
             "start {\n"
             "    while (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         const std::string forLine = "start {\n    for (value in items) { print(value) }\n}\n";
         const std::string doLine = "start {\n    do { print(1) } while (ready)\n}\n";
         const std::string method = "class Box {\n    int64 value() { return(1) }\n}\n";
         const std::string methodSplit =
             "class Box {\n"
             "    int64 value() {\n"
             "        return(1)\n"
             "    }\n"
             "}\n";
         auto blocks = cwhip::builtinStyle();
         blocks.allowShortBlocks = cwhip::AllowShortBlocks::Other;
         blocks.newlineBeforeCloseBrace = false;
         expectSame(start, blocks);
         require(formatted(ifLine, blocks) == ifSplit, "blocks alone kept an if");
         require(formatted(method, blocks) == methodSplit, "blocks alone kept a function");
         auto iff = blocks;
         iff.allowShortIf = cwhip::AllowShortIf::Other;
         expectSame(ifLine, iff);
         auto loops = blocks;
         loops.allowShortLoops = true;
         expectSame(whileLine, loops);
         expectSame(forLine, loops);
         expectSame(doLine, loops);
         require(formatted(whileLine, blocks) == whileSplit, "blocks alone kept a loop");
         auto functions = blocks;
         functions.allowShortFunctions = cwhip::AllowShortFunctions::Other;
         expectSame(method, functions);
         require(formatted(ifLine, functions) == ifSplit, "functions alone kept an if");
         auto functionsDenied = cwhip::builtinStyle();
         functionsDenied.allowShortFunctions = cwhip::AllowShortFunctions::Other;
         functionsDenied.allowShortIf = cwhip::AllowShortIf::Other;
         functionsDenied.allowShortLoops = true;
         require(formatted(method, functionsDenied) == methodSplit, formatted(method, functionsDenied));
         require(formatted(ifLine, functionsDenied) == ifSplit, formatted(ifLine, functionsDenied));
         require(formatted(whileLine, functionsDenied) == whileSplit,
                 formatted(whileLine, functionsDenied));
         auto closeOff = blocks;
         closeOff.newlineAfterCloseBrace = false;
         expectSame("namespace Foo { class Bar { int64 value } }\n", closeOff);
         auto tryKept = closeOff;
         tryKept.newlineBeforeExcept = false;
         expectSame(
             "start { try { print(1) } except(Exception) { print(2) } finally { print(3) } }\n",
             tryKept);
         auto elseKept = closeOff;
         elseKept.allowShortIf = cwhip::AllowShortIf::Other;
         elseKept.newlineBeforeElse = false;
         expectSame("start { if (ready) { print(1) } else { print(2) } }\n", elseKept);

         const char* keepFunctions[] = {"All", "true", "Inline", "Empty"};
         for (const char* spelling : keepFunctions) {
             const auto loaded = parseStyle(
                 std::string("NewlineBeforeCloseBrace: false\n"
                             "AllowShortBlocksOnASingleLine: Always\n"
                             "AllowShortFunctionsOnASingleLine: ") +
                 spelling + "\n");
             require(loaded.ok, loaded.diagnostic);
             expectSame(method, loaded.style);
         }
         const char* splitFunctions[] = {"None", "false"};
         for (const char* spelling : splitFunctions) {
             const auto loaded = parseStyle(
                 std::string("AllowShortBlocksOnASingleLine: Always\n"
                             "AllowShortFunctionsOnASingleLine: ") +
                 spelling + "\n");
             require(loaded.ok, loaded.diagnostic);
             require(formatted(method, loaded.style) == methodSplit, spelling);
         }
         const char* keepBlocks[] = {"Always", "true", "Empty"};
         for (const char* spelling : keepBlocks) {
             const auto loaded = parseStyle(
                 std::string("NewlineBeforeCloseBrace: false\n"
                             "AllowShortBlocksOnASingleLine: ") +
                 spelling + "\n");
             require(loaded.ok, loaded.diagnostic);
             expectSame(start, loaded.style);
         }
         const char* splitBlocks[] = {"Never", "false"};
         for (const char* spelling : splitBlocks) {
             const auto loaded = parseStyle(std::string("AllowShortBlocksOnASingleLine: ") +
                                            spelling + "\n");
             require(loaded.ok, loaded.diagnostic);
             require(formatted(start, loaded.style) == startSplit, spelling);
         }
         const char* keepIf[] = {"Always", "true"};
         for (const char* spelling : keepIf) {
             const auto loaded = parseStyle(
                 std::string("NewlineBeforeCloseBrace: false\n"
                             "AllowShortBlocksOnASingleLine: Always\n"
                             "AllowShortIfStatementsOnASingleLine: ") +
                 spelling + "\n");
             require(loaded.ok, loaded.diagnostic);
             expectSame(ifLine, loaded.style);
         }
         const char* splitIf[] = {"Never", "false"};
         for (const char* spelling : splitIf) {
             const auto loaded = parseStyle(
                 std::string("AllowShortBlocksOnASingleLine: Always\n"
                             "AllowShortIfStatementsOnASingleLine: ") +
                 spelling + "\n");
             require(loaded.ok, loaded.diagnostic);
             require(formatted(ifLine, loaded.style) == ifSplit, spelling);
         }
         const auto loopsOn = parseStyle(
             "NewlineBeforeCloseBrace: false\n"
             "AllowShortBlocksOnASingleLine: Always\n"
             "AllowShortLoopsOnASingleLine: true\n");
         require(loopsOn.ok, loopsOn.diagnostic);
         expectSame(whileLine, loopsOn.style);
         const auto loopsOff = parseStyle(
             "AllowShortBlocksOnASingleLine: Always\n"
             "AllowShortLoopsOnASingleLine: false\n");
         require(loopsOff.ok, loopsOff.diagnostic);
         require(formatted(whileLine, loopsOff.style) == whileSplit, formatted(whileLine, loopsOff.style));
         const auto badFunction = parseStyle("AllowShortFunctionsOnASingleLine: Sometimes\n");
         require(!badFunction.ok, "Sometimes was accepted");
         require(badFunction.diagnostic.find("AllowShortFunctionsOnASingleLine") != std::string::npos,
                 badFunction.diagnostic);
         const auto badBlock = parseStyle("AllowShortBlocksOnASingleLine: Sometimes\n");
         require(!badBlock.ok &&
                     badBlock.diagnostic.find("AllowShortBlocksOnASingleLine") != std::string::npos,
                 badBlock.diagnostic);
         const auto badIf = parseStyle("AllowShortIfStatementsOnASingleLine: Sometimes\n");
         require(!badIf.ok && badIf.diagnostic.find("AllowShortIfStatementsOnASingleLine") !=
                                  std::string::npos,
                 badIf.diagnostic);
     }},
    {"control parentheses gain a space and calls lose one", [] {
         const std::string source =
             "start {\n"
             "    if(ready) { print(1) }\n"
             "    while(ready) { print(1) }\n"
             "    for(value in items) { print(value) }\n"
             "    switch(value) { case(1) { print(1) } default { print(0) } }\n"
             "    do { print(1) } while(ready)\n"
             "    longCall (1)\n"
             "    print (2)\n"
             "    print(3)\n"
             "    return (4)\n"
             "    return(5)\n"
             "    raise (Error())\n"
             "    raise(Error())\n"
             "    try { print(6) } except (Exception) { print(7) }\n"
             "    try { print(8) } except(Other) { print(9) }\n"
             "    print(items[0] (1))\n"
             "    print((ready) (1))\n"
             "    print(items > (1))\n"
             "    print(\"name\" (1))\n"
             "}\n";
         const std::string untouched =
             "start {\n"
             "    if(ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    while(ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    for(value in items) {\n"
             "        print(value)\n"
             "    }\n"
             "    switch(value) {\n"
             "        case(1) {\n"
             "            print(1)\n"
             "        }\n"
             "        default {\n"
             "            print(0)\n"
             "        }\n"
             "    }\n"
             "    do {\n"
             "        print(1)\n"
             "    } while(ready)\n"
             "    longCall (1)\n"
             "    print (2)\n"
             "    print(3)\n"
             "    return (4)\n"
             "    return(5)\n"
             "    raise (Error())\n"
             "    raise(Error())\n"
             "    try {\n"
             "        print(6)\n"
             "    }\n"
             "    except (Exception) {\n"
             "        print(7)\n"
             "    }\n"
             "    try {\n"
             "        print(8)\n"
             "    }\n"
             "    except(Other) {\n"
             "        print(9)\n"
             "    }\n"
             "    print(items[0] (1))\n"
             "    print((ready) (1))\n"
             "    print(items > (1))\n"
             "    print(\"name\" (1))\n"
             "}\n";
         const std::string spaced =
             "start {\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    while (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    for (value in items) {\n"
             "        print(value)\n"
             "    }\n"
             "    switch (value) {\n"
             "        case(1) {\n"
             "            print(1)\n"
             "        }\n"
             "        default {\n"
             "            print(0)\n"
             "        }\n"
             "    }\n"
             "    do {\n"
             "        print(1)\n"
             "    } while (ready)\n"
             "    longCall(1)\n"
             "    print (2)\n"
             "    print(3)\n"
             "    return (4)\n"
             "    return(5)\n"
             "    raise (Error())\n"
             "    raise(Error())\n"
             "    try {\n"
             "        print(6)\n"
             "    }\n"
             "    except (Exception) {\n"
             "        print(7)\n"
             "    }\n"
             "    try {\n"
             "        print(8)\n"
             "    }\n"
             "    except(Other) {\n"
             "        print(9)\n"
             "    }\n"
             "    print(items[0](1))\n"
             "    print((ready)(1))\n"
             "    print(items >(1))\n"
             "    print(\"name\"(1))\n"
             "}\n";
         require(formatted(source) == untouched, formatted(source));
         auto controls = cwhip::builtinStyle();
         controls.spaceBeforeParens = cwhip::SpaceBeforeParens::ControlStatements;
         require(formatted(source, controls) == spaced, formatted(source, controls));
     }},
    {"long parameters and bracket lists wrap and strings stay whole", [] {
         const std::string params =
             "class Box {\n"
             "    int64 value(int64 alpha, int64 beta, int64 gamma, int64 delta, int64 epsilon, "
             "int64 zeta, int64 eta, int64 theta) {\n"
             "        return(1)\n"
             "    }\n"
             "}\n";
         const std::string paramsWrapped =
             "class Box {\n"
             "    int64 value(\n"
             "            int64 alpha,\n"
             "            int64 beta,\n"
             "            int64 gamma,\n"
             "            int64 delta,\n"
             "            int64 epsilon,\n"
             "            int64 zeta,\n"
             "            int64 eta,\n"
             "            int64 theta) {\n"
             "        return(1)\n"
             "    }\n"
             "}\n";
         require(formatted(params) == paramsWrapped, formatted(params));
         const auto packParams = parseStyle("BinPackParameters: true\n");
         require(packParams.ok, packParams.diagnostic);
         require(formatted(params, packParams.style) == paramsWrapped,
                 formatted(params, packParams.style));
         require(formatted("class Box {\n    int64 value(int64 alpha) { return(1) }\n}\n") ==
                     "class Box {\n    int64 value(int64 alpha) {\n        return(1)\n    }\n}\n",
                 "a short parameter list wrapped");
         const std::string list =
             "start {\n"
             "    print([alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, kappa, "
             "lambda, mu])\n"
             "}\n";
         const std::string listWrapped =
             "start {\n"
             "    print([\n"
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
             "            mu])\n"
             "}\n";
         require(formatted(list) == listWrapped, formatted(list));
         expectSame("start {\n    print([alpha, beta])\n}\n");
         const auto packArgs = parseStyle("BinPackArguments: true\n");
         require(packArgs.ok, packArgs.diagnostic);
         require(formatted(kLongCall, packArgs.style) == kWrappedCall, formatted(kLongCall, packArgs.style));
         const std::string text =
             "start {\n"
             "    strg label = "
             "\"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghij\"\n"
             "}\n";
         const auto label = text.substr(text.find('\n') + 1);
         require(label.find('\n') > 80, "string line is not past the column limit");
         expectSame(text);
         auto breaking = cwhip::builtinStyle();
         breaking.breakStringLiterals = true;
         expectSame(text, breaking);
         const auto parsed = parseStyle("BreakStringLiterals: true\n");
         require(parsed.ok, parsed.diagnostic);
         expectSame(text, parsed.style);
     }},
    {"hash comments reflow unless the column limit is zero", [] {
         auto narrow = cwhip::builtinStyle();
         narrow.columnLimit = 40;
         const std::string lines =
             "start {\n"
             "    # alpha beta gamma delta epsilon zeta eta\n"
             "    // alpha beta gamma delta epsilon zeta eta\n"
             "    print(1)\n"
             "}\n";
         const std::string wrapped =
             "start {\n"
             "    # alpha beta gamma delta epsilon\n"
             "    # zeta eta\n"
             "    // alpha beta gamma delta epsilon\n"
             "    // zeta eta\n"
             "    print(1)\n"
             "}\n";
         require(formatted(lines, narrow) == wrapped, formatted(lines, narrow));
         auto quiet = narrow;
         quiet.reflowComments = false;
         expectSame(lines, quiet);
         auto unlimited = cwhip::builtinStyle();
         unlimited.columnLimit = 0;
         expectSame(lines, unlimited);
         const std::string codeLine =
             "start {\n"
             "    if(ready) { print(1) } # test: alpha beta gamma delta epsilon zeta eta theta "
             "iota kappa lambda mu\n"
             "}\n";
         const std::string codeReflowed =
             "start {\n"
             "    if(ready) {\n"
             "        print(1)\n"
             "    } # test: alpha beta gamma delta\n"
             "    # epsilon zeta eta theta iota kappa\n"
             "    # lambda mu\n"
             "}\n";
         require(formatted(codeLine, narrow) == codeReflowed, formatted(codeLine, narrow));
         auto frozen = narrow;
         frozen.commentPragmas = "^test:";
         expectSame(codeLine, frozen);
         const std::string hashLines =
             "start {\n"
             "    # test: alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu\n"
             "    # ordinary alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu\n"
             "    print(1)\n"
             "}\n";
         const std::string hashKept =
             "start {\n"
             "    # test: alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu\n"
             "    # ordinary alpha beta gamma delta\n"
             "    # epsilon zeta eta theta iota kappa\n"
             "    # lambda mu\n"
             "    print(1)\n"
             "}\n";
         require(formatted(hashLines, frozen) == hashKept, formatted(hashLines, frozen));
         auto empty = narrow;
         empty.commentPragmas = "";
         require(formatted(hashLines, empty) == formatted(hashLines, narrow),
                 "empty quotes protected a hash comment");
         const auto unquoted = parseStyle("CommentPragmas: ^test:\n");
         require(!unquoted.ok, "unquoted pragma");
         require(unquoted.diagnostic.find("CommentPragmas must be a quoted string") !=
                     std::string::npos,
                 unquoted.diagnostic);
         const auto quotes = parseStyle("CommentPragmas: \"\"\n");
         require(quotes.ok && quotes.style.commentPragmas && quotes.style.commentPragmas->empty(),
                 "empty double quotes");
     }},
    {"else if and a newline before except's parenthesis are format errors", [] {
         const std::string chain =
             "start {\n    if (ready) { print(1) } else if (other) { print(2) }\n}\n";
         const auto failed = cwhip::formatSource(chain, cwhip::builtinStyle(), "joined.cw");
         require(!failed.ok, "else if was formatted");
         require(failed.text == chain, "else if rewrote the file");
         require(failed.diagnostic.find("else if is not a statement") != std::string::npos,
                 failed.diagnostic);
         const auto allowed = parseStyle("ForbidElseIf: false\n");
         require(allowed.ok, allowed.diagnostic);
         const auto still = cwhip::formatSource(chain, allowed.style, "joined.cw");
         require(!still.ok && still.text == chain, "ForbidElseIf false accepted else if");
         require(still.diagnostic.find("else if is not a statement") != std::string::npos,
                 still.diagnostic);
         const std::string split =
             "start {\n    try { print(1) } except\n    (Exception) { print(2) }\n}\n";
         const auto moved = cwhip::formatSource(split, cwhip::builtinStyle(), "except.cw");
         require(!moved.ok && moved.text == split, "except parenthesis was joined");
         require(moved.diagnostic.find("newline between except and '('") != std::string::npos,
                 moved.diagnostic);
     }},
    {"open braces move for loops switch try and else", [] {
         auto on = cwhip::builtinStyle();
         on.newlineBeforeOpenBrace = true;
         on.blankLinesAroundLongControlStatement = false;
         require(formatted("start { while (ready) { print(1) } }\n", on) ==
                     "start\n"
                     "{\n"
                     "    while (ready)\n"
                     "    {\n"
                     "        print(1)\n"
                     "    }\n"
                     "}\n",
                 formatted("start { while (ready) { print(1) } }\n", on));
         require(formatted("start { for (value in items) { print(value) } }\n", on) ==
                     "start\n"
                     "{\n"
                     "    for (value in items)\n"
                     "    {\n"
                     "        print(value)\n"
                     "    }\n"
                     "}\n",
                 formatted("start { for (value in items) { print(value) } }\n", on));
         require(formatted(
                     "start { switch (value) { case (1) { print(1) } default { print(0) } } }\n",
                     on) ==
                     "start\n"
                     "{\n"
                     "    switch (value)\n"
                     "    {\n"
                     "        case (1)\n"
                     "        {\n"
                     "            print(1)\n"
                     "        }\n"
                     "        default\n"
                     "        {\n"
                     "            print(0)\n"
                     "        }\n"
                     "    }\n"
                     "}\n",
                 "switch braces");
         require(formatted("start { do { print(1) } while (ready) }\n", on) ==
                     "start\n"
                     "{\n"
                     "    do\n"
                     "    {\n"
                     "        print(1)\n"
                     "    } while (ready)\n"
                     "}\n",
                 "do brace");
         require(formatted(
                     "start { try { print(1) } except(Exception) { print(2) } finally { print(3) } }\n",
                     on) ==
                     "start\n"
                     "{\n"
                     "    try\n"
                     "    {\n"
                     "        print(1)\n"
                     "    }\n"
                     "    except(Exception)\n"
                     "    {\n"
                     "        print(2)\n"
                     "    }\n"
                     "    finally\n"
                     "    {\n"
                     "        print(3)\n"
                     "    }\n"
                     "}\n",
                 "try braces");
         require(formatted(
                     "start { if (ready) { print(1) } else (other) { print(2) } else { print(3) } }\n",
                     on) ==
                     "start\n"
                     "{\n"
                     "    if (ready)\n"
                     "    {\n"
                     "        print(1)\n"
                     "    }\n"
                     "    else (other)\n"
                     "    {\n"
                     "        print(2)\n"
                     "    }\n"
                     "    else\n"
                     "    {\n"
                     "        print(3)\n"
                     "    }\n"
                     "}\n",
                 "else braces");
     }},
    {"do while stays together when close brace newlines are off", [] {
         const std::string source = "start {\n    do { print(1) } while (ready)\n}\n";
         const std::string kept =
             "start {\n    do {\n        print(1)\n    } while (ready)\n}\n";
         auto off = cwhip::builtinStyle();
         off.newlineAfterCloseBrace = false;
         require(formatted(source, off) == kept, formatted(source, off));
         expectSame(kept, off);
         require(formatted(source) == kept, "true moved while off the brace");
     }},
    {"custom binding splits except and leaves enum braces", [] {
         const std::string source =
             "start {\n"
             "    try { print(1) } except(Exception) { print(2) } finally { print(3) }\n"
             "}\n";
         const std::string joined =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    } except(Exception) {\n"
             "        print(2)\n"
             "    } finally {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         const std::string split =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    }\n"
             "    except(Exception) {\n"
             "        print(2)\n"
             "    }\n"
             "    finally {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         auto off = cwhip::builtinStyle();
         off.newlineBeforeExcept = false;
         require(formatted(source, off) == joined, formatted(source, off));
         auto custom = off;
         custom.braceBinding = cwhip::BraceBinding::Custom;
         require(formatted(source, custom) == split, formatted(source, custom));
         const std::string enumeration = "class Box {\n    enum { A, B }\n}\n";
         const std::string expanded =
             "class Box {\n"
             "    enum {\n"
             "        A, B\n"
             "    }\n"
             "}\n";
         require(formatted(enumeration, custom) == expanded, formatted(enumeration, custom));
         require(formatted(enumeration, custom) == formatted(enumeration), "custom moved enum");
         auto shortEnum = custom;
         shortEnum.allowShortEnums = true;
         shortEnum.newlineBeforeCloseBrace = false;
         expectSame(enumeration, shortEnum);
         const std::string broken = "class Box {\n    enum\n    {\n        A\n    }\n}\n";
         const auto failed = cwhip::formatSource(broken, custom, "enum.cw");
         require(!failed.ok && failed.text == broken, "a newline before enum { was kept");
         const auto plain = cwhip::formatSource(broken, cwhip::builtinStyle(), "enum.cw");
         require(!plain.ok && plain.text == broken, "default accepted a newline before enum {");
     }},
    {"binary operators break inside parentheses and stay outside", [] {
         const std::string inside =
             "start {\n"
             "    if (ready and anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHere) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         require(std::string("    if (ready and "
                             "anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHere) {")
                         .size() > 80,
                 "and fixture is not past the column limit");
         expectSame(inside);
         auto before = cwhip::builtinStyle();
         before.breakBeforeBinaryOperators = cwhip::BreakBeforeBinaryOperators::NonAssignment;
         const std::string brokenBefore =
             "start {\n"
             "    if (ready\n"
             "            and anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHere) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         require(formatted(inside, before) == brokenBefore, formatted(inside, before));
         auto after = cwhip::builtinStyle();
         after.breakBeforeBinaryOperators = cwhip::BreakBeforeBinaryOperators::None;
         const std::string brokenAfter =
             "start {\n"
             "    if (ready and\n"
             "            anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHere) {\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         require(formatted(inside, after) == brokenAfter, formatted(inside, after));
         const std::string ors =
             "start {\n"
             "    if (ready or anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHere) {\n"
             "        print(1)\n"
             "    }\n"
             "    if (ready || anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHere) {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         const std::string orsBroken =
             "start {\n"
             "    if (ready\n"
             "            or anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHere) {\n"
             "        print(1)\n"
             "    }\n"
             "    if (ready\n"
             "            || anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHere) {\n"
             "        print(2)\n"
             "    }\n"
             "}\n";
         require(formatted(ors, before) == orsBroken, formatted(ors, before));
         const std::string outside =
             "start {\n"
             "    ready and anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHerePlusMore\n"
             "}\n";
         require(std::string("    ready and "
                             "anotherClauseThatIsVeryLongAndShouldNotWrapOutsideParenthesesHerePlusMore")
                         .size() > 80,
                 "outside operator is not past the column limit");
         expectSame(outside, before);
         expectSame(outside, after);
     }},
    {"indent widths other than four and eight are used", [] {
         auto style = cwhip::builtinStyle();
         style.indentWidth = 2;
         style.continuationIndentWidth = 6;
         const std::string wrapped =
             "start {\n"
             "  print(\n"
             "        alpha,\n"
             "        beta,\n"
             "        gamma,\n"
             "        delta,\n"
             "        epsilon,\n"
             "        zeta,\n"
             "        eta,\n"
             "        theta,\n"
             "        iota,\n"
             "        kappa,\n"
             "        lambda,\n"
             "        mu)\n"
             "}\n";
         require(formatted(kLongCall, style) == wrapped, formatted(kLongCall, style));
         const auto parsed = parseStyle("IndentWidth: 2\nContinuationIndentWidth: 6\n");
         require(parsed.ok, parsed.diagnostic);
         require(formatted(kLongCall, parsed.style) == wrapped, formatted(kLongCall, parsed.style));
     }},
    {"the other spelling of a locked key leaves the output unchanged", [] {
         const std::string source =
             "include \"zeta.cw\"\n"
             "include \"alpha.cw\"\n"
             "\n"
             "start {\n"
             "    if (ready or set) {\n"
             "        print(1)\n"
             "    }\n"
             "    if (ready || set) {\n"
             "        print(2)\n"
             "    }\n"
             "    if (not ready) {\n"
             "        print(3)\n"
             "    }\n"
             "    if (!ready) {\n"
             "        print(4)\n"
             "    }\n"
             "    if (ready) {\n"
             "        print(1)\n"
             "    }\n"
             "    else (other) {\n"
             "        print(2)\n"
             "    }\n"
             "    print(1..20)\n"
             "    print(int8(-2) >> 1)\n"
             "    print(\"a\\n\\\"b\")\n"
             "    print(.5)\n"
             "    print(1.)\n"
             "    strg text inline {\n"
             "        const char *s = \"{\";\n"
             "    }\n"
             "    /* alpha beta gamma delta epsilon zeta\n"
             "       eta theta iota kappa */\n"
             "}\n";
         expectSame(source);
         const auto locked = parseStyle(
             "BreakStringLiterals: true\n"
             "BinPackParameters: true\n"
             "BinPackArguments: true\n"
             "InsertSemicolons: true\n"
             "AllowMultipleStatementsPerLine: true\n"
             "WrapOnlyInsideParensAndBrackets: false\n"
             "KeepElseParenOnSameLine: false\n"
             "ForbidElseIf: false\n"
             "PreserveLogicalSpelling: false\n"
             "PreserveKeywordCase: false\n"
             "PreserveTypeAliasSpelling: false\n"
             "PreserveNumericSpelling: false\n"
             "PreserveStringLexeme: false\n"
             "PreserveParentheses: false\n"
             "SplitDotDot: true\n"
             "SplitShiftRight: true\n"
             "ExpandIncludes: true\n"
             "ReorderIncludes: true\n"
             "FormatInlineC: true\n"
             "PreserveBlockCommentNewlines: false\n");
         require(locked.ok, locked.diagnostic);
         expectSame(source, locked.style);
         require(source.find("include \"zeta.cw\"\ninclude \"alpha.cw\"") != std::string::npos,
                 "include order");
         const std::string joined = "start {\n    print(1) print(2)\n}\n";
         const auto failed = cwhip::formatSource(joined, locked.style, "joined.cw");
         require(!failed.ok && failed.text == joined, "multiple statements were allowed");
         const std::string assigned =
             "start {\n"
             "    int64 value = call(alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, "
             "kappa, lambda, mu)\n"
             "}\n";
         require(formatted(assigned, locked.style) == formatted(assigned),
                 formatted(assigned, locked.style));
         const std::string generic =
             "start {\n"
             "    dict<VeryLongTypeNameThatPushesThisGenericWellPastTheColumnLimit, "
             "AnotherLongTypeNameHere> item\n"
             "}\n";
         expectSame(generic, locked.style);
     }},
    {"style text comments quotes and rejected values", [] {
         const auto spaced = parseStyle("ColumnLimit :  40 # ColumnLimit: 1\n");
         require(spaced.ok, spaced.diagnostic);
         require(spaced.style.columnLimit == 40, "spaces or the trailing hash changed the value");
         const std::string call = "start {\n    print(alpha, beta, gamma, delta, epsilon)\n}\n";
         const auto line = std::string("    print(alpha, beta, gamma, delta, epsilon)");
         require(line.size() > 40 && line.size() <= 80, "column fixture is the wrong length");
         expectSame(call);
         const std::string wrapped =
             "start {\n"
             "    print(\n"
             "            alpha,\n"
             "            beta,\n"
             "            gamma,\n"
             "            delta,\n"
             "            epsilon)\n"
             "}\n";
         require(formatted(call, spaced.style) == wrapped, formatted(call, spaced.style));
         const auto hashed = parseStyle(
             "# ColumnLimit: 1\n"
             "ColumnLimit: 40\n"
             "CommentPragmas: \"keep#this\" # trailing\n");
         require(hashed.ok, hashed.diagnostic);
         require(hashed.style.columnLimit == 40, "a whole-line hash comment set the limit");
         require(hashed.style.commentPragmas && *hashed.style.commentPragmas == "keep#this",
                 "a hash inside quotes was stripped");
         auto narrow = hashed.style;
         const std::string comments =
             "start {\n"
             "    # keep#this alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu\n"
             "    # ordinary alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu\n"
             "    print(1)\n"
             "}\n";
         const auto kept = formatted(comments, narrow);
         require(kept.find("    # keep#this alpha beta gamma delta epsilon zeta eta theta iota "
                           "kappa lambda mu\n") != std::string::npos,
                 kept);
         require(kept.find("    # ordinary alpha beta gamma delta epsilon zeta eta theta iota "
                           "kappa lambda mu\n") == std::string::npos,
                 kept);
         const auto escaped = parseStyle("CommentPragmas: \"a\\\"b\"\n");
         require(escaped.ok && escaped.style.commentPragmas && *escaped.style.commentPragmas == "a\"b",
                 "quote escape");
         const auto slash = parseStyle("CommentPragmas: \"a\\\\b\"\n");
         require(slash.ok && slash.style.commentPragmas && *slash.style.commentPragmas == "a\\b",
                 "backslash escape");
         const auto newline = parseStyle("CommentPragmas: \"a\\nb\"\n");
         require(newline.ok && newline.style.commentPragmas &&
                     *newline.style.commentPragmas == "a\nb",
                 "newline escape");
         const auto tab = parseStyle("CommentPragmas: \"a\\tb\"\n");
         require(tab.ok && tab.style.commentPragmas && *tab.style.commentPragmas == "a\tb",
                 "tab escape");
         const auto badEscape = parseStyle("CommentPragmas: \"\\q\"\n");
         require(!badEscape.ok, "bad escape");
         require(badEscape.diagnostic.find("unterminated string") != std::string::npos,
                 badEscape.diagnostic);
         const auto single = parseStyle("CommentPragmas: 'a#b'\n");
         require(single.ok && single.style.commentPragmas && *single.style.commentPragmas == "a#b",
                 "single quoted hash");
         const auto leadingSpace = parseStyle(" ColumnLimit: 1\n");
         require(!leadingSpace.ok && leadingSpace.diagnostic.find("nested map") != std::string::npos,
                 leadingSpace.diagnostic);
         const auto leadingTab = parseStyle("\tColumnLimit: 1\n");
         require(!leadingTab.ok && leadingTab.diagnostic.find("nested map") != std::string::npos,
                 leadingTab.diagnostic);
         const auto emptyValue = parseStyle("ColumnLimit:\n");
         require(!emptyValue.ok && emptyValue.diagnostic.find("nested map: ColumnLimit") !=
                                       std::string::npos,
                 emptyValue.diagnostic);
         const auto missingColon = parseStyle("ColumnLimit 40\n");
         require(!missingColon.ok &&
                     missingColon.diagnostic.find("expected Key: Value") != std::string::npos,
                 missingColon.diagnostic);
         const auto useTab = parseStyle("UseTab: Always\n");
         require(!useTab.ok && useTab.diagnostic.find("invalid value for UseTab") != std::string::npos,
                 useTab.diagnostic);
         const auto align = parseStyle("AlignOperands: Align\n");
         require(!align.ok &&
                     align.diagnostic.find("invalid value for AlignOperands") != std::string::npos,
                 align.diagnostic);
         const auto alignFalse = parseStyle("AlignOperands: false\n");
         require(alignFalse.ok, alignFalse.diagnostic);
         require(formatted(kLongCall, alignFalse.style) == kWrappedCall,
                 formatted(kLongCall, alignFalse.style));
         const auto wrap = parseStyle("WrapLongParenthesizedList: BinPack\n");
         require(!wrap.ok && wrap.diagnostic.find("invalid value for WrapLongParenthesizedList") !=
                                 std::string::npos,
                 wrap.diagnostic);
         const auto terminator = parseStyle("StatementTerminator: Semicolon\n");
         require(!terminator.ok &&
                     terminator.diagnostic.find("invalid value for StatementTerminator") !=
                         std::string::npos,
                 terminator.diagnostic);
     }},
    {"an empty style file an empty home and an unreadable file", [] {
         EnvGuard home("HOME");
         const auto root = std::filesystem::temp_directory_path() /
                           ("cwhip-format-style-" + std::to_string(static_cast<long long>(getpid())));
         std::filesystem::remove_all(root);
         const auto child = root / "parent" / "child";
         writeFile(root / "parent" / ".cwhip-format", "ColumnLimit: 3\n");
         writeFile(child / ".cwhip-format", "");
         const auto stopped = cwhip::loadStyleAt(child.string());
         require(stopped.ok && stopped.found && stopped.style.columnLimit == 80,
                 "empty style file did not stop the walk: " + std::to_string(stopped.style.columnLimit));
         const auto here = root / "a" / "b" / "c" / "d" / "e" / "f";
         writeFile(here / "note.txt", "x");
         writeFile(root / "home" / ".config" / "cwhip" / ".cwhip-format", "ColumnLimit: 3\n");
         home.set((root / "home").string());
         const auto fromHome = cwhip::loadStyleAt(here.string());
         require(fromHome.ok && fromHome.found && fromHome.style.columnLimit == 3,
                 fromHome.diagnostic);
         home.set("");
         const auto emptyHome = cwhip::loadStyleAt(here.string());
         require(emptyHome.ok && !emptyHome.found && emptyHome.style.columnLimit == 80,
                 "empty HOME was used");
         writeFile(root / "secret" / ".cwhip-format", "ColumnLimit: 4\n");
         {
             PermGuard denied(root / "secret" / ".cwhip-format");
             denied.deny();
             const auto unreadable = cwhip::loadStyleAt((root / "secret").string());
             require(!unreadable.ok, "an unreadable style file was used");
             require(unreadable.diagnostic.find("cannot read style file") != std::string::npos,
                     unreadable.diagnostic);
         }
        {
            const auto inner = root / "deleted";
            std::filesystem::create_directories(inner);
            CwdGuard cwd;
            std::filesystem::current_path(inner);
            require(std::filesystem::remove(inner), "could not remove the current directory");
            const auto lost = cwhip::styleFor("");
            require(!lost.ok, lost.diagnostic.empty() ? "current directory was readable"
                                                      : lost.diagnostic);
            require(lost.diagnostic.find("cannot read the current directory") != std::string::npos,
                    lost.diagnostic);
        }
         std::filesystem::remove_all(root);
     }},
    {"spacing normalizes operators commas braces and delimiter padding", [] {
         require(formatted("start {\n    value=1+2\n}\n") ==
                     "start {\n    value = 1 + 2\n}\n",
                 formatted("start {\n    value=1+2\n}\n"));
         expectSame("start {\n    value = 1 + 2\n}\n");
         require(formatted("start {\n    value  =   1   +   2\n}\n") ==
                     "start {\n    value = 1 + 2\n}\n",
                 "extra operator spaces were kept");
         require(formatted("start {\n    print( 1 ,2 )\n}\n") == "start {\n    print(1, 2)\n}\n",
                 formatted("start {\n    print( 1 ,2 )\n}\n"));
         expectSame("start {\n    print(1, 2)\n}\n");
         require(formatted("start {\n    print(1,)\n}\n") == "start {\n    print(1,)\n}\n",
                 "trailing comma gained a space");
         require(formatted("class Box {\n    dict< int64,String > name\n}\n") ==
                     "class Box {\n    dict<int64, String> name\n}\n",
                 formatted("class Box {\n    dict< int64,String > name\n}\n"));
         expectSame("class Box {\n    dict<int64, String> name\n}\n");
         require(formatted("class Box {\n    dict<int64,String>name\n}\n") ==
                     "class Box {\n    dict<int64, String>name\n}\n",
                 "a space was inserted after '>'");
         require(formatted("start {\n    if (ready){\n        print(1)\n    }\n}\n") ==
                     "start {\n    if (ready) {\n        print(1)\n    }\n}\n",
                 "missing brace space");
         expectSame("start {\n    if (ready) {\n        print(1)\n    }\n}\n");
         require(formatted("start {\n    print(1 .. 20)\n}\n") == "start {\n    print(1..20)\n}\n",
                 formatted("start {\n    print(1 .. 20)\n}\n"));
         expectSame("start {\n    print(1..20)\n}\n");
         require(formatted("start {\n    if (! ready) {\n        print(1)\n    }\n}\n") ==
                     "start {\n    if (!ready) {\n        print(1)\n    }\n}\n",
                 "unary bang gained no space");
         require(formatted("start {\n    if (not  ready) {\n        print(1)\n    }\n}\n") ==
                     "start {\n    if (not ready) {\n        print(1)\n    }\n}\n",
                 formatted("start {\n    if (not  ready) {\n        print(1)\n    }\n}\n"));
         expectSame("start {\n    if (not ready) {\n        print(1)\n    }\n}\n");
         require(formatted("start {\n    print (1)\n}\n") == "start {\n    print (1)\n}\n",
                 "unset SpaceBeforeParens changed a call");
         require(formatted("start {\n    if(ready) {\n        print(1)\n    }\n}\n") ==
                     "start {\n    if(ready) {\n        print(1)\n    }\n}\n",
                 "unset SpaceBeforeParens changed if");
         const std::string trailed = "start {\n    print(1)   \n}\n";
         require(formatted(trailed) == "start {\n    print(1)\n}\n", formatted(trailed));
         const std::string once = formatted("start {\n    value=1+2\n    print( 1 , 2 )\n}\n");
         require(formatted(once) == once, "spacing was not stable");
     }},
    {"wrapping reformats broken calls assignment lists and from", [] {
         const std::string broken =
             "start {\n"
             "    print(\n"
             "        alpha,\n"
             "            beta,\n"
             "    gamma,\n"
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
         require(formatted(broken) == kWrappedCall, formatted(broken));
         require(formatted(kWrappedCall) == kWrappedCall, "canonical wrap was not stable");
         const std::string shortBroken =
             "start {\n"
             "    print(\n"
             "        alpha,\n"
             "            beta)\n"
             "}\n";
         require(formatted(shortBroken) == "start {\n    print(alpha, beta)\n}\n",
                 formatted(shortBroken));
         expectSame("start {\n    print(alpha, beta)\n}\n");
         const std::string commented =
             "start {\n"
             "    print(alpha, // keep\n"
             "            beta)\n"
             "}\n";
         const auto commentedText = formatted(commented);
         require(commentedText.find("// keep\n") != std::string::npos, commentedText);
         require(commentedText.find("beta)") != std::string::npos, commentedText);
         require(formatted(commentedText) == commentedText, "commented list was not stable");
         const std::string dict =
             "start {\n"
             "    Dict items = [\"alpha\": 1, \"beta\": 2, \"gamma\": 3, \"delta\": 4, \"epsilon\": 5, \"zeta\": 6, \"eta\": 7, \"theta\": 8]\n"
             "}\n";
         const std::string dictWrapped =
             "start {\n"
             "    Dict items = [\n"
             "            \"alpha\": 1,\n"
             "            \"beta\": 2,\n"
             "            \"gamma\": 3,\n"
             "            \"delta\": 4,\n"
             "            \"epsilon\": 5,\n"
             "            \"zeta\": 6,\n"
             "            \"eta\": 7,\n"
             "            \"theta\": 8]\n"
             "}\n";
         require(formatted(dict) == dictWrapped, formatted(dict));
         expectSame("start {\n    Dict items = [\"alpha\": 1, \"beta\": 2]\n}\n");
         const std::string sum =
             "start {\n"
             "    int64 value = alpha + beta + gamma + delta + epsilon + zeta + eta + theta + iota\n"
             "}\n";
         expectSame(sum);
         auto unlimited = cwhip::builtinStyle();
         unlimited.columnLimit = 0;
         expectSame(kLongCall, unlimited);
         expectSame(broken, unlimited);
         const std::string method =
             "String Name.method(int64 value) from \"cwhip_native_symbol_that_is_long_enough_to_pass_eighty_columns\"\n";
         const std::string methodBroken =
             "String Name.method(int64 value)\n"
             "from \"cwhip_native_symbol_that_is_long_enough_to_pass_eighty_columns\"\n";
         require(formatted(method) == methodBroken, formatted(method));
         require(formatted(methodBroken) == methodBroken, "from break was not stable");
         expectSame("String Name.method(int64 value) from \"short\"\n");
         const std::string indentedFrom =
             "namespace Gui {\n"
             "    String Name.method(int64 value)\n"
             "            from \"short\"\n"
             "}\n";
         require(formatted(indentedFrom) ==
                     "namespace Gui {\n"
                     "    String Name.method(int64 value)\n"
                     "    from \"short\"\n"
                     "}\n",
                 formatted(indentedFrom));
     }},
    {"block indent replaces the source column for comments cases and clauses", [] {
         const std::string comment =
             "start {\n"
             "# note\n"
             "    print(1)\n"
             "}\n";
         require(formatted(comment) ==
                     "start {\n"
                     "    # note\n"
                     "    print(1)\n"
                     "}\n",
                 formatted(comment));
         expectSame("start {\n    # note\n    print(1)\n}\n");
         const std::string switched =
             "start {\n"
             "    switch (value) {\n"
             "case (1) {\n"
             "            print(1)\n"
             "        }\n"
             "  default {\n"
             "            print(0)\n"
             "        }\n"
             "    }\n"
             "}\n";
         const std::string switchedIndented =
             "start {\n"
             "    switch (value) {\n"
             "        case (1) {\n"
             "            print(1)\n"
             "        }\n"
             "        default {\n"
             "            print(0)\n"
             "        }\n"
             "    }\n"
             "}\n";
         require(formatted(switched) == switchedIndented, formatted(switched));
         expectSame(switchedIndented);
         const std::string brace =
             "start {\n"
             "if (ready)\n"
             "{\n"
             "        print(1)\n"
             "    }\n"
             "}\n";
         require(formatted(brace) ==
                     "start {\n"
                     "    if (ready)\n"
                     "    {\n"
                     "        print(1)\n"
                     "    }\n"
                     "}\n",
                 formatted(brace));
         const std::string handlers =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    }\n"
             "        except(Exception) {\n"
             "        print(2)\n"
             "    }\n"
             "            finally {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         const std::string handlersIndented =
             "start {\n"
             "    try {\n"
             "        print(1)\n"
             "    }\n"
             "    except(Exception) {\n"
             "        print(2)\n"
             "    }\n"
             "    finally {\n"
             "        print(3)\n"
             "    }\n"
             "}\n";
         require(formatted(handlers) == handlersIndented, formatted(handlers));
         expectSame(handlersIndented);
         const std::string methodFrom =
             "int64 Box.value()\n"
             "    from \"box_value\"\n";
         require(formatted(methodFrom) == "int64 Box.value()\nfrom \"box_value\"\n",
                 formatted(methodFrom));
         expectSame("int64 Box.value()\nfrom \"box_value\"\n");
     }},
    {"a line range formats the selected statement and leaves the rest", [] {
         const std::string source =
             "start {\n"
             "    value=1\n"
             "    other=2\n"
             "}\n";
         const auto middle = cwhip::formatSourceRange(source, cwhip::builtinStyle(), "range.cw", 3, 3);
         require(middle.ok, middle.diagnostic);
         require(middle.text ==
                     "start {\n"
                     "    value=1\n"
                     "    other = 2\n"
                     "}\n",
                 middle.text);
         const auto outside = cwhip::formatSourceRange(source, cwhip::builtinStyle(), "range.cw", 2, 2);
         require(outside.ok, outside.diagnostic);
         require(outside.text ==
                     "start {\n"
                     "    value = 1\n"
                     "    other=2\n"
                     "}\n",
                 outside.text);
         const auto all = cwhip::formatSourceRange(source, cwhip::builtinStyle(), "range.cw", 0, 0);
         require(all.ok && all.text == formatted(source), all.text);
         require(formatted(all.text) == all.text, "ranged full format was not stable");
     }},
}};

} // namespace
