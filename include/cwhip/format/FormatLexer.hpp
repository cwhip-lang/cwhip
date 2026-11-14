/**
 * @file FormatLexer.hpp
 * @brief One-file lexer that keeps the trivia Lexer::skipTrivia discards.
 */
#pragma once

#include "cwhip/format/FormatToken.hpp"

#include <string>
#include <vector>

namespace cwhip {

class FormatLexer {
public:
    FormatLexer(std::string source, std::string fileName);
    std::vector<FormatToken> tokenize();

private:
    bool atEnd() const noexcept;
    char peek(std::size_t offset = 0) const noexcept;
    char advance() noexcept;
    void skipTrivia(std::vector<FormatToken>& tokens, std::size_t parenthesisDepth);
    void scanLineComment();
    void scanBlockComment(std::vector<FormatToken>& tokens, std::size_t parenthesisDepth);
    void scanIdentifierOrInteger(std::vector<FormatToken>& tokens);
    void scanString(std::vector<FormatToken>& tokens, char quote);
    void scanInlineBody(std::vector<FormatToken>& tokens);
    void emit(std::vector<FormatToken>& tokens, TokenType type, std::size_t begin,
              SourceLocation location, bool formattedString = false);
    SourceLocation currentLocation() const;

    std::string source_;
    std::string fileName_;
    std::size_t position_ = 0;
    std::size_t line_ = 1;
    std::size_t column_ = 1;
    bool inlineHeader_ = false;
    std::vector<FormatTrivia> pending_;
};

} // namespace cwhip
