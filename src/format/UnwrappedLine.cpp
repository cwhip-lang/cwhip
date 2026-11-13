/**
 * @file UnwrappedLine.cpp
 * @brief Group FormatTokens the way the parser separates statements.
 *
 * A failed walk leaves the file unchanged. synchronizeStatement is not used:
 * recovery is for diagnostics, not for a stable print.
 */
#include "cwhip/format/UnwrappedLine.hpp"

namespace cwhip {
namespace {

bool isTypeStart(TokenType type) {
    switch (type) {
    case TokenType::RemovedUnsigned:
    case TokenType::NativeInt:
    case TokenType::NativeUInt:
    case TokenType::NativeFloat:
    case TokenType::Int8:
    case TokenType::UInt8:
    case TokenType::Int16:
    case TokenType::UInt16:
    case TokenType::Int32:
    case TokenType::UInt32:
    case TokenType::Int64:
    case TokenType::UInt64:
    case TokenType::FP32:
    case TokenType::FP64:
    case TokenType::Bool:
    case TokenType::StrgType:
    case TokenType::ListType:
    case TokenType::DictType:
    case TokenType::BufferType:
    case TokenType::HandleType:
    case TokenType::AnyType:
    case TokenType::TypeType:
    case TokenType::RangeType:
    case TokenType::Void:
    case TokenType::Identifier:
        return true;
    default:
        return false;
    }
}

bool isWrapOperator(TokenType type) {
    switch (type) {
    case TokenType::And:
    case TokenType::Or:
    case TokenType::AndAnd:
    case TokenType::OrOr:
    case TokenType::Plus:
    case TokenType::Minus:
    case TokenType::Star:
    case TokenType::Slash:
    case TokenType::Percent:
    case TokenType::Ampersand:
    case TokenType::Pipe:
    case TokenType::Caret:
    case TokenType::EqualEqual:
    case TokenType::BangEqual:
    case TokenType::LessEqual:
    case TokenType::GreaterEqual:
    case TokenType::DotDot:
    case TokenType::In:
    case TokenType::Is:
        return true;
    default:
        return false;
    }
}

bool isEnumWord(const FormatToken& token) {
    if (token.type != TokenType::Identifier || token.lexeme.size() != 4) return false;
    const char* word = "enum";
    for (std::size_t index = 0; index < 4; ++index) {
        char value = token.lexeme[index];
        if (value >= 'A' && value <= 'Z') value = static_cast<char>(value - 'A' + 'a');
        if (value != word[index]) return false;
    }
    return true;
}

bool isNextWord(const FormatToken& token) {
    if (token.type != TokenType::Identifier || token.lexeme.size() != 4) return false;
    const char* word = "next";
    for (std::size_t index = 0; index < 4; ++index) {
        char value = token.lexeme[index];
        if (value >= 'A' && value <= 'Z') value = static_cast<char>(value - 'A' + 'a');
        if (value != word[index]) return false;
    }
    return true;
}

struct StmtMark {
    std::size_t begin = 0;
    std::size_t end = 0;
    bool declaration = false;
    int newlinesBefore = 0;
    /// Newlines consumed as this statement's terminator. One means the next
    /// statement sits on the following line.
    int newlinesAfter = 0;
};

class Walker {
public:
    explicit Walker(const std::vector<FormatToken>& tokens)
        : tokens_(tokens), annotations_(tokens.size()) {}

    UnwrapResult run() {
        UnwrapResult result;
        if (tokens_.empty()) {
            result.ok = false;
            result.message = "cannot group statements";
            return result;
        }
        parseFile();
        result.ok = !failed_;
        result.message = message_;
        result.location = location_;
        result.annotations = std::move(annotations_);
        result.lines = std::move(lines_);
        result.controls = std::move(controls_);
        return result;
    }

private:
    const std::vector<FormatToken>& tokens_;
    std::vector<TokenAnnotation> annotations_;
    std::vector<UnwrappedLine> lines_;
    std::vector<ControlSpan> controls_;
    std::vector<StmtMark> statements_;
    std::size_t markFloor_ = 0;
    std::size_t index_ = 0;
    int level_ = 0;
    bool failed_ = false;
    std::string message_;
    SourceLocation location_;

    const FormatToken& cur() const { return tokens_[index_]; }
    bool is(TokenType type) const { return cur().type == type; }
    bool done() const { return is(TokenType::End); }

    void fail(const std::string& message) {
        if (failed_) return;
        failed_ = true;
        message_ = message;
        location_ = cur().location;
    }

    void stamp(std::size_t index) { annotations_[index].blockLevel = level_; }

    void advance() {
        if (done() || failed_) return;
        stamp(index_);
        ++index_;
    }

    bool take(TokenType type) {
        if (!is(type)) return false;
        advance();
        return !failed_;
    }

    void markNewline(NewlineKind kind) {
        if (cur().splitsBlockComment) annotations_[index_].newlineKind = NewlineKind::BlockComment;
        else annotations_[index_].newlineKind = kind;
        stamp(index_);
    }

    /// Returns how many newlines were consumed.
    int skipNewlines(NewlineKind kind) {
        int count = 0;
        while (!failed_ && is(TokenType::Newline)) {
            const bool block = cur().splitsBlockComment;
            markNewline(kind);
            advance();
            ++count;
            if (block) {
                if (!done()) annotations_[index_].rawLine = true;
            }
        }
        return count;
    }

    int consumeTerminator() {
        if (is(TokenType::Newline)) return skipNewlines(NewlineKind::Terminator);
        if (!is(TokenType::RightBrace) && !is(TokenType::End)) {
            fail("expected newline after statement");
        }
        return 0;
    }

    bool skipFree() {
        if (!is(TokenType::Newline)) return false;
        skipNewlines(NewlineKind::Free);
        if (!done() && !failed_) {
            annotations_[index_].preserveIndent = true;
            annotations_[index_].reindent = false;
        }
        return true;
    }

    void noteLine(std::size_t begin) {
        UnwrappedLine line;
        line.begin = begin;
        line.end = index_;
        line.indentLevel = level_;
        lines_.push_back(line);
    }

    void skipType() {
        if (is(TokenType::RangeType)) {
            advance();
        } else if (is(TokenType::Identifier)) {
            advance();
            while (!failed_ && is(TokenType::Dot)) {
                advance();
                if (!take(TokenType::Identifier)) {
                    fail("expected a name after '.'");
                    return;
                }
            }
        } else if (isTypeStart(cur().type)) {
            advance();
        } else {
            fail("expected a type name");
            return;
        }
        while (!failed_ && is(TokenType::Less)) {
            int depth = 1;
            annotations_[index_].forbidWrap = true;
            advance();
            while (!failed_ && depth > 0 && !done()) {
                annotations_[index_].forbidWrap = true;
                stamp(index_);
                if (is(TokenType::Less)) ++depth;
                else if (is(TokenType::Greater)) --depth;
                else if (is(TokenType::ShiftRight)) depth = depth > 1 ? depth - 2 : 0;
                else if (is(TokenType::Newline) || is(TokenType::RightBrace)) {
                    fail("cannot group statements");
                    return;
                }
                advance();
            }
            if (depth != 0) fail("cannot group statements");
        }
    }

    std::size_t lookPastType(std::size_t index) const {
        if (index >= tokens_.size() || !isTypeStart(tokens_[index].type)) return index;
        if (tokens_[index].type == TokenType::Identifier ||
            tokens_[index].type == TokenType::RangeType) {
            if (tokens_[index].type == TokenType::Identifier) {
                ++index;
                while (index + 1 < tokens_.size() && tokens_[index].type == TokenType::Dot &&
                       tokens_[index + 1].type == TokenType::Identifier) {
                    index += 2;
                }
            } else {
                ++index;
            }
        } else {
            ++index;
        }
        while (index < tokens_.size() && tokens_[index].type == TokenType::Less) {
            int depth = 0;
            do {
                if (index >= tokens_.size()) return index;
                if (tokens_[index].type == TokenType::Less) ++depth;
                else if (tokens_[index].type == TokenType::Greater) --depth;
                else if (tokens_[index].type == TokenType::ShiftRight)
                    depth = depth > 1 ? depth - 2 : 0;
                ++index;
            } while (index < tokens_.size() && depth != 0);
        }
        return index;
    }

    bool looksLikeDeclaration() const {
        const auto after = lookPastType(index_);
        return after < tokens_.size() && tokens_[after].type == TokenType::Identifier;
    }

    bool looksLikeOutOfLine() const {
        const auto after = lookPastType(index_);
        return after + 2 < tokens_.size() && tokens_[after].type == TokenType::Identifier &&
               tokens_[after + 1].type == TokenType::Dot &&
               tokens_[after + 2].type == TokenType::Identifier;
    }

    void consumeDelimited(bool openingIsList) {
        if (!is(TokenType::LeftParen) && !is(TokenType::LeftBracket)) {
            fail("expected '('");
            return;
        }
        annotations_[index_].listOpen = openingIsList;
        int depth = 1;
        advance();
        while (!failed_ && depth > 0 && !done()) {
            stamp(index_);
            annotations_[index_].parenDepthBefore = depth;
            if (is(TokenType::LeftParen) || is(TokenType::LeftBracket)) {
                annotations_[index_].listOpen = true;
                ++depth;
            } else if (is(TokenType::RightParen) || is(TokenType::RightBracket)) {
                --depth;
            } else if (is(TokenType::Newline)) {
                fail("cannot group statements");
                return;
            } else if (depth > 0 && isWrapOperator(cur().type)) {
                annotations_[index_].binaryOperator = true;
            }
            advance();
        }
        if (depth != 0) fail("cannot group statements");
    }

    void consumeStatementTail(bool forbidding) {
        int depth = 0;
        while (!failed_ && !done()) {
            if (depth == 0 && (is(TokenType::Newline) || is(TokenType::RightBrace) ||
                               is(TokenType::End) || is(TokenType::LeftBrace))) {
                break;
            }
            stamp(index_);
            annotations_[index_].parenDepthBefore = depth;
            if (forbidding) annotations_[index_].forbidWrap = true;
            if (is(TokenType::LeftParen) || is(TokenType::LeftBracket)) {
                if (!forbidding) annotations_[index_].listOpen = true;
                ++depth;
            } else if (is(TokenType::RightParen) || is(TokenType::RightBracket)) {
                if (depth == 0) {
                    fail("cannot group statements");
                    return;
                }
                --depth;
            } else if (depth == 0 && is(TokenType::Equal)) {
                forbidding = true;
                annotations_[index_].forbidWrap = true;
            } else if (depth > 0 && isWrapOperator(cur().type) && !forbidding) {
                annotations_[index_].binaryOperator = true;
            }
            advance();
        }
        if (depth != 0) fail("cannot group statements");
    }

    void parseBlock(BlockKind kind) {
        if (!is(TokenType::LeftBrace)) {
            fail("expected '{'");
            return;
        }
        annotations_[index_].isOpenBrace = true;
        annotations_[index_].blockKind = kind;
        advance();
        ++level_;
        const auto savedFloor = markFloor_;
        markFloor_ = statements_.size();
        while (!failed_ && !done() && !is(TokenType::RightBrace)) {
            const int newlines = skipNewlines(NewlineKind::Terminator);
            if (failed_) return;
            if (is(TokenType::RightBrace) || done()) break;
            const auto begin = index_;
            bool declaration = false;
            parseStatement(newlines, declaration);
            if (failed_) return;
            noteLine(begin);
            const int after = consumeTerminator();
            statements_.push_back({begin, index_, declaration, newlines, after});
        }
        statements_.resize(markFloor_);
        markFloor_ = savedFloor;
        if (failed_) return;
        if (!is(TokenType::RightBrace)) {
            fail("cannot group statements");
            return;
        }
        --level_;
        annotations_[index_].isCloseBrace = true;
        annotations_[index_].reindent = true;
        advance();
    }

    std::size_t attachedStart(std::size_t keyword, int newlinesBefore) const {
        std::size_t attached = keyword;
        // A blank line before the keyword (the terminator already ate one
        // newline, so any newline still sitting here is a second one) keeps
        // the declaration outside the pair.
        if (newlinesBefore != 0) return attached;
        std::size_t cursor = statements_.size();
        while (cursor > markFloor_) {
            const auto& previous = statements_[cursor - 1];
            if (!previous.declaration || previous.newlinesAfter != 1) break;
            attached = previous.begin;
            --cursor;
        }
        return attached;
    }

    void parseConditionAndBlock(BlockKind kind) {
        if (!is(TokenType::LeftParen)) {
            fail("expected '('");
            return;
        }
        consumeDelimited(false);
        if (failed_) return;
        skipFree();
        parseBlock(kind);
    }

    void parseIf(int newlinesBefore) {
        const auto keyword = index_;
        const auto attached = attachedStart(keyword, newlinesBefore);
        annotations_[index_].reindent = true;
        advance();
        parseConditionAndBlock(BlockKind::If);
        if (failed_) return;
        while (!failed_) {
            std::size_t look = index_;
            while (look < tokens_.size() && tokens_[look].type == TokenType::Newline) ++look;
            if (look >= tokens_.size() || tokens_[look].type != TokenType::Else) break;
            int between = 0;
            while (is(TokenType::Newline)) {
                ++between;
                markNewline(NewlineKind::Free);
                advance();
            }
            annotations_[index_].isElse = true;
            annotations_[index_].preserveIndent = between > 0;
            annotations_[index_].reindent = between == 0;
            advance();
            if (is(TokenType::If)) {
                fail("else if is not a statement");
                return;
            }
            if (is(TokenType::Newline)) {
                std::size_t after = index_;
                while (after < tokens_.size() && tokens_[after].type == TokenType::Newline) ++after;
                if (after < tokens_.size() && tokens_[after].type == TokenType::LeftParen) {
                    fail("newline between else and '('");
                    return;
                }
                skipFree();
            }
            if (is(TokenType::LeftParen)) {
                consumeDelimited(false);
                if (failed_) return;
                skipFree();
                parseBlock(BlockKind::If);
                continue;
            }
            if (is(TokenType::LeftBrace)) {
                parseBlock(BlockKind::Generic);
                look = index_;
                while (look < tokens_.size() && tokens_[look].type == TokenType::Newline) ++look;
                if (look < tokens_.size() && tokens_[look].type == TokenType::Else) {
                    fail("unconditional else must be the final clause");
                }
                break;
            }
            fail("expected a brace after else");
            return;
        }
        if (!failed_) controls_.push_back({keyword, attached, index_});
    }

    void parseWhile(int newlinesBefore) {
        const auto keyword = index_;
        const auto attached = attachedStart(keyword, newlinesBefore);
        annotations_[index_].reindent = true;
        advance();
        parseConditionAndBlock(BlockKind::Loop);
        if (!failed_) controls_.push_back({keyword, attached, index_});
    }

    void parseFor(int newlinesBefore) {
        const auto keyword = index_;
        const auto attached = attachedStart(keyword, newlinesBefore);
        annotations_[index_].reindent = true;
        advance();
        parseConditionAndBlock(BlockKind::Loop);
        if (!failed_) controls_.push_back({keyword, attached, index_});
    }

    void parseSwitch(int newlinesBefore) {
        const auto keyword = index_;
        const auto attached = attachedStart(keyword, newlinesBefore);
        annotations_[index_].reindent = true;
        advance();
        if (!is(TokenType::LeftParen)) {
            fail("expected '('");
            return;
        }
        consumeDelimited(false);
        if (failed_) return;
        skipFree();
        if (!is(TokenType::LeftBrace)) {
            fail("expected '{'");
            return;
        }
        annotations_[index_].isOpenBrace = true;
        annotations_[index_].blockKind = BlockKind::Generic;
        advance();
        ++level_;
        while (!failed_ && !done() && !is(TokenType::RightBrace)) {
            skipNewlines(NewlineKind::Terminator);
            if (is(TokenType::RightBrace) || done()) break;
            if (take(TokenType::Case)) {
                if (!is(TokenType::LeftParen)) {
                    fail("expected '(' after case");
                    return;
                }
                consumeDelimited(true);
                if (failed_) return;
                skipFree();
                parseBlock(BlockKind::Generic);
            } else if (take(TokenType::Default)) {
                skipFree();
                parseBlock(BlockKind::Generic);
            } else {
                fail("expected case or default");
                return;
            }
        }
        if (failed_) return;
        if (!is(TokenType::RightBrace)) {
            fail("cannot group statements");
            return;
        }
        --level_;
        annotations_[index_].isCloseBrace = true;
        annotations_[index_].reindent = true;
        advance();
        controls_.push_back({keyword, attached, index_});
    }

    void parseDo(int newlinesBefore) {
        const auto keyword = index_;
        const auto attached = attachedStart(keyword, newlinesBefore);
        annotations_[index_].reindent = true;
        advance();
        skipFree();
        parseBlock(BlockKind::Loop);
        if (failed_) return;
        skipFree();
        if (!take(TokenType::While)) {
            fail("expected 'while' after do");
            return;
        }
        if (!is(TokenType::LeftParen)) {
            fail("expected '('");
            return;
        }
        consumeDelimited(false);
        if (!failed_) controls_.push_back({keyword, attached, index_});
    }

    void parseTry() {
        annotations_[index_].reindent = true;
        advance();
        skipFree();
        parseBlock(BlockKind::Generic);
        if (failed_) return;
        bool handler = false;
        while (!failed_) {
            std::size_t look = index_;
            while (look < tokens_.size() && tokens_[look].type == TokenType::Newline) ++look;
            if (look >= tokens_.size()) break;
            if (tokens_[look].type != TokenType::Except &&
                tokens_[look].type != TokenType::Finally) {
                break;
            }
            skipFree();
            if (is(TokenType::Except)) {
                annotations_[index_].isExcept = true;
                advance();
                if (is(TokenType::Newline)) {
                    fail("newline between except and '('");
                    return;
                }
                if (!is(TokenType::LeftParen)) {
                    fail("expected '(' after except");
                    return;
                }
                consumeDelimited(false);
                if (failed_) return;
                if (take(TokenType::As)) {
                    if (!take(TokenType::Identifier)) {
                        fail("expected an exception name");
                        return;
                    }
                }
                skipFree();
                parseBlock(BlockKind::Generic);
                handler = true;
                continue;
            }
            if (is(TokenType::Finally)) {
                annotations_[index_].isFinally = true;
                advance();
                skipFree();
                parseBlock(BlockKind::Generic);
                handler = true;
                break;
            }
            break;
        }
        if (!handler) fail("'try' requires an 'except' or 'finally' block");
    }

    void parseInline() {
        annotations_[index_].reindent = true;
        advance();
        if (is(TokenType::LeftParen)) consumeDelimited(true);
        if (failed_) return;
        if (!is(TokenType::InlineBody)) {
            fail("expected an inline C block");
            return;
        }
        advance();
    }

    void parseSimple(bool declaration) {
        annotations_[index_].reindent = true;
        if (declaration) {
            skipType();
            if (failed_) return;
            if (!take(TokenType::Identifier)) {
                fail("expected a name");
                return;
            }
            if (is(TokenType::LeftParen)) consumeDelimited(true);
            if (failed_) return;
            if (is(TokenType::Inline)) {
                parseInline();
                return;
            }
        }
        consumeStatementTail(false);
    }

    void parseStatement(int newlinesBefore, bool& declaration) {
        const auto begin = index_;
        declaration = false;
        if (is(TokenType::Inline)) {
            parseInline();
        } else if (is(TokenType::If)) {
            parseIf(newlinesBefore);
        } else if (is(TokenType::While)) {
            parseWhile(newlinesBefore);
        } else if (is(TokenType::For)) {
            parseFor(newlinesBefore);
        } else if (is(TokenType::Switch)) {
            parseSwitch(newlinesBefore);
        } else if (is(TokenType::Do)) {
            parseDo(newlinesBefore);
        } else if (is(TokenType::Try)) {
            parseTry();
        } else if (is(TokenType::LeftBrace)) {
            annotations_[index_].reindent = true;
            parseBlock(BlockKind::Generic);
        } else if (is(TokenType::Return) || is(TokenType::Raise) || is(TokenType::Print) ||
                   is(TokenType::Break) || is(TokenType::Continue)) {
            annotations_[index_].reindent = true;
            const bool call = is(TokenType::Return) || is(TokenType::Raise) || is(TokenType::Print);
            advance();
            if (call && is(TokenType::LeftParen)) consumeDelimited(true);
            else if (call && !is(TokenType::Newline) && !is(TokenType::RightBrace) &&
                     !is(TokenType::End)) {
                fail("cannot group statements");
            }
        } else if (is(TokenType::Super) || is(TokenType::Virtual)) {
            annotations_[index_].reindent = true;
            if (is(TokenType::Super)) {
                advance();
                take(TokenType::Virtual);
            } else {
                advance();
                if (!take(TokenType::Super)) fail("expected 'super'");
            }
            if (!failed_) consumeStatementTail(false);
        } else if (!done() && isNextWord(cur()) && index_ + 1 < tokens_.size() &&
                   (tokens_[index_ + 1].type == TokenType::Newline ||
                    tokens_[index_ + 1].type == TokenType::RightBrace ||
                    tokens_[index_ + 1].type == TokenType::End)) {
            annotations_[index_].reindent = true;
            advance();
        } else if (is(TokenType::Identifier) || is(TokenType::LeftParen) || isTypeStart(cur().type)) {
            declaration = looksLikeDeclaration();
            parseSimple(declaration);
        } else {
            fail("cannot group statements");
        }
        if (!failed_ && index_ == begin) fail("cannot group statements");
    }

    void parseEnum() {
        annotations_[index_].reindent = true;
        advance();
        if (!is(TokenType::LeftBrace)) {
            fail("expected '{' after enum");
            return;
        }
        annotations_[index_].isOpenBrace = true;
        annotations_[index_].blockKind = BlockKind::Enum;
        advance();
        ++level_;
        while (!failed_ && !done() && !is(TokenType::RightBrace)) {
            skipNewlines(NewlineKind::Terminator);
            if (is(TokenType::RightBrace) || done()) break;
            annotations_[index_].reindent = true;
            if (!take(TokenType::Identifier)) {
                fail("expected an enum member");
                return;
            }
            if (is(TokenType::Equal)) {
                advance();
                consumeStatementTail(true);
            }
            if (failed_) return;
            if (take(TokenType::Comma)) continue;
            if (is(TokenType::RightBrace)) break;
            if (!is(TokenType::Newline)) {
                fail("expected ',' or newline after enum member");
                return;
            }
        }
        if (!is(TokenType::RightBrace)) {
            fail("cannot group statements");
            return;
        }
        --level_;
        annotations_[index_].isCloseBrace = true;
        annotations_[index_].reindent = true;
        advance();
    }

    void parseMethodAfterName(bool requireImmediateBrace) {
        if (!is(TokenType::LeftParen)) {
            fail("expected '('");
            return;
        }
        consumeDelimited(true);
        if (failed_) return;
        if (requireImmediateBrace) {
            if (is(TokenType::Newline)) {
                std::size_t look = index_;
                while (look < tokens_.size() && tokens_[look].type == TokenType::Newline) ++look;
                if (look < tokens_.size() && tokens_[look].type == TokenType::LeftBrace) {
                    fail("newline before '{' does not parse here");
                    return;
                }
            }
            if (is(TokenType::LeftBrace)) {
                parseBlock(BlockKind::Function);
                return;
            }
            consumeTerminator();
            return;
        }
        skipFree();
        if (is(TokenType::From)) {
            annotations_[index_].preserveIndent = true;
            advance();
            if (!is(TokenType::String)) {
                fail("expected a string after from");
                return;
            }
            advance();
            consumeTerminator();
            return;
        }
        if (is(TokenType::LeftBrace)) {
            parseBlock(BlockKind::Function);
            return;
        }
        fail("expected a method body or from");
    }

    void parseClass() {
        annotations_[index_].reindent = true;
        advance();
        if (!take(TokenType::Identifier)) {
            fail("expected a class name");
            return;
        }
        const auto nameIndex = index_ - 1;
        const std::string className = tokens_[nameIndex].lexeme;
        if (is(TokenType::Colon)) {
            advance();
            while (!failed_ && !is(TokenType::LeftBrace) && !done()) {
                annotations_[index_].forbidWrap = true;
                if (is(TokenType::Newline)) {
                    fail("cannot group statements");
                    return;
                }
                advance();
            }
        }
        if (is(TokenType::Newline)) {
            fail("newline before '{' does not parse here");
            return;
        }
        if (!is(TokenType::LeftBrace)) {
            fail("expected '{'");
            return;
        }
        annotations_[index_].isOpenBrace = true;
        annotations_[index_].blockKind = BlockKind::Generic;
        advance();
        ++level_;
        while (!failed_ && !done() && !is(TokenType::RightBrace)) {
            skipNewlines(NewlineKind::Terminator);
            if (is(TokenType::RightBrace) || done()) break;
            if ((is(TokenType::Public) || is(TokenType::Protected) || is(TokenType::Private)) &&
                index_ + 1 < tokens_.size() && tokens_[index_ + 1].type == TokenType::Colon) {
                annotations_[index_].reindent = true;
                advance();
                advance();
                continue;
            }
            if (isEnumWord(cur()) && index_ + 1 < tokens_.size() &&
                tokens_[index_ + 1].type == TokenType::LeftBrace) {
                parseEnum();
                continue;
            }
            if (is(TokenType::Identifier) && cur().lexeme == "destroy") {
                annotations_[index_].reindent = true;
                advance();
                if (is(TokenType::Newline) || !is(TokenType::LeftBrace)) {
                    fail("newline before '{' does not parse here");
                    return;
                }
                parseBlock(BlockKind::Function);
                continue;
            }
            if (!isTypeStart(cur().type)) {
                fail("cannot group statements");
                return;
            }
            const auto typeStart = index_;
            const bool constructor =
                is(TokenType::Identifier) && cur().lexeme == className &&
                index_ + 1 < tokens_.size() && tokens_[index_ + 1].type == TokenType::LeftParen;
            if (constructor) {
                annotations_[index_].reindent = true;
                advance();
                parseMethodAfterName(true);
                continue;
            }
            skipType();
            if (failed_) return;
            if (!is(TokenType::Identifier)) {
                fail("expected a field or method name");
                return;
            }
            annotations_[typeStart].reindent = true;
            advance();
            if (is(TokenType::LeftParen)) {
                parseMethodAfterName(true);
                continue;
            }
            consumeStatementTail(false);
            if (failed_) return;
            consumeTerminator();
        }
        if (!is(TokenType::RightBrace)) {
            fail("cannot group statements");
            return;
        }
        --level_;
        annotations_[index_].isCloseBrace = true;
        annotations_[index_].reindent = true;
        advance();
    }

    void parseNamespace() {
        annotations_[index_].reindent = true;
        advance();
        if (!take(TokenType::Identifier)) {
            fail("expected a namespace name");
            return;
        }
        skipFree();
        if (!is(TokenType::LeftBrace)) {
            fail("expected '{'");
            return;
        }
        annotations_[index_].isOpenBrace = true;
        annotations_[index_].blockKind = BlockKind::Generic;
        advance();
        ++level_;
        while (!failed_ && !done() && !is(TokenType::RightBrace)) {
            skipNewlines(NewlineKind::Terminator);
            if (is(TokenType::RightBrace) || done()) break;
            if (is(TokenType::Namespace)) parseNamespace();
            else if (is(TokenType::Class)) parseClass();
            else if (looksLikeOutOfLine()) parseOutOfLine();
            else fail("cannot group statements");
        }
        if (!is(TokenType::RightBrace)) {
            fail("cannot group statements");
            return;
        }
        --level_;
        annotations_[index_].isCloseBrace = true;
        annotations_[index_].reindent = true;
        advance();
    }

    void parseOutOfLine() {
        annotations_[index_].reindent = true;
        skipType();
        if (failed_) return;
        if (!take(TokenType::Identifier)) {
            fail("expected a class name");
            return;
        }
        while (!failed_ && is(TokenType::Dot)) {
            advance();
            if (!take(TokenType::Identifier)) {
                fail("expected a method name");
                return;
            }
        }
        parseMethodAfterName(false);
    }

    void parseTopItem() {
        if (is(TokenType::Import)) {
            annotations_[index_].reindent = true;
            advance();
            if (!take(TokenType::Identifier)) {
                fail("expected a module name");
                return;
            }
            if (take(TokenType::As) && !take(TokenType::Identifier)) {
                fail("expected an import alias");
                return;
            }
            consumeTerminator();
            return;
        }
        if (is(TokenType::Include)) {
            annotations_[index_].reindent = true;
            advance();
            if (!is(TokenType::String)) {
                fail("expected a string after include");
                return;
            }
            advance();
            consumeTerminator();
            return;
        }
        if (is(TokenType::Class)) {
            parseClass();
            return;
        }
        if (is(TokenType::Namespace)) {
            parseNamespace();
            return;
        }
        if (is(TokenType::Start)) {
            annotations_[index_].reindent = true;
            advance();
            skipFree();
            parseBlock(BlockKind::Generic);
            return;
        }
        if (looksLikeOutOfLine()) {
            parseOutOfLine();
            return;
        }
        fail("cannot group statements");
    }

    void parseFile() {
        skipNewlines(NewlineKind::Terminator);
        while (!failed_ && !done()) {
            const auto begin = index_;
            parseTopItem();
            if (failed_) return;
            if (index_ == begin) {
                fail("cannot group statements");
                return;
            }
            noteLine(begin);
            skipNewlines(NewlineKind::Terminator);
        }
    }
};

} // namespace

UnwrapResult unwrapLines(const std::vector<FormatToken>& tokens) {
    return Walker(tokens).run();
}

} // namespace cwhip
