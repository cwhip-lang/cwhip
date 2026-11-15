/**
 * @file LspServer.cpp
 * @brief Stdio language server for Cwhip. Speaks a small Language Server Protocol subset:
 * initialize, shutdown, exit, full-document open/change/save/close with
 * textDocument/publishDiagnostics, and textDocument/formatting plus
 * textDocument/rangeFormatting.
 */
#include "cwhip/Diagnostic.hpp"
#include "cwhip/SourceCheck.hpp"
#include "cwhip/format/Format.hpp"

#include <cctype>
#include <cstdint>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <map>
#include <optional>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

namespace {

struct Json;

struct Json {
    enum class Kind { Null, Bool, Number, String, Array, Object };
    Kind kind = Kind::Null;
    bool boolean = false;
    std::string text;
    std::vector<Json> array;
    std::vector<std::pair<std::string, Json>> object;

    const Json* field(const std::string& name) const {
        if (kind != Kind::Object) return nullptr;
        for (const auto& entry : object) {
            if (entry.first == name) return &entry.second;
        }
        return nullptr;
    }

    std::string stringField(const std::string& name) const {
        const Json* value = field(name);
        return value != nullptr && value->kind == Kind::String ? value->text : std::string();
    }
};

class JsonParser {
public:
    explicit JsonParser(const std::string& text) : text_(text) {}

    Json parse() {
        skip();
        Json value = parseValue();
        skip();
        return value;
    }

private:
    Json parseValue() {
        skip();
        if (pos_ >= text_.size()) return {};
        const char mark = text_[pos_];
        if (mark == '{') return parseObject();
        if (mark == '[') return parseArray();
        if (mark == '"') {
            Json value;
            value.kind = Json::Kind::String;
            value.text = parseString();
            return value;
        }
        if (mark == 't' || mark == 'f') {
            Json value;
            value.kind = Json::Kind::Bool;
            value.boolean = mark == 't';
            pos_ += mark == 't' ? 4 : 5;
            return value;
        }
        if (mark == 'n') {
            pos_ += 4;
            return {};
        }
        Json value;
        value.kind = Json::Kind::Number;
        const std::size_t start = pos_;
        if (text_[pos_] == '-') ++pos_;
        while (pos_ < text_.size() && (std::isdigit(static_cast<unsigned char>(text_[pos_])) ||
                                       text_[pos_] == '.')) {
            ++pos_;
        }
        value.text = text_.substr(start, pos_ - start);
        return value;
    }

    Json parseObject() {
        Json value;
        value.kind = Json::Kind::Object;
        ++pos_;
        skip();
        if (consume('}')) return value;
        for (;;) {
            skip();
            const std::string key = parseString();
            skip();
            consume(':');
            value.object.emplace_back(key, parseValue());
            skip();
            if (consume('}')) return value;
            consume(',');
        }
    }

    Json parseArray() {
        Json value;
        value.kind = Json::Kind::Array;
        ++pos_;
        skip();
        if (consume(']')) return value;
        for (;;) {
            value.array.push_back(parseValue());
            skip();
            if (consume(']')) return value;
            consume(',');
        }
    }

    std::string parseString() {
        if (!consume('"')) return {};
        std::string result;
        while (pos_ < text_.size()) {
            const char character = text_[pos_++];
            if (character == '"') return result;
            if (character != '\\' || pos_ >= text_.size()) {
                result.push_back(character);
                continue;
            }
            const char escaped = text_[pos_++];
            if (escaped == 'n') result.push_back('\n');
            else if (escaped == 'r') result.push_back('\r');
            else if (escaped == 't') result.push_back('\t');
            else if (escaped == 'u' && pos_ + 4 <= text_.size()) {
                int code = 0;
                for (int index = 0; index < 4; ++index) {
                    const char digit = text_[pos_++];
                    code <<= 4;
                    if (digit >= '0' && digit <= '9') code += digit - '0';
                    else if (digit >= 'a' && digit <= 'f') code += digit - 'a' + 10;
                    else if (digit >= 'A' && digit <= 'F') code += digit - 'A' + 10;
                }
                if (code < 0x80) result.push_back(static_cast<char>(code));
                else if (code < 0x800) {
                    result.push_back(static_cast<char>(0xC0 | (code >> 6)));
                    result.push_back(static_cast<char>(0x80 | (code & 0x3F)));
                } else {
                    result.push_back(static_cast<char>(0xE0 | (code >> 12)));
                    result.push_back(static_cast<char>(0x80 | ((code >> 6) & 0x3F)));
                    result.push_back(static_cast<char>(0x80 | (code & 0x3F)));
                }
            } else result.push_back(escaped);
        }
        return result;
    }

    void skip() {
        while (pos_ < text_.size() &&
               std::isspace(static_cast<unsigned char>(text_[pos_]))) {
            ++pos_;
        }
    }

    bool consume(char expected) {
        if (pos_ < text_.size() && text_[pos_] == expected) {
            ++pos_;
            return true;
        }
        return false;
    }

    const std::string& text_;
    std::size_t pos_ = 0;
};

std::string jsonString(const std::string& text) {
    std::string result = "\"";
    for (unsigned char character : text) {
        if (character == '"' || character == '\\') {
            result.push_back('\\');
            result.push_back(static_cast<char>(character));
        } else if (character == '\n') result += "\\n";
        else if (character == '\r') result += "\\r";
        else if (character == '\t') result += "\\t";
        else if (character < 0x20) {
            constexpr char digits[] = "0123456789abcdef";
            result += "\\u00";
            result.push_back(digits[character >> 4]);
            result.push_back(digits[character & 0x0F]);
        } else result.push_back(static_cast<char>(character));
    }
    result.push_back('"');
    return result;
}

std::string percentDecode(const std::string& text) {
    std::string result;
    for (std::size_t index = 0; index < text.size(); ++index) {
        if (text[index] == '%' && index + 2 < text.size()) {
            auto hex = [](char character) {
                if (character >= '0' && character <= '9') return character - '0';
                if (character >= 'a' && character <= 'f') return character - 'a' + 10;
                if (character >= 'A' && character <= 'F') return character - 'A' + 10;
                return -1;
            };
            const int high = hex(text[index + 1]);
            const int low = hex(text[index + 2]);
            if (high >= 0 && low >= 0) {
                result.push_back(static_cast<char>((high << 4) | low));
                index += 2;
                continue;
            }
        }
        result.push_back(text[index]);
    }
    return result;
}

std::filesystem::path uriPath(const std::string& uri) {
    const std::string prefix = "file://";
    if (uri.compare(0, prefix.size(), prefix) != 0) return percentDecode(uri);
    std::string path = uri.substr(prefix.size());
    const auto slash = path.find('/');
    if (slash == std::string::npos) return {};
    if (slash > 0) path = path.substr(slash);
    return percentDecode(path);
}

struct Document {
    std::string uri;
    std::string text;
    int version = 0;
};

std::map<std::string, Document> documents;
bool shutdownRequested = false;

void send(const std::string& body) {
    std::cout << "Content-Length: " << body.size() << "\r\n\r\n" << body;
    std::cout.flush();
}

void publish(const Document& document) {
    cwhip::DiagnosticList diagnostics;
    cwhip::checkSource(uriPath(document.uri), document.text, diagnostics);
    std::ostringstream body;
    body << "{\"jsonrpc\":\"2.0\",\"method\":\"textDocument/publishDiagnostics\",\"params\":{"
         << "\"uri\":" << jsonString(document.uri) << ",\"version\":" << document.version
         << ",\"diagnostics\":[";
    bool first = true;
    for (const auto& diagnostic : diagnostics.items()) {
        if (!first) body << ',';
        first = false;
        const int line = diagnostic.location.line > 0
                             ? static_cast<int>(diagnostic.location.line) - 1
                             : 0;
        const int character = diagnostic.location.column > 0
                                  ? static_cast<int>(diagnostic.location.column) - 1
                                  : 0;
        body << "{\"range\":{\"start\":{\"line\":" << line << ",\"character\":" << character
             << "},\"end\":{\"line\":" << line << ",\"character\":" << character
             << "}},\"severity\":1,\"source\":\"cwhip\",\"message\":"
             << jsonString(diagnostic.message) << "}";
    }
    body << "]}}";
    send(body.str());
}

std::optional<std::string> readMessage() {
    std::size_t length = 0;
    std::string line;
    while (std::getline(std::cin, line)) {
        if (!line.empty() && line.back() == '\r') line.pop_back();
        if (line.empty()) break;
        const std::string header = "Content-Length:";
        if (line.compare(0, header.size(), header) == 0) {
            length = static_cast<std::size_t>(std::strtoul(line.c_str() + header.size(), nullptr, 10));
        }
    }
    if (!std::cin || length == 0) return std::nullopt;
    std::string body(length, '\0');
    std::cin.read(body.data(), static_cast<std::streamsize>(length));
    if (static_cast<std::size_t>(std::cin.gcount()) != length) return std::nullopt;
    return body;
}

const Json* documentOf(const Json& message) {
    const Json* params = message.field("params");
    if (params == nullptr) return nullptr;
    return params->field("textDocument");
}

std::string changedText(const Json& message) {
    const Json* params = message.field("params");
    if (params == nullptr) return {};
    const Json* changes = params->field("contentChanges");
    if (changes == nullptr || changes->array.empty()) return {};
    const Json* text = changes->array.back().field("text");
    return text != nullptr && text->kind == Json::Kind::String ? text->text : std::string();
}

int jsonInt(const Json* value, int fallback) {
    if (value == nullptr || value->kind != Json::Kind::Number) return fallback;
    return std::atoi(value->text.c_str());
}

std::string requestId(const Json* id) {
    if (id == nullptr) return "null";
    if (id->kind == Json::Kind::Number) return id->text;
    if (id->kind == Json::Kind::String) return jsonString(id->text);
    return "null";
}

void replyError(const Json* id, int code, const std::string& message) {
    send("{\"jsonrpc\":\"2.0\",\"id\":" + requestId(id) + ",\"error\":{\"code\":" +
         std::to_string(code) + ",\"message\":" + jsonString(message) + "}}");
}

std::string wholeEdit(const std::string& original, const std::string& formatted) {
    if (original == formatted) return "[]";
    int line = 0;
    int character = 0;
    for (char value : original) {
        if (value == '\n') {
            ++line;
            character = 0;
        } else {
            ++character;
        }
    }
    return "[{\"range\":{\"start\":{\"line\":0,\"character\":0},\"end\":{\"line\":" +
           std::to_string(line) + ",\"character\":" + std::to_string(character) +
           "}},\"newText\":" + jsonString(formatted) + "}]";
}

void replyFormatting(const Json& message, bool ranged) {
    const Json* id = message.field("id");
    const Json* document = documentOf(message);
    if (document == nullptr) {
        replyError(id, -32602, "document not open");
        return;
    }
    const std::string uri = document->stringField("uri");
    const auto found = documents.find(uri);
    if (found == documents.end()) {
        replyError(id, -32602, "document not open");
        return;
    }
    cwhip::Style style = cwhip::builtinStyle();
    std::error_code failure;
    const auto directory = std::filesystem::current_path(failure);
    if (!failure) {
        const auto loaded = cwhip::loadStyleAt(directory.string());
        if (!loaded.ok) {
            replyError(id, -32603, loaded.diagnostic);
            return;
        }
        style = loaded.style;
    }
    int firstLine = 0;
    int lastLine = 0;
    if (ranged) {
        const Json* params = message.field("params");
        const Json* range = params == nullptr ? nullptr : params->field("range");
        const Json* start = range == nullptr ? nullptr : range->field("start");
        const Json* end = range == nullptr ? nullptr : range->field("end");
        const int startLine = jsonInt(start == nullptr ? nullptr : start->field("line"), 0);
        const int endLine = jsonInt(end == nullptr ? nullptr : end->field("line"), startLine);
        const int endCharacter = jsonInt(end == nullptr ? nullptr : end->field("character"), 0);
        firstLine = startLine + 1;
        lastLine = endCharacter == 0 && endLine > startLine ? endLine : endLine + 1;
        if (lastLine < firstLine) lastLine = firstLine;
    }
    const auto formatted = cwhip::formatSourceRange(found->second.text, style, uriPath(uri).string(),
                                                    firstLine, lastLine);
    if (!formatted.ok) {
        replyError(id, -32603, formatted.diagnostic);
        return;
    }
    send("{\"jsonrpc\":\"2.0\",\"id\":" + requestId(id) + ",\"result\":" +
         wholeEdit(found->second.text, formatted.text) + "}");
}

void handle(const Json& message) {
    const std::string method = message.stringField("method");
    const Json* id = message.field("id");
    const bool request = id != nullptr && id->kind != Json::Kind::Null;
    if (method == "initialize") {
        send("{\"jsonrpc\":\"2.0\",\"id\":" + (id != nullptr && id->kind == Json::Kind::Number
                                                   ? id->text
                                                   : std::string("null")) +
             ",\"result\":{\"capabilities\":{\"textDocumentSync\":1,"
             "\"documentFormattingProvider\":true,\"documentRangeFormattingProvider\":true}}}");
        return;
    }
    if (method == "shutdown") {
        shutdownRequested = true;
        send("{\"jsonrpc\":\"2.0\",\"id\":" + (id != nullptr && id->kind == Json::Kind::Number
                                                   ? id->text
                                                   : std::string("null")) +
             ",\"result\":null}");
        return;
    }
    if (method == "exit") {
        std::exit(shutdownRequested ? 0 : 1);
    }
    if (method == "initialized" || method == "$/cancelRequest") return;
    if (method == "textDocument/didOpen") {
        const Json* document = documentOf(message);
        if (document != nullptr) {
            Document opened;
            opened.uri = document->stringField("uri");
            opened.text = document->stringField("text");
            const Json* version = document->field("version");
            if (version != nullptr && version->kind == Json::Kind::Number) {
                opened.version = std::atoi(version->text.c_str());
            }
            documents[opened.uri] = opened;
            publish(documents[opened.uri]);
        }
        return;
    }
    if (method == "textDocument/didChange") {
        const Json* document = documentOf(message);
        if (document != nullptr) {
            const std::string uri = document->stringField("uri");
            auto found = documents.find(uri);
            if (found != documents.end()) {
                found->second.text = changedText(message);
                const Json* version = document->field("version");
                if (version != nullptr && version->kind == Json::Kind::Number) {
                    found->second.version = std::atoi(version->text.c_str());
                }
                publish(found->second);
            }
        }
        return;
    }
    if (method == "textDocument/didSave") {
        const Json* document = documentOf(message);
        if (document != nullptr) {
            auto found = documents.find(document->stringField("uri"));
            if (found != documents.end()) {
                const Json* text = document->field("text");
                if (text != nullptr && text->kind == Json::Kind::String) found->second.text = text->text;
                publish(found->second);
            }
        }
        return;
    }
    if (method == "textDocument/didClose") {
        const Json* document = documentOf(message);
        if (document != nullptr) {
            const std::string uri = document->stringField("uri");
            documents.erase(uri);
            send("{\"jsonrpc\":\"2.0\",\"method\":\"textDocument/publishDiagnostics\",\"params\":{"
                 "\"uri\":" + jsonString(uri) + ",\"diagnostics\":[]}}");
        }
        return;
    }
    if (method == "textDocument/formatting" || method == "textDocument/rangeFormatting") {
        if (request) replyFormatting(message, method == "textDocument/rangeFormatting");
        return;
    }
    if (request) {
        send("{\"jsonrpc\":\"2.0\",\"id\":" + requestId(id) +
             ",\"error\":{\"code\":-32601,\"message\":\"method not found\"}}");
    }
}

} // namespace

int main() {
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);
    while (auto message = readMessage()) {
        handle(JsonParser(*message).parse());
    }
    return shutdownRequested ? 0 : 1;
}
