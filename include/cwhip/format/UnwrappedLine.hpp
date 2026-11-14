/**
 * @file UnwrappedLine.hpp
 * @brief Statement ranges over FormatToken, without building a Program.
 */
#pragma once

#include "cwhip/format/FormatToken.hpp"

#include <string>
#include <vector>

namespace cwhip {

enum class NewlineKind {
    None,
    /// Separates statements. The printer keeps it.
    Terminator,
    /// A skipNewlines site: before `{`, `else`, `from`, or `while`.
    Free,
    /// Depth-0 newline that splits a block comment. Never add or remove it.
    BlockComment
};

enum class BlockKind {
    None,
    Generic,
    Function,
    If,
    Loop,
    Enum
};

struct TokenAnnotation {
    int blockLevel = 0;
    NewlineKind newlineKind = NewlineKind::None;
    BlockKind blockKind = BlockKind::None;
    bool preserveIndent = false;
    bool reindent = false;
    /// The following line is the rest of a split block comment.
    bool rawLine = false;
    bool listOpen = false;
    bool forbidWrap = false;
    /// Parenthesis depth before this token. () and [] count together.
    int parenDepthBefore = 0;
    bool binaryOperator = false;
    bool isElse = false;
    bool isExcept = false;
    bool isFinally = false;
    bool isOpenBrace = false;
    bool isCloseBrace = false;
    /// A newline before this '{' parses. class, enum, destroy, and an
    /// in-class method do not.
    bool openBraceMayBreak = false;
};

struct UnwrappedLine {
    std::size_t begin = 0;
    std::size_t end = 0;
    int indentLevel = 0;
};

struct ControlSpan {
    /// First token of the keyword (`if`, `while`, `for`, `switch`, `do`).
    std::size_t keyword = 0;
    /// First token that stays inside the blank-line pair. A run of declarations
    /// that sit against the control is included.
    std::size_t attached = 0;
    /// One past the last token of the construct.
    std::size_t end = 0;
};

struct UnwrapResult {
    bool ok = false;
    std::string message;
    SourceLocation location;
    std::vector<TokenAnnotation> annotations;
    std::vector<UnwrappedLine> lines;
    std::vector<ControlSpan> controls;
};

UnwrapResult unwrapLines(const std::vector<FormatToken>& tokens);

} // namespace cwhip
