/**
 * @file FormatLexer.cpp
 * @brief Trivia-preserving lex of one Cwhip file.
 *
 * Character decisions match Lexer::tokenize. The compiler token still drops
 * comments, raw string bytes, and the second dot of `..`, so this lexer stays
 * beside it.
 */
#include "cwhip/format/FormatLexer.hpp"

#include "cwhip/Diagnostic.hpp"

#include <cctype>
#include <unordered_map>
#include <utility>

namespace cwhip {
namespace {

char lowerAscii(char value) {
    if (value >= 'A' && value <= 'Z') return static_cast<char>(value - 'A' + 'a');
    return value;
}

bool isIdentifierStart(char value) {
    return (value >= 'a' && value <= 'z') || (value >= 'A' && value <= 'Z') || value == '_';
}

bool isIdentifierPart(char value) {
    return isIdentifierStart(value) || (value >= '0' && value <= '9');
}

bool isValidUtf8(const std::string& value) {
    std::size_t index = 0;
    while (index < value.size()) {
        const auto lead = static_cast<unsigned char>(value[index]);
        if (lead <= 0x7f) {
            ++index;
            continue;
        }
        std::size_t length = 0;
        unsigned char secondMinimum = 0x80;
        unsigned char secondMaximum = 0xbf;
        if (lead >= 0xc2 && lead <= 0xdf) {
            length = 2;
        } else if (lead >= 0xe0 && lead <= 0xef) {
            length = 3;
            if (lead == 0xe0) secondMinimum = 0xa0;
            if (lead == 0xed) secondMaximum = 0x9f;
        } else if (lead >= 0xf0 && lead <= 0xf4) {
            length = 4;
            if (lead == 0xf0) secondMinimum = 0x90;
            if (lead == 0xf4) secondMaximum = 0x8f;
        } else {
            return false;
        }
        if (index + length > value.size()) return false;
        const auto second = static_cast<unsigned char>(value[index + 1]);
        if (second < secondMinimum || second > secondMaximum) return false;
        for (std::size_t offset = 2; offset < length; ++offset) {
            const auto continuation = static_cast<unsigned char>(value[index + offset]);
            if (continuation < 0x80 || continuation > 0xbf) return false;
        }
        index += length;
    }
    return true;
}

FormatTriviaKind whitespaceKind(char value) {
    switch (value) {
    case ' ': return FormatTriviaKind::Space;
    case '\t': return FormatTriviaKind::Tab;
    case '\r': return FormatTriviaKind::CarriageReturn;
    case '\v': return FormatTriviaKind::VerticalTab;
    case '\f': return FormatTriviaKind::FormFeed;
    default: return FormatTriviaKind::Space;
    }
}

const std::unordered_map<std::string, TokenType>& keywords() {
    static const std::unordered_map<std::string, TokenType> table{
        {"start", TokenType::Start},
        {"int", TokenType::NativeInt}, {"uint", TokenType::NativeUInt},
        {"unsigned", TokenType::RemovedUnsigned},
        {"float", TokenType::NativeFloat},
        {"int8", TokenType::Int8}, {"uint8", TokenType::UInt8},
        {"int16", TokenType::Int16}, {"uint16", TokenType::UInt16},
        {"int32", TokenType::Int32}, {"uint32", TokenType::UInt32},
        {"int64", TokenType::Int64}, {"uint64", TokenType::UInt64},
        {"fp32", TokenType::FP32}, {"fp64", TokenType::FP64},
        {"bool", TokenType::Bool},
        {"strg", TokenType::StrgType},
        {"list", TokenType::ListType}, {"dict", TokenType::DictType},
        {"range", TokenType::RangeType},
        {"buffer", TokenType::BufferType}, {"handle", TokenType::HandleType},
        {"any", TokenType::AnyType}, {"type", TokenType::TypeType},
        {"if", TokenType::If},
        {"else", TokenType::Else}, {"while", TokenType::While},
        {"do", TokenType::Do}, {"for", TokenType::For},
        {"in", TokenType::In}, {"is", TokenType::Is}, {"break", TokenType::Break},
        {"continue", TokenType::Continue}, {"and", TokenType::And},
        {"switch", TokenType::Switch}, {"case", TokenType::Case},
        {"default", TokenType::Default},
        {"or", TokenType::Or}, {"not", TokenType::Bang},
        {"print", TokenType::Print}, {"raise", TokenType::Raise},
        {"try", TokenType::Try}, {"except", TokenType::Except},
        {"finally", TokenType::Finally}, {"class", TokenType::Class},
        {"namespace", TokenType::Namespace}, {"include", TokenType::Include},
        {"inline", TokenType::Inline},
        {"import", TokenType::Import}, {"as", TokenType::As},
        {"from", TokenType::From},
        {"public", TokenType::Public}, {"protected", TokenType::Protected},
        {"private", TokenType::Private},
        {"virtual", TokenType::Virtual},
        {"super", TokenType::Super},
        {"null", TokenType::Null},
        {"true", TokenType::True}, {"false", TokenType::False},
        {"return", TokenType::Return}, {"void", TokenType::Void}
    };
    return table;
}

} // namespace

FormatLexer::FormatLexer(std::string source, std::string fileName)
    : source_(std::move(source)), fileName_(std::move(fileName)) {}

bool FormatLexer::atEnd() const noexcept { return position_ >= source_.size(); }

char FormatLexer::peek(std::size_t offset) const noexcept {
    const auto index = position_ + offset;
    return index < source_.size() ? source_[index] : '\0';
}

char FormatLexer::advance() noexcept {
    const char value = source_[position_++];
    if (value == '\n') {
        ++line_;
        column_ = 1;
    } else {
        ++column_;
    }
    return value;
}

SourceLocation FormatLexer::currentLocation() const { return {fileName_, line_, column_}; }

void FormatLexer::emit(std::vector<FormatToken>& tokens, TokenType type, std::size_t begin,
                       SourceLocation location, bool formattedString) {
    FormatToken token;
    token.type = type;
    token.lexeme = source_.substr(begin, position_ - begin);
    token.begin = begin;
    token.end = position_;
    token.location = std::move(location);
    token.formattedString = formattedString;
    token.leading = std::move(pending_);
    pending_.clear();
    tokens.push_back(std::move(token));
}

void FormatLexer::scanLineComment() {
    const auto start = position_;
    while (!atEnd() && peek() != '\n') advance();
    pending_.push_back({FormatTriviaKind::LineComment, source_.substr(start, position_ - start)});
}

void FormatLexer::scanBlockComment(std::vector<FormatToken>& tokens,
                                   std::size_t parenthesisDepth) {
    const auto commentLocation = currentLocation();
    auto piece = position_;
    advance();
    advance();
    bool closed = false;
    while (!atEnd()) {
        if (peek() == '*' && peek(1) == '/') {
            advance();
            advance();
            closed = true;
            break;
        }
        if (peek() == '\n' && parenthesisDepth == 0) {
            pending_.push_back(
                {FormatTriviaKind::BlockComment, source_.substr(piece, position_ - piece)});
            const auto newlineLocation = currentLocation();
            const auto newlineAt = position_;
            advance();
            FormatToken newline;
            newline.type = TokenType::Newline;
            newline.lexeme = "\n";
            newline.begin = newlineAt;
            newline.end = position_;
            newline.location = newlineLocation;
            newline.splitsBlockComment = true;
            newline.leading = std::move(pending_);
            pending_.clear();
            tokens.push_back(std::move(newline));
            piece = position_;
            continue;
        }
        advance();
    }
    if (!closed) throw DiagnosticError(commentLocation, "unterminated block comment");
    pending_.push_back(
        {FormatTriviaKind::BlockComment, source_.substr(piece, position_ - piece)});
}

void FormatLexer::skipTrivia(std::vector<FormatToken>& tokens, std::size_t parenthesisDepth) {
    for (;;) {
        if (!atEnd() && peek() != '\n' &&
            std::isspace(static_cast<unsigned char>(peek())) != 0) {
            const auto kind = whitespaceKind(peek());
            const auto start = position_;
            while (!atEnd() && peek() != '\n' &&
                   std::isspace(static_cast<unsigned char>(peek())) != 0 &&
                   whitespaceKind(peek()) == kind) {
                advance();
            }
            pending_.push_back({kind, source_.substr(start, position_ - start)});
            continue;
        }
        if (peek() == '#') {
            scanLineComment();
            continue;
        }
        if (peek() == '/' && peek(1) == '/') {
            scanLineComment();
            continue;
        }
        if (peek() == '/' && peek(1) == '*') {
            scanBlockComment(tokens, parenthesisDepth);
            continue;
        }
        return;
    }
}

void FormatLexer::scanIdentifierOrInteger(std::vector<FormatToken>& tokens) {
    const auto location = currentLocation();
    const auto begin = position_;
    const bool leadingDot = peek() == '.';
    const bool number = leadingDot || (peek() >= '0' && peek() <= '9');
    if (number) {
        bool floating = leadingDot;
        const bool hexadecimal =
            !leadingDot && peek() == '0' && (peek(1) == 'x' || peek(1) == 'X');
        if (leadingDot) {
            advance();
            while (peek() >= '0' && peek() <= '9') advance();
        } else if (hexadecimal) {
            advance();
            advance();
            const auto digitStart = position_;
            while ((peek() >= '0' && peek() <= '9') || (peek() >= 'a' && peek() <= 'f') ||
                   (peek() >= 'A' && peek() <= 'F')) {
                advance();
            }
            if (position_ == digitStart) {
                throw DiagnosticError(location, "malformed hexadecimal integer literal");
            }
            if (peek() == 'u' || peek() == 'U') advance();
            if (isIdentifierPart(peek())) {
                while (isIdentifierPart(peek())) advance();
                throw DiagnosticError(location, "malformed hexadecimal integer literal");
            }
            const char suffix = source_[position_ - 1];
            emit(tokens,
                 (suffix == 'u' || suffix == 'U') ? TokenType::UnsignedInteger
                                                   : TokenType::Integer,
                 begin, location);
            return;
        } else {
            while (peek() >= '0' && peek() <= '9') advance();
        }
        if (!leadingDot && peek() == '.' && peek(1) != '.') {
            floating = true;
            advance();
            while (peek() >= '0' && peek() <= '9') advance();
        }
        if (peek() == 'e' || peek() == 'E') {
            floating = true;
            advance();
            if (peek() == '+' || peek() == '-') advance();
            if (peek() < '0' || peek() > '9') {
                throw DiagnosticError(location, "malformed floating-point literal");
            }
            while (peek() >= '0' && peek() <= '9') advance();
        }
        if (floating && peek() == 'f' && peek(1) == '6' && peek(2) == '4') {
            advance();
            advance();
            advance();
            if (isIdentifierPart(peek())) {
                throw DiagnosticError(location, "malformed floating-point literal");
            }
        }
        TokenType type;
        if (!floating && (peek() == 'u' || peek() == 'U')) {
            advance();
            type = TokenType::UnsignedInteger;
        } else {
            type = floating ? TokenType::Float : TokenType::Integer;
        }
        emit(tokens, type, begin, location);
        return;
    }

    while (isIdentifierPart(peek())) advance();
    const std::string text = source_.substr(begin, position_ - begin);
    std::string normalized;
    normalized.reserve(text.size());
    for (char value : text) normalized.push_back(lowerAscii(value));
    TokenType type = TokenType::Identifier;
    if (text != "String") {
        const auto found = keywords().find(normalized);
        if (found != keywords().end()) type = found->second;
        if (type == TokenType::Inline) inlineHeader_ = true;
    }
    emit(tokens, type, begin, location);
}

void FormatLexer::scanString(std::vector<FormatToken>& tokens, char quote) {
    const auto location = currentLocation();
    const auto begin = position_;
    advance();
    std::string decoded;
    while (!atEnd() && peek() != quote) {
        if (peek() == '\n' || peek() == '\r') {
            throw DiagnosticError(currentLocation(), "newline in string literal");
        }
        if (quote == '"' && peek() == '\\') {
            advance();
            if (atEnd()) throw DiagnosticError(location, "unterminated escape sequence");
            const char escaped = advance();
            switch (escaped) {
            case 'e': decoded.push_back('\x1b'); break;
            case 'n': decoded.push_back('\n'); break;
            case 'r': decoded.push_back('\r'); break;
            case 't': decoded.push_back('\t'); break;
            case '\\': decoded.push_back('\\'); break;
            case '"': decoded.push_back('"'); break;
            default: throw DiagnosticError(currentLocation(), "unsupported string escape");
            }
        } else {
            decoded.push_back(advance());
        }
    }
    if (atEnd()) throw DiagnosticError(location, "unterminated string literal");
    advance();
    if (!isValidUtf8(decoded)) throw DiagnosticError(location, "string literal is not valid UTF-8");
    emit(tokens, TokenType::String, begin, location, quote == '"');
}

void FormatLexer::scanInlineBody(std::vector<FormatToken>& tokens) {
    const auto location = currentLocation();
    const auto braceAt = position_;
    advance();
    const auto bodyAt = position_;
    std::size_t braceDepth = 1;
    while (!atEnd()) {
        if (peek() == '"' || peek() == '\'') {
            const char quote = advance();
            bool closed = false;
            while (!atEnd()) {
                const char value = advance();
                if (value == '\\' && !atEnd()) {
                    advance();
                } else if (value == quote) {
                    closed = true;
                    break;
                }
            }
            if (!closed) throw DiagnosticError(location, "unterminated string in inline C block");
            continue;
        }
        if (peek() == '/' && peek(1) == '/') {
            advance();
            advance();
            while (!atEnd() && peek() != '\n') advance();
            continue;
        }
        if (peek() == '/' && peek(1) == '*') {
            advance();
            advance();
            bool closed = false;
            while (!atEnd()) {
                if (peek() == '*' && peek(1) == '/') {
                    advance();
                    advance();
                    closed = true;
                    break;
                }
                advance();
            }
            if (!closed) throw DiagnosticError(location, "unterminated comment in inline C block");
            continue;
        }
        if (peek() == '{') {
            ++braceDepth;
            advance();
            continue;
        }
        if (peek() == '}') {
            advance();
            if (--braceDepth == 0) {
                inlineHeader_ = false;
                FormatToken token;
                token.type = TokenType::InlineBody;
                token.lexeme = source_.substr(bodyAt, (position_ - 1) - bodyAt);
                token.begin = braceAt;
                token.end = position_;
                token.location = location;
                token.leading = std::move(pending_);
                pending_.clear();
                tokens.push_back(std::move(token));
                return;
            }
            continue;
        }
        advance();
    }
    throw DiagnosticError(location, "unterminated inline C block");
}

std::vector<FormatToken> FormatLexer::tokenize() {
    std::vector<FormatToken> tokens;
    std::size_t parenthesisDepth = 0;
    while (!atEnd()) {
        skipTrivia(tokens, parenthesisDepth);
        if (atEnd()) break;
        const auto location = currentLocation();
        const auto begin = position_;
        const char value = peek();
        if (inlineHeader_ && value == '{') {
            scanInlineBody(tokens);
            continue;
        }
        if (value == '\n') {
            advance();
            if (parenthesisDepth == 0) {
                emit(tokens, TokenType::Newline, begin, location);
            } else {
                pending_.push_back({FormatTriviaKind::Newline, "\n"});
            }
            continue;
        }
        if (isIdentifierStart(value) || (value >= '0' && value <= '9') ||
            (value == '.' && peek(1) >= '0' && peek(1) <= '9')) {
            scanIdentifierOrInteger(tokens);
            continue;
        }
        if (value == '"' || value == '\'') {
            scanString(tokens, value);
            continue;
        }
        advance();
        TokenType type;
        switch (value) {
        case ';':
            throw DiagnosticError(location,
                                  "unknown character ';': ';' is not a comment; use '#' or '//'");
        case '{': type = TokenType::LeftBrace; break;
        case '}': type = TokenType::RightBrace; break;
        case '(': type = TokenType::LeftParen; break;
        case ')': type = TokenType::RightParen; break;
        case '[': type = TokenType::LeftBracket; break;
        case ']': type = TokenType::RightBracket; break;
        case ',': type = TokenType::Comma; break;
        case '.':
            type = peek() == '.' ? (advance(), TokenType::DotDot) : TokenType::Dot;
            break;
        case ':': type = TokenType::Colon; break;
        case '+': type = peek() == '=' ? (advance(), TokenType::PlusEqual) : TokenType::Plus; break;
        case '-': type = peek() == '=' ? (advance(), TokenType::MinusEqual) : TokenType::Minus; break;
        case '*': type = peek() == '=' ? (advance(), TokenType::StarEqual) : TokenType::Star; break;
        case '/': type = peek() == '=' ? (advance(), TokenType::SlashEqual) : TokenType::Slash; break;
        case '%':
            type = peek() == '=' ? (advance(), TokenType::PercentEqual) : TokenType::Percent;
            break;
        case '&':
            type = peek() == '&' ? (advance(), TokenType::AndAnd)
                   : peek() == '=' ? (advance(), TokenType::AmpersandEqual)
                                   : TokenType::Ampersand;
            break;
        case '|':
            type = peek() == '|' ? (advance(), TokenType::OrOr)
                   : peek() == '=' ? (advance(), TokenType::PipeEqual)
                                   : TokenType::Pipe;
            break;
        case '^': type = peek() == '=' ? (advance(), TokenType::CaretEqual) : TokenType::Caret; break;
        case '~': type = TokenType::Tilde; break;
        case '!': type = peek() == '=' ? (advance(), TokenType::BangEqual) : TokenType::Bang; break;
        case '=': type = peek() == '=' ? (advance(), TokenType::EqualEqual) : TokenType::Equal; break;
        case '<':
            if (peek() == '<') {
                advance();
                type = peek() == '=' ? (advance(), TokenType::ShiftLeftEqual) : TokenType::ShiftLeft;
            } else {
                type = peek() == '=' ? (advance(), TokenType::LessEqual) : TokenType::Less;
            }
            break;
        case '>':
            if (peek() == '>') {
                advance();
                type = peek() == '=' ? (advance(), TokenType::ShiftRightEqual)
                                     : TokenType::ShiftRight;
            } else {
                type = peek() == '=' ? (advance(), TokenType::GreaterEqual) : TokenType::Greater;
            }
            break;
        default: throw DiagnosticError(location, "unexpected character");
        }
        if (type == TokenType::LeftParen || type == TokenType::LeftBracket) {
            ++parenthesisDepth;
        } else if ((type == TokenType::RightParen || type == TokenType::RightBracket) &&
                   parenthesisDepth > 0) {
            --parenthesisDepth;
        }
        emit(tokens, type, begin, location);
    }
    FormatToken end;
    end.type = TokenType::End;
    end.location = currentLocation();
    end.begin = position_;
    end.end = position_;
    end.leading = std::move(pending_);
    tokens.push_back(std::move(end));
    return tokens;
}

} // namespace cwhip
