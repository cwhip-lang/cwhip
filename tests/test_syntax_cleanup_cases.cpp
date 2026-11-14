#include "test_cases.hpp"

#include "cwhip/Lexer.hpp"
#include "cwhip/Parser.hpp"

namespace cwhip_test {
namespace {

cwhip::Program syntax(const std::string& source) {
    return cwhip::Parser(cwhip::Lexer(source, "syntax.cw").tokenize()).parseProgram();
}

void precedence() {
    const auto program = syntax(R"(start {
    print(8 >> 1 & 3 ^ 2 | 1 == 3)
    print(1 | 2 < 4)
    print(!1 & 2 == 0)
    print(not 1 == 2 and true || false or true && false)
})");
    const auto& equality = *program.statements.front().expressions.front();
    require(equality.value == "==", "comparison must bind below bitwise operators");
    const auto& bitOr = *equality.left;
    require(bitOr.value == "|" && bitOr.left->value == "^" &&
                bitOr.left->left->value == "&" &&
                bitOr.left->left->left->value == ">>",
            "bitwise precedence must be shifts, &, ^, |");
    const auto& relational = *program.statements[1].expressions.front();
    require(relational.value == "<" && relational.left->value == "|",
            "relational operators must bind below bitwise operators");
    const auto& negated = *program.statements[2].expressions.front();
    require(negated.value == "!" && negated.left->value == "==" &&
                negated.left->left->value == "&",
            "! must retain Python not precedence");
    expectValid(R"(start {
    bool result = not 1 == 2 and true || false or true && false
    bool bits = 8 >> 1 & 3 ^ 2 | 1 == 3
    print(result)
    print(bits)
})");
}

void collections() {
    expectValid(R"(start {
    list values = [
        1 +
        2, # continuation in a literal
        4,
    ]
    dict entries = [
        "a": values,
        "b": [
            7, /* multiline
                  comment */ 8,
        ],
    ]
    dict empty = [
        :
    ]
    list none = []
    list nested = entries["a"]
    print(nested[0])
    print(empty.length)
    print(none.length)
})");
    const auto program = syntax(R"(start {
    print([:])
    print([])
    print(["key": [1, 2,],])
})");
    require(program.statements[0].expressions[0]->kind == cwhip::ExpressionKind::MapLiteral,
            "[:] must be a dict literal");
    require(program.statements[1].expressions[0]->kind == cwhip::ExpressionKind::ArrayLiteral,
            "[] must remain an empty list");
    require(program.statements[2].expressions[0]->arguments.size() == 2,
            "dictionary arguments must be key/value pairs");
    expectDiagnostic("start { dict d = {} }", "dict literals now use [k: v]");
    expectDiagnostic("start { dict d = {\"k\": 1} }", "dict literals now use [k: v]");
    expectDiagnostic("start { list l = [1, 2: 3] }",
                     "cannot mix list elements and dict entries");
    expectDiagnostic("start { dict d = [1: 2, 3] }",
                     "cannot mix list elements and dict entries");
    expectDiagnostic("start { dict d = [:,] }", "expected ']' after list elements or dict entries");
}

void returnsAndRaises() {
    expectValid(R"(class Values {
    public:
    int32 get() { return(1 + 2) }
    void empty() { return() }
    void bare() { return }
}
start {
    Values value()
    print(value.get())
})");
    expectDiagnostic("class X { public: int32 get() { return 1 } }\nstart {}",
                     "return value must be parenthesized: return(expr)");
    expectDiagnostic("class X { public: int32 get() { return(1) + 2 } }\nstart {}",
                     "return value must be parenthesized: return(expr)");
    expectDiagnostic("start { raise 1 }",
                     "raise arguments must be parenthesized: raise(expr)");
    const auto program = syntax("start { raise(1)\nraise() }");
    require(program.statements[0].expressions.size() == 1 &&
                program.statements[1].rethrowsException,
            "raise(expr) and raise() syntax must remain distinct");
}

void commentsAndKeywords() {
    expectValid(R"(# leading hash comment
StArT { // C++ comment
    int32 value = 1 /* C comment */
    print(value) # trailing hash comment
    print("# ; // /* are string contents")
})");
    expectDiagnostic("start { ; old comment\n}", "unknown character ';'");
    expectDiagnostic("start { int32 n = 1; ignored\n}",
                     "';' is not a comment; use '#' or '//'");
    expectDiagnostic("start { int32 While = 1 }", "found 'while'");
    const auto tokens = cwhip::Lexer("AnD && Or || NoT ! WhIlE", "keywords.cw").tokenize();
    require(tokens[0].type == cwhip::TokenType::And &&
                tokens[1].type == cwhip::TokenType::AndAnd &&
                tokens[2].type == cwhip::TokenType::Or &&
                tokens[3].type == cwhip::TokenType::OrOr &&
                tokens[4].type == cwhip::TokenType::Bang &&
                tokens[5].type == cwhip::TokenType::Bang &&
                tokens[6].type == cwhip::TokenType::While,
            "case-insensitive keywords and dual logical spellings must be retained");
}

const TestGroupRegistration registration(130, {
    {"syntax cleanup precedence", precedence},
    {"syntax cleanup collection literals", collections},
    {"syntax cleanup return and raise migration diagnostics", returnsAndRaises},
    {"syntax cleanup comments and reserved keywords", commentsAndKeywords},
});

} // namespace
} // namespace cwhip_test
