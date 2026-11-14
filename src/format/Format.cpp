/**
 * @file Format.cpp
 * @brief formatSource plus the file and process edge the driver calls.
 */
#include "cwhip/format/Format.hpp"

#include "cwhip/Diagnostic.hpp"
#include "cwhip/RuntimeGc.h"
#include "cwhip/format/FormatLexer.hpp"
#include "cwhip/format/UnwrappedLine.hpp"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <string_view>
#include <vector>

namespace cwhip {

std::string printFormatted(std::string_view source, const std::vector<FormatToken>& tokens,
                           const UnwrapResult& unwrapped, const Style& style);

namespace {

std::string located(const std::string& file, const SourceLocation& location,
                    const std::string& message) {
    const std::string& name = location.file.empty() ? file : location.file;
    return name + ":" + std::to_string(location.line) + ":" + std::to_string(location.column) +
           ": " + message;
}

std::string readFile(const std::filesystem::path& path, std::string& error) {
    std::ifstream input(path, std::ios::binary);
    if (!input) {
        error = path.string() + ":1:1: cannot read file";
        return {};
    }
    std::ostringstream buffer;
    buffer << input.rdbuf();
    if (!input && !input.eof()) {
        error = path.string() + ":1:1: cannot read file";
        return {};
    }
    return buffer.str();
}

void writeStderr(const std::string& diagnostic) {
    std::fwrite(diagnostic.data(), 1, diagnostic.size(), stderr);
    if (diagnostic.empty() || diagnostic.back() != '\n') std::fputc('\n', stderr);
}

} // namespace

FormatResult formatSource(std::string_view source, const Style& style, std::string_view fileName) {
    const std::string name(fileName);
    try {
        FormatLexer lexer(std::string(source), name);
        const auto tokens = lexer.tokenize();
        const auto unwrapped = unwrapLines(tokens);
        if (!unwrapped.ok) {
            FormatResult failed;
            failed.ok = false;
            failed.text = std::string(source);
            failed.diagnostic = located(name, unwrapped.location, unwrapped.message);
            return failed;
        }
        FormatResult result;
        result.ok = true;
        result.text = printFormatted(source, tokens, unwrapped, style);
        return result;
    } catch (const DiagnosticError& error) {
        FormatResult failed;
        failed.ok = false;
        failed.text = std::string(source);
        failed.diagnostic = located(name, error.location(), error.message());
        return failed;
    }
}

std::string borrowString(void* object) {
    if (object == nullptr) return {};
    const char* data = nullptr;
    uint64_t length = 0;
    cwhip_string_bytes(object, &data, &length);
    if (data == nullptr || length == 0) return {};
    return std::string(data, data + length);
}

StyleLoadResult styleFor(const std::string& stylePath) {
    if (!stylePath.empty()) {
        std::string error;
        const auto text = readFile(stylePath, error);
        if (!error.empty()) {
            StyleLoadResult failed;
            failed.ok = false;
            failed.diagnostic = error;
            return failed;
        }
        return parseStyleText(text, stylePath);
    }
    std::error_code failure;
    const auto directory = std::filesystem::current_path(failure);
    if (failure) {
        StyleLoadResult failed;
        failed.ok = false;
        failed.diagnostic = ".:1:1: cannot read the current directory";
        return failed;
    }
    return loadStyleAt(directory.string());
}

bool writeStdout(const std::string& text) {
    if (text.empty()) return true;
    const auto written = std::fwrite(text.data(), 1, text.size(), stdout);
    return written == text.size();
}

int64_t formatOne(const std::string& path, const std::string& stylePath, bool inPlace) {
    std::string error;
    const auto original = readFile(path, error);
    if (!error.empty()) {
        writeStderr(error);
        return 1;
    }
    const auto loaded = styleFor(stylePath);
    if (!loaded.ok) {
        writeStderr(loaded.diagnostic);
        return 1;
    }
    const auto formatted = formatSource(original, loaded.style, path);
    if (!formatted.ok) {
        writeStderr(formatted.diagnostic);
        if (!inPlace) {
            if (!writeStdout(original)) {
                writeStderr(path + ":1:1: cannot write stdout");
            }
        }
        return 1;
    }
    if (!inPlace) {
        if (!writeStdout(formatted.text)) {
            writeStderr(path + ":1:1: cannot write stdout");
            return 1;
        }
        return 0;
    }
    if (formatted.text == original) return 0;
    const auto temporary = path + ".cwhip-format-tmp";
    {
        std::ofstream output(temporary, std::ios::binary | std::ios::trunc);
        if (!output) {
            writeStderr(path + ":1:1: cannot write temporary file");
            return 1;
        }
        output.write(formatted.text.data(), static_cast<std::streamsize>(formatted.text.size()));
        if (!output) {
            output.close();
            std::error_code ignored;
            std::filesystem::remove(temporary, ignored);
            writeStderr(path + ":1:1: cannot write temporary file");
            return 1;
        }
    }
    std::error_code renameError;
    std::filesystem::rename(temporary, path, renameError);
    if (renameError) {
        std::error_code ignored;
        std::filesystem::remove(temporary, ignored);
        writeStderr(path + ":1:1: cannot replace file");
        return 1;
    }
    return 0;
}

} // namespace cwhip

extern "C" const CwhipClassMeta cwhip_string_class_meta __attribute__((weak));

#ifndef CWHIP_VERSION
#define CWHIP_VERSION "0.0.2"
#endif

extern "C" void* cwhip_format_version(void* /*self*/) {
    const char* version = CWHIP_VERSION;
    return cwhip_string_new(&cwhip_string_class_meta, version, std::strlen(version));
}

extern "C" void* cwhip_format_builtin_config(void* /*self*/) {
    const std::string text = cwhip::builtinConfigText();
    return cwhip_string_new(&cwhip_string_class_meta, text.data(), text.size());
}

extern "C" int64_t cwhip_format_file(void* /*self*/, void* path, void* stylePath, bool inPlace) {
    return cwhip::formatOne(cwhip::borrowString(path), cwhip::borrowString(stylePath), inPlace);
}
