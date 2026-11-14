/**
 * @file Style.cpp
 * @brief Built-in style, the Key: Value subset, and the directory walk.
 */
#include "cwhip/format/Style.hpp"

#include <cctype>
#include <cstdlib>
#include <fstream>
#include <filesystem>
#include <regex>
#include <sstream>
#include <unordered_set>
#include <utility>

namespace cwhip {
namespace {

std::string trim(std::string text) {
    std::size_t begin = 0;
    while (begin < text.size() &&
           std::isspace(static_cast<unsigned char>(text[begin])) != 0) {
        ++begin;
    }
    std::size_t end = text.size();
    while (end > begin && std::isspace(static_cast<unsigned char>(text[end - 1])) != 0) {
        --end;
    }
    return text.substr(begin, end - begin);
}

std::string diagnostic(const std::string& file, std::size_t line, const std::string& message) {
    return file + ":" + std::to_string(line) + ":1: " + message;
}

StyleLoadResult failure(const std::string& file, std::size_t line, const std::string& message) {
    StyleLoadResult result;
    result.ok = false;
    result.diagnostic = diagnostic(file, line, message);
    return result;
}

bool parseInt(const std::string& text, int& value) {
    if (text.empty()) return false;
    std::size_t index = 0;
    int sign = 1;
    if (text[0] == '-') {
        sign = -1;
        index = 1;
        if (index >= text.size()) return false;
    }
    int parsed = 0;
    for (; index < text.size(); ++index) {
        if (text[index] < '0' || text[index] > '9') return false;
        parsed = parsed * 10 + (text[index] - '0');
    }
    value = sign * parsed;
    return true;
}

std::string unquote(const std::string& text, bool& ok) {
    ok = false;
    if (text.size() < 2) return {};
    const char quote = text.front();
    if ((quote != '"' && quote != '\'') || text.back() != quote) return {};
    std::string value;
    if (quote == '\'') {
        value = text.substr(1, text.size() - 2);
        ok = value.find('\'') == std::string::npos;
        return value;
    }
    for (std::size_t index = 1; index + 1 < text.size(); ++index) {
        if (text[index] != '\\') {
            value.push_back(text[index]);
            continue;
        }
        if (index + 1 >= text.size() - 1) return {};
        const char escaped = text[++index];
        switch (escaped) {
        case '\\': value.push_back('\\'); break;
        case '"': value.push_back('"'); break;
        case 'n': value.push_back('\n'); break;
        case 't': value.push_back('\t'); break;
        default: return {};
        }
    }
    ok = true;
    return value;
}

const std::unordered_set<std::string>& knownKeys() {
    static const std::unordered_set<std::string> keys{
        "Language",
        "IndentWidth",
        "UseTab",
        "ContinuationIndentWidth",
        "AlignOperands",
        "ColumnLimit",
        "BreakStringLiterals",
        "AllowShortFunctionsOnASingleLine",
        "AllowShortBlocksOnASingleLine",
        "AllowShortIfStatementsOnASingleLine",
        "AllowShortLoopsOnASingleLine",
        "AllowShortEnumsOnASingleLine",
        "NewlineBeforeOpenBrace",
        "NewlineAfterOpenBrace",
        "NewlineAfterCloseBrace",
        "NewlineBeforeElse",
        "WrapLongParenthesizedList",
        "BinPackParameters",
        "BinPackArguments",
        "BreakBeforeBinaryOperators",
        "SpaceBeforeParens",
        "BlankLinesAroundLongControlStatement",
        "LongControlStatementLines",
        "ReflowComments",
        "CommentPragmas",
        "StatementTerminator",
        "InsertSemicolons",
        "AllowMultipleStatementsPerLine",
        "WrapOnlyInsideParensAndBrackets",
        "BraceBinding",
        "KeepElseParenOnSameLine",
        "ForbidElseIf",
        "PreserveLogicalSpelling",
        "PreserveKeywordCase",
        "PreserveTypeAliasSpelling",
        "PreserveNumericSpelling",
        "PreserveStringLexeme",
        "PreserveParentheses",
        "SplitDotDot",
        "SplitShiftRight",
        "ExpandIncludes",
        "ReorderIncludes",
        "FormatInlineC",
        "PreserveBlockCommentNewlines",
        "BasedOnStyle",
    };
    return keys;
}

bool isBoolKey(const std::string& key) {
    static const std::unordered_set<std::string> keys{
        "BreakStringLiterals",
        "AllowShortLoopsOnASingleLine",
        "AllowShortEnumsOnASingleLine",
        "NewlineBeforeOpenBrace",
        "NewlineAfterOpenBrace",
        "NewlineAfterCloseBrace",
        "NewlineBeforeElse",
        "BinPackParameters",
        "BinPackArguments",
        "BlankLinesAroundLongControlStatement",
        "ReflowComments",
        "InsertSemicolons",
        "AllowMultipleStatementsPerLine",
        "WrapOnlyInsideParensAndBrackets",
        "KeepElseParenOnSameLine",
        "ForbidElseIf",
        "PreserveLogicalSpelling",
        "PreserveKeywordCase",
        "PreserveTypeAliasSpelling",
        "PreserveNumericSpelling",
        "PreserveStringLexeme",
        "PreserveParentheses",
        "SplitDotDot",
        "SplitShiftRight",
        "ExpandIncludes",
        "ReorderIncludes",
        "FormatInlineC",
        "PreserveBlockCommentNewlines",
    };
    return keys.count(key) != 0;
}

struct RawEntry {
    std::string key;
    std::string value;
    bool quoted = false;
    std::size_t line = 1;
};

bool applyEntry(Style& style, const RawEntry& entry, const std::string& file,
                std::string& error) {
    const auto& key = entry.key;
    const auto& value = entry.value;
    const auto bad = [&](const std::string& message) {
        error = diagnostic(file, entry.line, message);
        return false;
    };
    if (key == "BasedOnStyle") return bad("unknown key: BasedOnStyle");
    if (key == "Language") {
        if (value != "Cwhip") return bad("unsupported language: " + value);
        return true;
    }
    if (key == "IndentWidth" || key == "ContinuationIndentWidth" || key == "ColumnLimit" ||
        key == "LongControlStatementLines") {
        int number = 0;
        if (!parseInt(value, number)) return bad("expected an integer for " + key);
        if (number < 0) return bad("negative integer: " + key);
        if (key == "IndentWidth") style.indentWidth = number;
        else if (key == "ContinuationIndentWidth") style.continuationIndentWidth = number;
        else if (key == "ColumnLimit") style.columnLimit = number;
        else style.longControlStatementLines = number;
        return true;
    }
    if (isBoolKey(key)) {
        if (value != "true" && value != "false") return bad("expected true or false for " + key);
        const bool flag = value == "true";
        if (key == "BreakStringLiterals") style.breakStringLiterals = flag;
        else if (key == "AllowShortLoopsOnASingleLine") style.allowShortLoops = flag;
        else if (key == "AllowShortEnumsOnASingleLine") style.allowShortEnums = flag;
        else if (key == "NewlineBeforeOpenBrace") style.newlineBeforeOpenBrace = flag;
        else if (key == "NewlineAfterOpenBrace") style.newlineAfterOpenBrace = flag;
        else if (key == "NewlineAfterCloseBrace") style.newlineAfterCloseBrace = flag;
        else if (key == "NewlineBeforeElse") style.newlineBeforeElse = flag;
        else if (key == "BlankLinesAroundLongControlStatement")
            style.blankLinesAroundLongControlStatement = flag;
        else if (key == "ReflowComments") style.reflowComments = flag;
        // The other booleans are accepted so a short file can set them. The
        // printer keeps the syntax locks (no semicolons, no include expansion,
        // no string breaks) regardless of a contradictory true.
        return true;
    }
    if (key == "UseTab") {
        if (value != "Never") return bad("invalid value for UseTab");
        return true;
    }
    if (key == "AlignOperands") {
        if (value != "DontAlign" && value != "false") return bad("invalid value for AlignOperands");
        return true;
    }
    if (key == "AllowShortFunctionsOnASingleLine") {
        style.allowShortFunctions =
            (value == "None" || value == "false") ? AllowShortFunctions::None
                                                   : AllowShortFunctions::Other;
        if (value != "None" && value != "false" && value != "All" && value != "true" &&
            value != "Inline" && value != "Empty") {
            return bad("invalid value for AllowShortFunctionsOnASingleLine");
        }
        return true;
    }
    if (key == "AllowShortBlocksOnASingleLine") {
        style.allowShortBlocks = (value == "Never" || value == "false") ? AllowShortBlocks::Never
                                                                        : AllowShortBlocks::Other;
        if (value != "Never" && value != "false" && value != "Always" && value != "true" &&
            value != "Empty") {
            return bad("invalid value for AllowShortBlocksOnASingleLine");
        }
        return true;
    }
    if (key == "AllowShortIfStatementsOnASingleLine") {
        style.allowShortIf =
            (value == "Never" || value == "false") ? AllowShortIf::Never : AllowShortIf::Other;
        if (value != "Never" && value != "false" && value != "Always" && value != "true") {
            return bad("invalid value for AllowShortIfStatementsOnASingleLine");
        }
        return true;
    }
    if (key == "WrapLongParenthesizedList") {
        if (value != "BreakAfterOpenParen") {
            return bad("invalid value for WrapLongParenthesizedList");
        }
        return true;
    }
    if (key == "StatementTerminator") {
        if (value != "Newline") return bad("invalid value for StatementTerminator");
        return true;
    }
    if (key == "BreakBeforeBinaryOperators") {
        if (value == "None" || value == "false") {
            style.breakBeforeBinaryOperators = BreakBeforeBinaryOperators::None;
        } else if (value == "NonAssignment") {
            style.breakBeforeBinaryOperators = BreakBeforeBinaryOperators::NonAssignment;
        } else {
            return bad("invalid value for BreakBeforeBinaryOperators");
        }
        return true;
    }
    if (key == "SpaceBeforeParens") {
        if (value == "Never") style.spaceBeforeParens = SpaceBeforeParens::Never;
        else if (value == "ControlStatements")
            style.spaceBeforeParens = SpaceBeforeParens::ControlStatements;
        else return bad("invalid value for SpaceBeforeParens");
        return true;
    }
    if (key == "BraceBinding") {
        if (value == "PreserveWhereLegal") style.braceBinding = BraceBinding::PreserveWhereLegal;
        else if (value == "Custom") style.braceBinding = BraceBinding::Custom;
        else return bad("invalid value for BraceBinding");
        return true;
    }
    if (key == "CommentPragmas") {
        if (!entry.quoted && !value.empty()) return bad("CommentPragmas must be a quoted string");
        style.commentPragmas = value;
        if (!value.empty()) {
            try {
                (void)std::regex(value);
            } catch (const std::regex_error&) {
                return bad("invalid CommentPragmas pattern");
            }
        }
        return true;
    }
    return bad("unknown key: " + key);
}

std::string stripComment(const std::string& line) {
    bool quoted = false;
    char quote = 0;
    for (std::size_t index = 0; index < line.size(); ++index) {
        const char value = line[index];
        if (quoted) {
            if (value == '\\' && quote == '"' && index + 1 < line.size()) {
                ++index;
                continue;
            }
            if (value == quote) quoted = false;
            continue;
        }
        if (value == '"' || value == '\'') {
            quoted = true;
            quote = value;
            continue;
        }
        if (value == '#') return line.substr(0, index);
    }
    return line;
}

} // namespace

Style builtinStyle() { return Style{}; }

namespace {

const char* boolText(bool value) { return value ? "true" : "false"; }

std::string shortFunctionsText(AllowShortFunctions value) {
    return value == AllowShortFunctions::None ? "None" : "All";
}

std::string shortBlocksText(AllowShortBlocks value) {
    return value == AllowShortBlocks::Never ? "Never" : "Always";
}

std::string shortIfText(AllowShortIf value) {
    return value == AllowShortIf::Never ? "Never" : "Always";
}

} // namespace

std::string builtinConfigText() {
    const Style style = builtinStyle();
    std::ostringstream text;
    auto emit = [&](const char* key, const std::string& value, const char* comment) {
        text << "# " << comment << '\n';
        text << key << ": " << value << '\n';
    };
    emit("Language", "Cwhip", "Language of the file. Cwhip is the only accepted value.");
    emit("IndentWidth", std::to_string(style.indentWidth), "Spaces for each indent level.");
    emit("UseTab", "Never", "Inserted indent uses spaces.");
    emit("ContinuationIndentWidth", std::to_string(style.continuationIndentWidth),
         "Extra spaces past the block indent on a wrapped line.");
    emit("AlignOperands", "DontAlign", "Do not line up an operand with the operator.");
    emit("ColumnLimit", std::to_string(style.columnLimit),
         "Preferred line length. 0 means do not wrap.");
    emit("BreakStringLiterals", boolText(style.breakStringLiterals),
         "Do not split a string literal across lines.");
    emit("AllowShortFunctionsOnASingleLine", shortFunctionsText(style.allowShortFunctions),
         "Allow a function body on one line. None does not.");
    emit("AllowShortBlocksOnASingleLine", shortBlocksText(style.allowShortBlocks),
         "Allow a block on one line. Never does not.");
    emit("AllowShortIfStatementsOnASingleLine", shortIfText(style.allowShortIf),
         "Allow an if body on one line. Never does not.");
    emit("AllowShortLoopsOnASingleLine", boolText(style.allowShortLoops),
         "Allow a loop body on one line.");
    emit("AllowShortEnumsOnASingleLine", boolText(style.allowShortEnums),
         "Allow an enum body on one line.");
    emit("NewlineBeforeOpenBrace", boolText(style.newlineBeforeOpenBrace),
         "Put { on the next line. False keeps the source break.");
    emit("NewlineAfterOpenBrace", boolText(style.newlineAfterOpenBrace),
         "Put the token after { on the next line.");
    emit("NewlineAfterCloseBrace", boolText(style.newlineAfterCloseBrace),
         "Put the token after } on the next line.");
    emit("NewlineBeforeElse", boolText(style.newlineBeforeElse),
         "Put else on the line after }. False leaves it on the } line.");
    emit("WrapLongParenthesizedList", "BreakAfterOpenParen",
         "Break a long parenthesized list after the opening parenthesis.");
    emit("BinPackParameters", "false", "Pack wrapped parameters onto one line.");
    emit("BinPackArguments", "false", "Pack wrapped arguments onto one line.");
    emit("BlankLinesAroundLongControlStatement",
         boolText(style.blankLinesAroundLongControlStatement),
         "Insert a blank line around a long control statement.");
    emit("LongControlStatementLines", std::to_string(style.longControlStatementLines),
         "A control statement longer than this many lines is long.");
    emit("ReflowComments", boolText(style.reflowComments),
         "Reflow hash and slash comments to the column limit.");
    emit("StatementTerminator", "Newline", "A newline ends a statement.");
    emit("InsertSemicolons", "false", "Do not insert semicolons.");
    emit("AllowMultipleStatementsPerLine", "false", "Allow more than one statement on a line.");
    emit("WrapOnlyInsideParensAndBrackets", "true", "Wrap only inside parentheses and brackets.");
    emit("KeepElseParenOnSameLine", "true", "Keep else and its parenthesis on one line.");
    emit("ForbidElseIf", "true", "Do not write else if.");
    emit("PreserveLogicalSpelling", "true", "Keep and, or, and not as written.");
    emit("PreserveKeywordCase", "true", "Keep keyword capitalization as written.");
    emit("PreserveTypeAliasSpelling", "true", "Keep int, strg, and other type spellings as written.");
    emit("PreserveNumericSpelling", "true", "Keep numeric spellings as written.");
    emit("PreserveStringLexeme", "true", "Copy string text without re-escaping.");
    emit("PreserveParentheses", "true", "Keep parentheses that are in the source.");
    emit("SplitDotDot", "false", "Do not split the .. operator.");
    emit("SplitShiftRight", "false", "Do not split the >> operator.");
    emit("ExpandIncludes", "false", "Do not expand include directives.");
    emit("ReorderIncludes", "false", "Do not reorder include directives.");
    emit("FormatInlineC", "false", "Do not format an inline C body.");
    emit("PreserveBlockCommentNewlines", "true", "Keep newlines inside block comments.");
    return text.str();
}

StyleLoadResult parseStyleText(const std::string& text, const std::string& fileName) {
    StyleLoadResult result;
    result.found = true;
    result.style = builtinStyle();
    std::unordered_set<std::string> seen;
    std::size_t lineNumber = 0;
    std::size_t cursor = 0;
    while (cursor <= text.size()) {
        std::size_t end = text.find('\n', cursor);
        if (end == std::string::npos) end = text.size();
        std::string line = text.substr(cursor, end - cursor);
        if (!line.empty() && line.back() == '\r') line.pop_back();
        const bool last = end == text.size();
        cursor = end + 1;
        ++lineNumber;
        const auto body = trim(stripComment(line));
        if (body.empty()) {
            if (last) break;
            continue;
        }
        if (!line.empty() && (line[0] == ' ' || line[0] == '\t')) {
            return failure(fileName, lineNumber, "nested map");
        }
        const auto colon = body.find(':');
        if (colon == std::string::npos) {
            return failure(fileName, lineNumber, "expected Key: Value");
        }
        RawEntry entry;
        entry.line = lineNumber;
        entry.key = trim(body.substr(0, colon));
        auto rawValue = trim(body.substr(colon + 1));
        if (entry.key.empty()) return failure(fileName, lineNumber, "expected Key: Value");
        if (rawValue.empty()) {
            return failure(fileName, lineNumber, "nested map: " + entry.key);
        }
        if (seen.count(entry.key) != 0) {
            return failure(fileName, lineNumber, "duplicate key: " + entry.key);
        }
        seen.insert(entry.key);
        if (knownKeys().count(entry.key) == 0) {
            return failure(fileName, lineNumber, "unknown key: " + entry.key);
        }
        if ((rawValue.front() == '"' || rawValue.front() == '\'')) {
            bool ok = false;
            entry.value = unquote(rawValue, ok);
            if (!ok) return failure(fileName, lineNumber, "unterminated string for " + entry.key);
            entry.quoted = true;
        } else {
            entry.value = rawValue;
        }
        std::string error;
        if (!applyEntry(result.style, entry, fileName, error)) {
            result.ok = false;
            result.diagnostic = error;
            return result;
        }
        if (last) break;
    }
    return result;
}

StyleLoadResult loadStyleAt(const std::string& startDirectory) {
    namespace fs = std::filesystem;
    std::error_code error;
    fs::path directory = fs::absolute(startDirectory, error);
    if (error) directory = startDirectory;
    directory = directory.lexically_normal();

    auto consider = [](const fs::path& candidate) -> StyleLoadResult {
        std::error_code existsError;
        const bool present = fs::exists(candidate, existsError);
        if (existsError) {
            return failure(candidate.string(), 1, "cannot read style file");
        }
        if (!present) {
            StyleLoadResult missing;
            missing.ok = true;
            missing.found = false;
            return missing;
        }
        if (!fs::is_regular_file(candidate, existsError) || existsError) {
            return failure(candidate.string(), 1, ".cwhip-format is not a regular file");
        }
        std::ifstream input(candidate, std::ios::binary);
        if (!input) return failure(candidate.string(), 1, "cannot read style file");
        std::ostringstream buffer;
        buffer << input.rdbuf();
        if (!input && !input.eof()) {
            return failure(candidate.string(), 1, "cannot read style file");
        }
        return parseStyleText(buffer.str(), candidate.string());
    };

    for (int level = 0; level < 6; ++level) {
        const auto loaded = consider(directory / ".cwhip-format");
        if (!loaded.ok || loaded.found) return loaded;
        const fs::path parent = directory.parent_path();
        if (parent.empty() || parent == directory) break;
        directory = parent;
    }

    const char* home = std::getenv("HOME");
    if (home != nullptr && home[0] != '\0') {
        const auto loaded =
            consider(fs::path(home) / ".config" / "cwhip" / ".cwhip-format");
        if (!loaded.ok || loaded.found) return loaded;
    }

    StyleLoadResult builtin;
    builtin.ok = true;
    builtin.found = false;
    builtin.style = builtinStyle();
    return builtin;
}

} // namespace cwhip
