/**
 * @file Style.hpp
 * @brief Built-in cwhip-format style and the Key: Value file loader.
 *
 * Open keys stay unset. A built-in default does not pick either side.
 */
#pragma once

#include <optional>
#include <string>

namespace cwhip {

enum class BreakBeforeBinaryOperators {
    /// Break after the operator. Clang-format reads `false` as this.
    None,
    /// Break before &&, and, and the other non-assignment operators.
    NonAssignment
};

enum class SpaceBeforeParens {
    Never,
    ControlStatements
};

enum class BraceBinding {
    /// Keep the source wherever both bindings parse.
    PreserveWhereLegal,
    /// Abbr BraceWrapping: attach control and function braces, break before
    /// else / except / finally.
    Custom
};

enum class AllowShortFunctions {
    None,
    Other
};

enum class AllowShortBlocks {
    Never,
    Other
};

enum class AllowShortIf {
    Never,
    Other
};

struct Style {
    int indentWidth = 4;
    int continuationIndentWidth = 8;
    /// 80 by default. 0 means no column limit.
    int columnLimit = 80;
    bool breakStringLiterals = false;
    AllowShortFunctions allowShortFunctions = AllowShortFunctions::None;
    AllowShortBlocks allowShortBlocks = AllowShortBlocks::Never;
    AllowShortIf allowShortIf = AllowShortIf::Never;
    bool allowShortLoops = false;
    bool allowShortEnums = false;
    bool reflowComments = true;
    bool blankLinesAroundLongControlStatement = true;
    int longControlStatementLines = 10;
    std::optional<BreakBeforeBinaryOperators> breakBeforeBinaryOperators;
    std::optional<SpaceBeforeParens> spaceBeforeParens;
    std::optional<std::string> commentPragmas;
    std::optional<BraceBinding> braceBinding;
};

Style builtinStyle();

/// Key: Value text of the built-in defaults. The four open keys are omitted.
/// Parsing the text yields builtinStyle().
std::string builtinConfigText();

struct StyleLoadResult {
    bool ok = true;
    bool found = false;
    Style style = builtinStyle();
    /// `path:line:column: message` when ok is false.
    std::string diagnostic;
};

/// Parse one style file. `text` is the file bytes. Language may be omitted;
/// any language other than Cwhip is an error.
StyleLoadResult parseStyleText(const std::string& text, const std::string& fileName);

/// Search `startDirectory`, then at most five parents, then `$HOME/.config/cwhip/`.
/// `startDirectory` is the process current directory for a real run.
StyleLoadResult loadStyleAt(const std::string& startDirectory);

} // namespace cwhip
