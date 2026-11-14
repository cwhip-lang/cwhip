/**
 * @file Printer.cpp
 * @brief Reprint, then indent, short blocks, column wrapping, and long-control blanks.
 *
 * An unset open key does not insert or remove a break, a brace newline, a space
 * before '(', or a comment-pragma exemption.
 */
#include "cwhip/format/Style.hpp"
#include "cwhip/format/UnwrappedLine.hpp"

#include <algorithm>
#include <regex>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

namespace cwhip {
namespace {

constexpr std::size_t kNone = static_cast<std::size_t>(-1);

struct OutLine {
    std::string text;
    std::size_t first = kNone;
    std::size_t last = kNone;
    bool terminated = false;
};

struct Breaks {
    std::vector<bool> before;
    std::vector<bool> wrap;
    std::vector<bool> attach;
};

bool expandBlock(BlockKind kind, const Style& style) {
    const bool blocks = style.allowShortBlocks == AllowShortBlocks::Never;
    switch (kind) {
    case BlockKind::Function:
        return style.allowShortFunctions == AllowShortFunctions::None || blocks;
    case BlockKind::If:
        return style.allowShortIf == AllowShortIf::Never || blocks;
    case BlockKind::Loop:
        return !style.allowShortLoops || blocks;
    case BlockKind::Enum:
        return !style.allowShortEnums;
    case BlockKind::Generic:
        return blocks;
    case BlockKind::None:
        return false;
    }
    return false;
}

bool horizontal(FormatTriviaKind kind) {
    return kind == FormatTriviaKind::Space || kind == FormatTriviaKind::Tab ||
           kind == FormatTriviaKind::CarriageReturn || kind == FormatTriviaKind::VerticalTab ||
           kind == FormatTriviaKind::FormFeed;
}

std::size_t columns(std::string_view text) {
    std::size_t count = 0;
    for (unsigned char value : text) {
        if ((value & 0xc0) != 0x80) ++count;
    }
    return count;
}

bool whitespaceOnly(std::string_view text) {
    return std::all_of(text.begin(), text.end(), [](unsigned char value) {
        return value == ' ' || value == '\t' || value == '\r' || value == '\v' || value == '\f';
    });
}

bool isControlKeyword(TokenType type) {
    return type == TokenType::If || type == TokenType::While || type == TokenType::For ||
           type == TokenType::Switch;
}

bool isCallLike(TokenType type) {
    return type == TokenType::Identifier || type == TokenType::RightParen ||
           type == TokenType::RightBracket || type == TokenType::Greater ||
           type == TokenType::String;
}

bool leaveParenSpace(TokenType type) {
    return type == TokenType::Print || type == TokenType::Return || type == TokenType::Raise ||
           type == TokenType::Except;
}

std::size_t matchingClose(const std::vector<FormatToken>& tokens, std::size_t open) {
    int depth = 0;
    for (std::size_t index = open; index < tokens.size(); ++index) {
        const auto type = tokens[index].type;
        if (type == TokenType::LeftParen || type == TokenType::LeftBracket) ++depth;
        else if (type == TokenType::RightParen || type == TokenType::RightBracket) {
            --depth;
            if (depth == 0) return index;
        }
    }
    return tokens.size();
}

std::size_t matchingBrace(const std::vector<FormatToken>& tokens, std::size_t open) {
    int depth = 0;
    for (std::size_t index = open; index < tokens.size(); ++index) {
        if (tokens[index].type == TokenType::LeftBrace) ++depth;
        else if (tokens[index].type == TokenType::RightBrace) {
            --depth;
            if (depth == 0) return index;
        }
    }
    return tokens.size();
}

class Printer {
public:
    Printer(std::string_view sourceText, const std::vector<FormatToken>& tokenList,
            const UnwrapResult& parsed, const Style& active)
        : source_(sourceText), tokens_(tokenList), unwrapped_(parsed), style_(active) {
        if (style_.commentPragmas && !style_.commentPragmas->empty()) {
            try {
                pragma_ = std::regex(*style_.commentPragmas);
            } catch (const std::regex_error&) {
                pragma_.reset();
            }
        }
    }

    std::string run() const {
        Breaks breaks;
        plan(breaks);
        auto lines = emit(breaks);
        explode(lines);
        applyControlBlanks(lines);
        std::string text;
        for (const auto& line : lines) {
            text += line.text;
            if (line.terminated) text.push_back('\n');
        }
        return text;
    }

private:
    std::string_view source_;
    const std::vector<FormatToken>& tokens_;
    const UnwrapResult& unwrapped_;
    const Style& style_;
    std::optional<std::regex> pragma_;

    const TokenAnnotation& note(std::size_t index) const { return unwrapped_.annotations[index]; }

    bool pragmaMatches(std::string_view comment) const {
        if (!pragma_) return false;
        std::string payload(comment);
        if (payload.rfind("//", 0) == 0) payload.erase(0, 2);
        else if (!payload.empty() && payload[0] == '#') payload.erase(0, 1);
        if (!payload.empty() && payload[0] == ' ') payload.erase(0, 1);
        return std::regex_search(payload, *pragma_);
    }

    int indentSpaces(std::size_t index, bool wrap) const {
        int spaces = note(index).blockLevel * style_.indentWidth;
        if (wrap) spaces += style_.continuationIndentWidth;
        return spaces < 0 ? 0 : spaces;
    }

    void plan(Breaks& breaks) const {
        breaks.before.assign(tokens_.size(), false);
        breaks.wrap.assign(tokens_.size(), false);
        breaks.attach.assign(tokens_.size(), false);
        planShortBlocks(breaks);
        planBraceNewlines(breaks);
        planBraces(breaks);
        planWraps(breaks);
    }

    void planShortBlocks(Breaks& breaks) const {
        for (std::size_t index = 0; index < tokens_.size(); ++index) {
            if (!note(index).isOpenBrace) continue;
            if (!expandBlock(note(index).blockKind, style_)) continue;
            const auto close = matchingBrace(tokens_, index);
            if (close >= tokens_.size()) continue;
            if (tokens_[index].location.line != tokens_[close].location.line) continue;
            bool split = false;
            for (std::size_t cursor = index + 1; cursor < close; ++cursor) {
                if (tokens_[cursor].type == TokenType::Newline) split = true;
            }
            if (split) continue;
            // The token after '{' is the body, or '}' when the block is empty.
            if (style_.newlineAfterOpenBrace && close > index + 1) breaks.before[index + 1] = true;
            if (close == index + 1) {
                if (style_.newlineAfterOpenBrace) breaks.before[close] = true;
            } else {
                breaks.before[close] = true;
            }
        }
    }

    bool codePrecedesOnThisLine(std::size_t index) const {
        while (index > 0) {
            --index;
            const auto type = tokens_[index].type;
            if (type == TokenType::Newline || type == TokenType::End) return false;
            return true;
        }
        return false;
    }

    /// Next code token sharing this token's line, or size() when a newline
    /// (or the end of the file) already separates them.
    std::size_t nextCodeOnSameLine(std::size_t index) const {
        for (std::size_t cursor = index + 1; cursor < tokens_.size(); ++cursor) {
            const auto type = tokens_[cursor].type;
            if (type == TokenType::Newline || type == TokenType::End) return tokens_.size();
            return cursor;
        }
        return tokens_.size();
    }

    bool oneLineKeptShort(std::size_t open) const {
        if (!note(open).isOpenBrace) return false;
        if (expandBlock(note(open).blockKind, style_)) return false;
        const auto close = matchingBrace(tokens_, open);
        if (close >= tokens_.size()) return false;
        if (tokens_[open].location.line != tokens_[close].location.line) return false;
        for (std::size_t cursor = open + 1; cursor < close; ++cursor) {
            if (tokens_[cursor].type == TokenType::Newline) return false;
        }
        return true;
    }

    bool clauseStays(TokenType type) const { return type == TokenType::While; }

    void planBraceNewlines(Breaks& breaks) const {
        for (std::size_t index = 0; index < tokens_.size(); ++index) {
            const auto type = tokens_[index].type;
            const bool open = type == TokenType::LeftBrace;
            const bool close = type == TokenType::RightBrace;
            if (!open && !close) continue;
            if (open && style_.newlineBeforeOpenBrace && note(index).openBraceMayBreak &&
                codePrecedesOnThisLine(index)) {
                breaks.before[index] = true;
            }
            const auto next = nextCodeOnSameLine(index);
            // else is NewlineBeforeElse, not NewlineAfterCloseBrace.
            if (close && next < tokens_.size() && tokens_[next].type == TokenType::Else) {
                if (style_.newlineBeforeElse) breaks.before[next] = true;
                continue;
            }
            // except and finally are NewlineBeforeExcept, not NewlineAfterCloseBrace.
            if (close && next < tokens_.size() &&
                (tokens_[next].type == TokenType::Except ||
                 tokens_[next].type == TokenType::Finally)) {
                if (style_.newlineBeforeExcept) breaks.before[next] = true;
                continue;
            }
            if (open && !style_.newlineAfterOpenBrace) continue;
            if (close && !style_.newlineAfterCloseBrace) continue;
            if (next >= tokens_.size()) continue;
            // do/while's while stays on the brace line.
            if (close && clauseStays(tokens_[next].type)) continue;
            // AllowShort* still keeps a one-line block it was asked to keep.
            if (open && oneLineKeptShort(index)) continue;
            breaks.before[next] = true;
        }
    }

    void planBraces(Breaks& breaks) const {
        if (style_.braceBinding != BraceBinding::Custom) return;
        for (std::size_t index = 0; index < tokens_.size(); ++index) {
            const auto& annotation = note(index);
            if ((annotation.isElse || annotation.isExcept || annotation.isFinally) && index > 0 &&
                tokens_[index - 1].type != TokenType::Newline) {
                breaks.before[index] = true;
            }
            if (!annotation.isOpenBrace || annotation.blockKind == BlockKind::Enum) continue;
            if (index == 0 || tokens_[index - 1].type != TokenType::Newline) continue;
            if (note(index - 1).newlineKind != NewlineKind::Free) continue;
            if (index >= 2 && tokens_[index - 2].type == TokenType::Newline) continue;
            breaks.attach[index] = true;
        }
    }

    void planWraps(Breaks& breaks) const {
        if (style_.columnLimit <= 0) return;
        const auto limit = static_cast<std::size_t>(style_.columnLimit);
        for (int pass = 0; pass < static_cast<int>(tokens_.size()) + 1; ++pass) {
            if (!improve(breaks, limit)) return;
        }
    }

    bool attachedNewline(std::size_t index, const Breaks& breaks) const {
        return tokens_[index].type == TokenType::Newline && index + 1 < tokens_.size() &&
               breaks.attach[index + 1];
    }

    bool improve(Breaks& breaks, std::size_t limit) const {
        std::size_t index = 0;
        while (index < tokens_.size()) {
            if (tokens_[index].type == TokenType::End) break;
            if (tokens_[index].type == TokenType::Newline) {
                ++index;
                continue;
            }
            const auto start = index;
            ++index;
            while (index < tokens_.size() && tokens_[index].type != TokenType::End &&
                   !breaks.before[index] &&
                   (tokens_[index].type != TokenType::Newline || attachedNewline(index, breaks))) {
                ++index;
            }
            if (lineWidth(start, index, breaks) <= limit) continue;
            if (breakList(start, index, breaks, limit)) return true;
            if (breakOperator(start, index, breaks, limit)) return true;
        }
        return false;
    }

    std::size_t lineWidth(std::size_t begin, std::size_t end, const Breaks& breaks) const {
        std::size_t column = lineStartColumn(begin, breaks);
        bool first = true;
        for (std::size_t index = begin; index < end; ++index) {
            if (tokens_[index].type == TokenType::Newline) continue;
            if (!first && breaks.attach[index]) {
                column += 1;
                std::size_t trivia = 0;
                while (trivia < tokens_[index].leading.size() &&
                       horizontal(tokens_[index].leading[trivia].kind)) {
                    ++trivia;
                }
                for (; trivia < tokens_[index].leading.size(); ++trivia) {
                    column += columns(tokens_[index].leading[trivia].text);
                }
            } else if (!first) {
                for (const auto& trivia : tokens_[index].leading) column += columns(trivia.text);
            } else {
                const bool skip = !note(index).rawLine && !note(index).preserveIndent &&
                                  (note(index).reindent || breaks.before[index] ||
                                   note(index).isCloseBrace || note(index).isOpenBrace ||
                                   breaks.wrap[index]);
                std::size_t trivia = 0;
                if (skip) {
                    while (trivia < tokens_[index].leading.size() &&
                           horizontal(tokens_[index].leading[trivia].kind)) {
                        ++trivia;
                    }
                }
                for (; trivia < tokens_[index].leading.size(); ++trivia) {
                    column += columns(tokens_[index].leading[trivia].text);
                }
            }
            first = false;
            if (tokens_[index].type == TokenType::InlineBody) column += 2;
            column += columns(tokens_[index].lexeme);
        }
        return column;
    }

    std::size_t lineStartColumn(std::size_t begin, const Breaks& breaks) const {
        const auto& annotation = note(begin);
        if (annotation.rawLine || annotation.preserveIndent) {
            std::size_t column = 0;
            for (const auto& trivia : tokens_[begin].leading) {
                if (!horizontal(trivia.kind)) break;
                column += columns(trivia.text);
            }
            return column;
        }
        if (annotation.reindent || breaks.before[begin] || annotation.isCloseBrace ||
            annotation.isOpenBrace || breaks.wrap[begin]) {
            return static_cast<std::size_t>(indentSpaces(begin, breaks.wrap[begin]));
        }
        std::size_t column = 0;
        for (const auto& trivia : tokens_[begin].leading) {
            if (!horizontal(trivia.kind)) break;
            column += columns(trivia.text);
        }
        return column;
    }

    bool sameOutputLine(std::size_t left, std::size_t right, const Breaks& breaks) const {
        for (std::size_t index = left + 1; index <= right && index < tokens_.size(); ++index) {
            if (breaks.before[index]) return false;
            if (tokens_[index].type == TokenType::Newline && !attachedNewline(index, breaks)) {
                return false;
            }
        }
        return true;
    }

    bool breakList(std::size_t begin, std::size_t end, Breaks& breaks, std::size_t limit) const {
        std::size_t chosen = tokens_.size();
        std::size_t column = lineStartColumn(begin, breaks);
        bool first = true;
        std::vector<std::size_t> at(tokens_.size(), 0);
        for (std::size_t index = begin; index < end; ++index) {
            if (tokens_[index].type == TokenType::Newline) continue;
            if (!first) {
                if (breaks.attach[index]) column += 1;
                else {
                    for (const auto& trivia : tokens_[index].leading) column += columns(trivia.text);
                }
            }
            first = false;
            at[index] = column;
            if (tokens_[index].type == TokenType::InlineBody) column += 2;
            column += columns(tokens_[index].lexeme);
        }
        for (std::size_t index = begin; index < end; ++index) {
            if (tokens_[index].type == TokenType::Newline) continue;
            if (!note(index).listOpen || note(index).forbidWrap) continue;
            const auto close = matchingClose(tokens_, index);
            if (close >= end) continue;
            if (!sameOutputLine(index, close, breaks)) continue;
            bool already = false;
            for (std::size_t cursor = index + 1; cursor < close; ++cursor) {
                if (breaks.before[cursor]) already = true;
            }
            if (already) continue;
            const auto closeEnd = at[close] + columns(tokens_[close].lexeme);
            if (closeEnd <= limit) continue;
            chosen = index;
        }
        if (chosen >= tokens_.size()) return false;
        const auto close = matchingClose(tokens_, chosen);
        int depth = 0;
        bool sawItem = false;
        for (std::size_t index = chosen + 1; index < close; ++index) {
            if (tokens_[index].type == TokenType::Newline) continue;
            const auto type = tokens_[index].type;
            if (type == TokenType::LeftParen || type == TokenType::LeftBracket) {
                ++depth;
                if (depth == 1 && !sawItem) {
                    breaks.before[index] = true;
                    breaks.wrap[index] = true;
                    sawItem = true;
                }
                continue;
            }
            if (type == TokenType::RightParen || type == TokenType::RightBracket) {
                if (depth > 0) --depth;
                continue;
            }
            if (depth > 0) continue;
            if (!sawItem) {
                breaks.before[index] = true;
                breaks.wrap[index] = true;
                sawItem = true;
                continue;
            }
            if (type == TokenType::Comma && index + 1 < close &&
                tokens_[index + 1].type != TokenType::RightParen &&
                tokens_[index + 1].type != TokenType::RightBracket) {
                breaks.before[index + 1] = true;
                breaks.wrap[index + 1] = true;
            }
        }
        return sawItem;
    }

    bool breakOperator(std::size_t begin, std::size_t end, Breaks& breaks,
                       std::size_t limit) const {
        if (!style_.breakBeforeBinaryOperators) return false;
        const bool beforeOp =
            *style_.breakBeforeBinaryOperators == BreakBeforeBinaryOperators::NonAssignment;
        std::size_t chosen = kNone;
        std::size_t fallback = kNone;
        std::size_t column = lineStartColumn(begin, breaks);
        bool first = true;
        for (std::size_t index = begin; index < end; ++index) {
            if (tokens_[index].type == TokenType::Newline) continue;
            if (!first) {
                for (const auto& trivia : tokens_[index].leading) column += columns(trivia.text);
            }
            first = false;
            const bool op = note(index).binaryOperator && note(index).parenDepthBefore > 0 &&
                            !note(index).forbidWrap;
            if (op) {
                if (fallback == kNone) fallback = index;
                const auto at = beforeOp ? column : column + columns(tokens_[index].lexeme);
                if (at <= limit) chosen = index;
            }
            if (tokens_[index].type == TokenType::InlineBody) column += 2;
            column += columns(tokens_[index].lexeme);
        }
        if (chosen == kNone) chosen = fallback;
        if (chosen == kNone || chosen >= end) return false;
        if (beforeOp) {
            if (breaks.before[chosen]) return false;
            breaks.before[chosen] = true;
            breaks.wrap[chosen] = true;
            return true;
        }
        std::size_t next = chosen + 1;
        while (next < end && tokens_[next].type == TokenType::Newline) ++next;
        if (next >= end || breaks.before[next]) return false;
        breaks.before[next] = true;
        breaks.wrap[next] = true;
        return true;
    }

    std::vector<OutLine> emit(const Breaks& breaks) const {
        std::vector<OutLine> lines;
        std::string current;
        std::size_t first = kNone;
        std::size_t last = kNone;
        bool atLineStart = true;
        bool sourceLineStart = true;
        std::size_t lineByte = 0;
        auto finish = [&](bool terminated) {
            OutLine line;
            line.text = std::move(current);
            line.first = first;
            line.last = last;
            line.terminated = terminated;
            lines.push_back(std::move(line));
            current.clear();
            first = kNone;
            last = kNone;
            atLineStart = true;
        };
        for (std::size_t index = 0; index < tokens_.size(); ++index) {
            const auto& token = tokens_[index];
            if (token.type == TokenType::End) {
                appendTrivia(current, index, false, false, breaks);
                break;
            }
            if (attachedNewline(index, breaks)) continue;
            if (sourceLineStart && lineFrozen(index)) {
                const auto newline = nextNewline(index);
                const auto stop = newline < tokens_.size() ? tokens_[newline].end : source_.size();
                current.assign(source_.data() + lineByte, stop - lineByte);
                if (!current.empty() && current.back() == '\n') current.pop_back();
                first = index;
                last = newline < tokens_.size() ? newline : index;
                const bool terminated = newline < tokens_.size();
                finish(terminated);
                if (terminated) {
                    lineByte = tokens_[newline].end;
                    index = newline;
                } else {
                    index = tokens_.size() - 1;
                }
                sourceLineStart = true;
                continue;
            }
            if (breaks.before[index] && !atLineStart) {
                finish(true);
                sourceLineStart = false;
            }
            if (token.type == TokenType::Newline) {
                appendTrivia(current, index, atLineStart, false, breaks);
                if (first == kNone) first = index;
                last = index;
                finish(true);
                lineByte = token.end;
                sourceLineStart = true;
                continue;
            }
            if (first == kNone) first = index;
            last = index;
            const bool wrapping = breaks.wrap[index];
            appendTrivia(current, index, atLineStart, wrapping, breaks);
            if (token.type == TokenType::InlineBody) {
                current.push_back('{');
                current += token.lexeme;
                current.push_back('}');
            } else {
                current += token.lexeme;
            }
            atLineStart = false;
            sourceLineStart = false;
        }
        if (!current.empty() || lines.empty()) finish(false);
        return lines;
    }

    std::size_t nextNewline(std::size_t index) const {
        for (std::size_t cursor = index; cursor < tokens_.size(); ++cursor) {
            if (tokens_[cursor].type == TokenType::Newline) return cursor;
        }
        return tokens_.size();
    }

    bool lineFrozen(std::size_t begin) const {
        if (!pragma_) return false;
        const auto end = nextNewline(begin);
        const auto stop = end < tokens_.size() ? end + 1 : tokens_.size();
        for (std::size_t index = begin; index < stop; ++index) {
            for (const auto& trivia : tokens_[index].leading) {
                if (trivia.kind == FormatTriviaKind::LineComment && pragmaMatches(trivia.text)) {
                    return true;
                }
            }
        }
        return false;
    }

    TokenType previousCode(std::size_t index) const {
        while (index > 0) {
            --index;
            if (tokens_[index].type != TokenType::Newline && tokens_[index].type != TokenType::End) {
                return tokens_[index].type;
            }
        }
        return TokenType::End;
    }

    void appendTrivia(std::string& current, std::size_t index, bool atLineStart, bool wrap,
                      const Breaks& breaks) const {
        const auto& token = tokens_[index];
        const auto& annotation = note(index);
        const bool attach = breaks.attach[index];
        const bool replace = atLineStart && token.type != TokenType::Newline &&
                             token.type != TokenType::End && !annotation.rawLine &&
                             !annotation.preserveIndent &&
                             (annotation.reindent || breaks.before[index] || annotation.isCloseBrace ||
                              annotation.isOpenBrace || wrap);
        std::size_t triviaIndex = 0;
        if (replace || attach) {
            while (triviaIndex < token.leading.size() && horizontal(token.leading[triviaIndex].kind)) {
                ++triviaIndex;
            }
        }
        if (replace) {
            const bool commentFirst = triviaIndex == 0 && triviaIndex < token.leading.size() &&
                                      token.leading[triviaIndex].kind == FormatTriviaKind::BlockComment;
            if (!commentFirst) current.append(static_cast<std::size_t>(indentSpaces(index, wrap)), ' ');
        } else if (attach) {
            if (current.empty() || current.back() != ' ') current.push_back(' ');
        }

        const bool adjust = token.type == TokenType::LeftParen && style_.spaceBeforeParens &&
                            !atLineStart && !attach;
        enum class ParenSpace { Keep, Drop, Force };
        ParenSpace paren = ParenSpace::Keep;
        if (adjust) {
            const auto previous = previousCode(index);
            const auto mode = *style_.spaceBeforeParens;
            if (mode == SpaceBeforeParens::Never) paren = ParenSpace::Drop;
            else if (isControlKeyword(previous)) paren = ParenSpace::Force;
            else if (isCallLike(previous)) paren = ParenSpace::Drop;
            else if (leaveParenSpace(previous)) paren = ParenSpace::Keep;
        }

        for (; triviaIndex < token.leading.size(); ++triviaIndex) {
            const auto& trivia = token.leading[triviaIndex];
            if (paren != ParenSpace::Keep && horizontal(trivia.kind)) continue;
            if (trivia.kind == FormatTriviaKind::LineComment && !pragmaMatches(trivia.text) &&
                style_.reflowComments && style_.columnLimit > 0) {
                const auto used = columns(current) + columns(trivia.text);
                if (used > static_cast<std::size_t>(style_.columnLimit)) {
                    reflow(current, trivia.text, atLineStart);
                    continue;
                }
            }
            current += trivia.text;
        }
        if (paren == ParenSpace::Force && (current.empty() || current.back() != ' ')) {
            current.push_back(' ');
        }
    }

    void reflow(std::string& current, const std::string& comment, bool fullLine) const {
        const bool slash = comment.rfind("//", 0) == 0;
        if (!slash && (comment.empty() || comment[0] != '#')) {
            current += comment;
            return;
        }
        const std::string marker = slash ? "//" : "#";
        std::string body = comment.substr(marker.size());
        const bool spaced = !body.empty() && (body[0] == ' ' || body[0] == '\t');
        if (spaced) body.erase(0, 1);
        std::vector<std::string> words;
        std::string word;
        for (char value : body) {
            if (value == ' ' || value == '\t') {
                if (!word.empty()) {
                    words.push_back(word);
                    word.clear();
                }
            } else {
                word.push_back(value);
            }
        }
        if (!word.empty()) words.push_back(std::move(word));

        const int indent = fullLine ? static_cast<int>(columns(current)) : statementIndent(current);
        std::string prefix(static_cast<std::size_t>(indent > 0 ? indent : 0), ' ');
        prefix += marker;
        if (spaced || !words.empty()) prefix.push_back(' ');
        const auto limit = static_cast<std::size_t>(style_.columnLimit);
        if (prefix.size() >= limit) {
            current += comment;
            return;
        }

        std::string first;
        if (fullLine) first = prefix;
        else {
            first = current;
            if (!first.empty() && first.back() != ' ') first.push_back(' ');
            first += marker;
            if (spaced || !words.empty()) first.push_back(' ');
        }
        std::string line = first;
        std::string built;
        bool wrapped = false;
        auto commit = [&]() {
            if (!built.empty()) built.push_back('\n');
            built += line;
            wrapped = true;
        };
        for (const auto& piece : words) {
            const bool emptyLine = fullLine ? line.size() == prefix.size()
                                            : (!wrapped && line.size() == first.size()) ||
                                                  (wrapped && line.size() == prefix.size());
            if (emptyLine) {
                line += piece;
                continue;
            }
            if (line.size() + 1 + piece.size() <= limit) {
                line.push_back(' ');
                line += piece;
                continue;
            }
            commit();
            line = prefix + piece;
        }
        commit();
        current = std::move(built);
    }

    int statementIndent(const std::string& current) const {
        std::size_t count = 0;
        while (count < current.size() && current[count] == ' ') ++count;
        return static_cast<int>(count);
    }

    void explode(std::vector<OutLine>& lines) const {
        std::vector<OutLine> exploded;
        for (const auto& line : lines) {
            std::size_t start = 0;
            bool piece = false;
            for (std::size_t index = 0; index <= line.text.size(); ++index) {
                if (index != line.text.size() && line.text[index] != '\n') continue;
                OutLine part;
                part.text = line.text.substr(start, index - start);
                part.terminated = index < line.text.size() || line.terminated;
                if (!piece) part.first = line.first;
                if (index == line.text.size()) part.last = line.last;
                exploded.push_back(std::move(part));
                piece = true;
                start = index + 1;
            }
        }
        lines.swap(exploded);
    }

    int lineOf(const std::vector<OutLine>& lines, std::size_t token) const {
        if (token == kNone) return -1;
        for (std::size_t index = 0; index < lines.size(); ++index) {
            if (lines[index].first == kNone || lines[index].last == kNone) continue;
            if (lines[index].first <= token && token <= lines[index].last) {
                return static_cast<int>(index);
            }
        }
        return -1;
    }

    void applyControlBlanks(std::vector<OutLine>& lines) const {
        if (!style_.blankLinesAroundLongControlStatement) return;
        std::vector<bool> done(unwrapped_.controls.size(), false);
        for (std::size_t pass = 0; pass < unwrapped_.controls.size() + 1; ++pass) {
            std::vector<int> inserts;
            bool any = false;
            for (std::size_t index = 0; index < unwrapped_.controls.size(); ++index) {
                if (done[index]) continue;
                const auto& control = unwrapped_.controls[index];
                if (control.end == 0) continue;
                const int keyword = lineOf(lines, control.keyword);
                const int last = lineOf(lines, control.end - 1);
                if (keyword < 0 || last < keyword) continue;
                if (last - keyword + 1 <= style_.longControlStatementLines) continue;
                done[index] = true;
                any = true;
                const int before = lineOf(lines, control.attached);
                if (before >= 0 && (before == 0 || !whitespaceOnly(lines[static_cast<std::size_t>(before - 1)].text))) {
                    inserts.push_back(before);
                }
                const int after = last + 1;
                if (after >= static_cast<int>(lines.size()) ||
                    !whitespaceOnly(lines[static_cast<std::size_t>(after)].text)) {
                    inserts.push_back(after);
                }
            }
            if (!any) return;
            std::sort(inserts.begin(), inserts.end());
            inserts.erase(std::unique(inserts.begin(), inserts.end()), inserts.end());
            for (auto cursor = inserts.rbegin(); cursor != inserts.rend(); ++cursor) {
                const auto at = static_cast<std::size_t>(*cursor);
                if (at > 0 && at - 1 < lines.size() && !lines[at - 1].terminated) {
                    lines[at - 1].terminated = true;
                }
                OutLine blank;
                blank.terminated = true;
                if (at >= lines.size()) lines.push_back(std::move(blank));
                else lines.insert(lines.begin() + static_cast<std::ptrdiff_t>(at), std::move(blank));
            }
        }
    }
};

} // namespace

std::string printFormatted(std::string_view source, const std::vector<FormatToken>& tokens,
                           const UnwrapResult& unwrapped, const Style& style) {
    return Printer(source, tokens, unwrapped, style).run();
}

} // namespace cwhip
