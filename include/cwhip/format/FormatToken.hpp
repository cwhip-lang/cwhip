/**
 * @file FormatToken.hpp
 * @brief Trivia-preserving tokens for cwhip-format.
 *
 * These sit beside cwhip::Token. The compiler lexer drops the bytes a printer
 * has to copy, so the formatter keeps its own token and does not change Token.
 */
#pragma once

#include "cwhip/Token.hpp"

#include <string>
#include <vector>

namespace cwhip {

enum class FormatTriviaKind {
    Space,
    Tab,
    CarriageReturn,
    VerticalTab,
    FormFeed,
    /// A newline inside () or []. Depth-0 newlines are FormatToken Newline
    /// tokens, not trivia. Interior newlines have to be trivia or a reprint
    /// cannot put them back.
    Newline,
    LineComment,
    BlockComment
};

struct FormatTrivia {
    FormatTriviaKind kind = FormatTriviaKind::Space;
    std::string text;
};

struct FormatToken {
    TokenType type = TokenType::End;
    /// Raw source bytes. Strings keep their quotes and escapes. `..` is `".."`.
    std::string lexeme;
    std::size_t begin = 0;
    std::size_t end = 0;
    SourceLocation location;
    std::vector<FormatTrivia> leading;
    bool formattedString = false;
    /// This Newline token is a depth-0 newline that also splits a block comment.
    bool splitsBlockComment = false;
};

} // namespace cwhip
