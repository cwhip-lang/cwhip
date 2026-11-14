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

} // namespace cwhip
