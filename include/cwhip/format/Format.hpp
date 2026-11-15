/**
 * @file Format.hpp
 * @brief formatSource and the file edge around it.
 */
#pragma once

#include "cwhip/format/Style.hpp"

#include <string>
#include <string_view>

namespace cwhip {

struct FormatResult {
    /// False when the walk or the lexer gives up. `text` is the original bytes.
    bool ok = true;
    std::string text;
    /// `path:line:column: message` when ok is false.
    std::string diagnostic;
};

FormatResult formatSource(std::string_view source, const Style& style,
                          std::string_view fileName);

/// `firstLine` and `lastLine` are 1-based and inclusive. Zero formats the
/// whole buffer. Lines outside the range are copied unchanged. A range that
/// touches a statement formats that whole statement.
FormatResult formatSourceRange(std::string_view source, const Style& style,
                               std::string_view fileName, int firstLine, int lastLine);

} // namespace cwhip
