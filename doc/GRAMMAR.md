# Cwhip grammar

This document describes the syntax accepted by the current compiler, not the
larger language proposed in the design notes. The notation below is
ISO-style EBNF: `::=` means “is”, `|` means “or”, `{ X }` means zero or more
repetitions, `[ X ]` means optional, and quoted text is a literal token.
Uppercase names such as `IDENT` and `NEWLINE` are lexical token classes.
Comments in the productions are explanatory, not grammar terminals.

## Lexical grammar

The lexer recognizes ASCII identifiers and keywords, UTF-8 string contents,
and the tokens listed here. Keywords are case-insensitive except that the
exact spelling `String` is an identifier (the builtin class); keyword-like
spellings such as `STRG` are still the `strg` type token. Lowercase `string`
is an ordinary identifier.

```ebnf
LETTER          ::= "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I"
                  | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R"
                  | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z"
                  | "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i"
                  | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r"
                  | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;
DIGIT           ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
IDENT_START     ::= LETTER | "_" ;
IDENT_PART      ::= IDENT_START | DIGIT ;
IDENT           ::= IDENT_START, { IDENT_PART } ;
QUALIFIED_IDENT ::= IDENT, { ".", IDENT } ;

DECIMAL_INTEGER ::= DIGIT, { DIGIT } ;
HEX_DIGIT       ::= DIGIT | "a" | "b" | "c" | "d" | "e" | "f"
                  | "A" | "B" | "C" | "D" | "E" | "F" ;
HEX_INTEGER     ::= ("0x" | "0X"), HEX_DIGIT, { HEX_DIGIT } ;
INTEGER         ::= DECIMAL_INTEGER | HEX_INTEGER ;
UNSIGNED_INT    ::= INTEGER, ("u" | "U") ;
EXPONENT        ::= ("e" | "E"), [ "+" | "-" ], DIGIT, { DIGIT } ;
FLOAT           ::= ( DIGIT, { DIGIT }, ".", { DIGIT }, [ EXPONENT ]
                  | ".", DIGIT, { DIGIT }, [ EXPONENT ]
                  | DIGIT, { DIGIT }, EXPONENT ), [ "f64" ] ;

DOUBLE_STRING   ::= '"', { DOUBLE_CHAR | ESCAPE }, '"' ;
SINGLE_STRING   ::= "'", { SINGLE_CHAR }, "'" ;
ESCAPE          ::= "\", ("e" | "n" | "r" | "t" | "\" | '"') ;
DOUBLE_CHAR     ::= any valid UTF-8 character except '"', "\", CR, or LF ;
SINGLE_CHAR     ::= any valid UTF-8 character except "'", CR, or LF ;
STRING          ::= DOUBLE_STRING | SINGLE_STRING ;

COMMENT         ::= LINE_COMMENT | BLOCK_COMMENT ;
LINE_COMMENT    ::= "#" , { any character except LF }
                  | "//", { any character except LF } ;
BLOCK_COMMENT   ::= "/*", { any character or LF except the first "*/" }, "*/" ;
HORIZONTAL_WS   ::= one or more non-LF characters for which the C++ runtime
                    classifies `isspace` as true ;
NEWLINE         ::= LF ;

PUNCTUATION     ::= "{" | "}" | "(" | ")" | "[" | "]" | "," | "." | ":" ;
OPERATOR        ::= "+=" | "-=" | "*=" | "/=" | "%="
                  | "&=" | "|=" | "^=" | "<<=" | ">>="
                  | "+" | "-" | "*" | "/" | "%" | "!" | "&&" | "||"
                  | "&" | "|" | "^" | "~" | "<<" | ">>" | ".."
                  | "=" | "==" | "!=" | "<" | "<=" | ">" | ">=" ;
```

The reserved words include `start`, `bool`, `int`, `uint`, `float`, `int8`,
`uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `fp32`,
`fp64`, `strg`, `list`, `dict`, `buffer`, `handle`, `range`, `any`, `type`, `class`,
`namespace`, `include`, `inline`, `import`, `as`, `public`, `protected`,
`private`, `const`, `virtual`, `super`, `null`, `true`, `false`, `return`,
`void`, `if`, `else`, `while`, `do`, `for`, `in`, `is`, `break`, `continue`,
`and`, `or`, `not`, `print`, `raise`, `try`, `except`, `finally`, `from`,
`switch`, `case`, and `default`.
`next` is a case-insensitive contextual keyword only as a standalone statement;
it remains an identifier in declarations, expressions, and member access.
`int`, `uint`, and `float` are native-width aliases for `int32`, `uint32`, and
`fp32`. `unsigned` remains reserved and produces a migration diagnostic
recommending `uint64`. `callback` is an ordinary identifier.
The LLVM backend lowers each numeric type at its declared width, with
catchable checked integer arithmetic and IEEE floating execution.

Integer literals are classified semantically: unsuffixed literals select the
smallest fitting signed type, while `u`/`U` select the smallest fitting
unsigned type. Hexadecimal digits are case-insensitive. Signs are unary
operators; a directly negated literal may represent the signed minimum.
Magnitudes outside the 64-bit range are rejected. Floating literals default
to `fp32`; `f64` explicitly selects `fp64`. Unsuffixed values that overflow or
underflow `fp32` fall back to `fp64`, and values outside finite `fp64` range
are rejected.

Lexical details that affect parsing:

- A leading `+` or `-` is an operator, not part of a number. Integer widths
  are inferred as described above; values outside the selected 64-bit range
  are rejected. Floats accept leading-dot (`.5`),
  trailing-dot (`5.`), and exponent forms (`1e3`, `1.0E-3`); an exponent must
  contain digits. `..` is a separate range token: `1..20` is an integer,
  range token, and integer, not two floating literals. This does not change
  `.5`, `5.`, or `1.e2` floating literals.
- Only double-quoted strings interpret escapes: `\e` produces ESC (`0x1b`),
  and `\n`, `\r`, `\t`, `\\`, and `\"` are also accepted. Single-quoted
  strings preserve backslashes literally. Both quote styles are one physical
  line and must decode to valid
  UTF-8. Neither quote style interpolates automatically; literal templates
  are interpreted only by `format` or multi-argument `print`.
- `#` and `//` begin line comments. `/* ... */` comments are non-nesting.
  Newline characters inside a block comment still delimit statements outside
  parentheses and brackets. `;` is an unknown character, not a comment or
  statement separator.
- LF produces a `NEWLINE` token except while inside parentheses or square
  brackets. Newlines inside braces are not suppressed. Other whitespace is
  discarded. There is no indentation-based syntax.
- Integer bitwise operators are `&`, `|`, `^`, `~`, `<<`, and `>>`.
  Compound assignment supports arithmetic, binary bitwise, and shift forms.
  There are no increment or conditional (`?:`) operators.
- After `inline` and an optional capture list, the lexer consumes the next
  balanced-brace block as one opaque `INLINE_BODY` token. Braces inside C
  strings and C comments do not change its brace depth.
- `INLINE_BODY` is a lexer-only token: its contents are C source rather than
  Cwhip tokens, so it has no ordinary Cwhip lexical production.

## Syntactic grammar

`include` is handled by the source loader before the parser runs; it is shown
below as source-level syntax, not as a declaration accepted by
`Parser::parseProgram`. `EOF` is the lexer end token. `terminator` reflects
the parser's newline rule, including its allowance for a closing brace or
end-of-file in place of a final newline.

### Compilation units and declarations

```ebnf
program             ::= { NEWLINE }, { top-level-item, { NEWLINE } },
                        start-block, { NEWLINE }, EOF ;
module              ::= { NEWLINE }, { module-item, { NEWLINE } }, EOF ;

top-level-item      ::= import-declaration
                      | class-declaration
                      | namespace-declaration
                      | out-of-line-definition ;
module-item         ::= import-declaration
                      | class-declaration
                      | namespace-declaration
                      | out-of-line-definition ;

start-block         ::= "start", { NEWLINE }, block ;
import-declaration  ::= "import", IDENT, [ "as", IDENT ], terminator ;
namespace-declaration
                    ::= "namespace", IDENT, { NEWLINE }, "{",
                        { NEWLINE },
                        { namespace-item, { NEWLINE } },
                        "}" ;
namespace-item      ::= namespace-declaration
                      | class-declaration
                      | out-of-line-definition ;

class-declaration   ::= "class", IDENT, [ ":", base-specifier,
                        { ",", base-specifier } ], "{",
                        { NEWLINE }, { class-member, { NEWLINE } }, "}" ;
base-specifier      ::= { base-modifier }, QUALIFIED_IDENT ;
base-modifier       ::= "public" | "protected" | "private" | "virtual" ;

class-member        ::= access-section
                      | field-declaration
                      | anonymous-enum-declaration
                      | constructor-declaration
                      | destructor-declaration
                      | method-declaration ;
access-section      ::= ("public" | "protected" | "private"), ":", { NEWLINE } ;
field-declaration   ::= type, IDENT, [ "=", expression ], terminator ;
anonymous-enum-declaration
                    ::= "enum", "{", { NEWLINE },
                        [ enum-member,
                          { (",", { NEWLINE } | NEWLINE), enum-member },
                          [ "," ], { NEWLINE } ],
                        "}" ;
enum-member         ::= IDENT, [ "=", expression ] ;
constructor-declaration
                    ::= IDENT, parameter-list, method-tail ;
destructor-declaration
                    ::= "destroy", block ;
method-declaration  ::= type, IDENT, parameter-list, method-tail ;
method-tail         ::= block | terminator ;

out-of-line-definition
                    ::= return-type, QUALIFIED_IDENT, ".", IDENT,
                        parameter-list,
                        ( "from", STRING, terminator | block ) ;
return-type         ::= type | "void" ;
parameter-list      ::= "(", [ parameter, { ",", parameter } ], ")" ;
parameter           ::= type, IDENT ;
type                ::= type-atom, { callable-parameters } ;
type-atom           ::= primitive-type | QUALIFIED_IDENT | range-type | "void" ;
range-type          ::= "range", "<", range-element-type, ">" ;
range-element-type  ::= integer-type-name ;
callable-parameters ::= "<", [ type, { ",", type } ], ">" ;
primitive-type      ::= numeric-type-name | "bool" | "strg"
                      | "list" | "dict" | "buffer"
                      | "handle" | "any" | "type" ;
numeric-type-name   ::= "int8" | "uint8" | "int16" | "uint16"
                      | "int32" | "uint32" | "int64" | "uint64"
                      | "fp32" | "fp64" | "int" | "uint" | "float" ;
integer-type-name   ::= "int8" | "uint8" | "int16" | "uint16"
                      | "int32" | "uint32" | "int64" | "uint64"
                      | "int" | "uint" ;

include-directive   ::= "include", DOUBLE_STRING, terminator ;
```

`destroy` is an in-class declaration form, not a general method signature: it
must be followed by a block and has no return type or parameter list.
Destructors cannot be declared without a body or defined out of line.
Callable signatures use `R<P1,P2>`; zero arguments use `R<>`. The return type
and each parameter are recursive types, so `int64<int64><String>` returns a
callable taking `String` whose result is `int64<int64>`. `range<T>` remains the
special one-argument range type and can itself be a callable result or parameter.
`void<>` is valid, but `void` is not a callable parameter. A member expression
without invocation parentheses captures an instance method when it resolves to
a method rather than a field; the expected callable type resolves overloads.
A call's callee may also be a typed callable value. See
[CALLBACKS.md](CALLBACKS.md) for semantic restrictions and the native ABI.
`enum` is contextual to the class-member production above; it does not
introduce a named enum type or a top-level declaration.

The source loader accepts `include-directive` only at brace depth zero and
before the root `start`; it searches the including file's directory before
configured include paths, expands each canonical file once, and rejects
`start` inside included text. Imports are parsed but resolved through the
module/package registry during compilation. Without an alias the binding uses
the manifest's declared export name. An explicit import alias denotes the
exported namespace itself; it does not add a package-name prefix to exported
class names (for example, `import time as T` exposes `T.Clock`). Imported
module files use `module`, which does not permit a `start` block.

### Statements

```ebnf
block               ::= "{", { NEWLINE }, { statement, { NEWLINE } }, "}" ;
statement           ::= declaration
                      | assignment
                      | method-call-statement
                      | print-statement
                      | if-statement
                      | switch-statement
                      | next-statement
                      | while-statement
                      | do-while-statement
                      | foreach-statement
                      | loop-control
                      | return-statement
                      | try-statement
                      | raise-statement
                      | super-initializer
                      | inline-c-statement
                      | block ;

declaration         ::= [ "const" ], type, IDENT,
                        [ "=", expression
                        | direct-constructor-arguments ],
                        terminator
                      | [ "const" ], type, IDENT, inline-c-statement ;
direct-constructor-arguments
                    ::= "(", [ expression, { ",", expression } ], ")" ;
assignment          ::= expression, assignment-operator, expression, terminator ;
assignment-operator ::= "=" | "+=" | "-=" | "*=" | "/=" | "%="
                      | "&=" | "|=" | "^=" | "<<=" | ">>=" ;
method-call-statement
                    ::= expression, terminator ;
print-statement     ::= "print", "(", [ expression
                         | STRING, ",", format-argument-list ], ")", terminator ;
if-statement        ::= "if", "(", expression, ")", { NEWLINE }, block,
                        { { NEWLINE }, conditional-else-clause },
                        [ { NEWLINE }, "else", { NEWLINE }, block ] ;
conditional-else-clause
                    ::= "else", "(", expression, ")",
                        { NEWLINE }, block ;
switch-statement    ::= "switch", "(", expression, ")", { NEWLINE }, "{",
                        { NEWLINE }, { case-branch, { NEWLINE } },
                        [ default-branch, { NEWLINE } ], "}" ;
case-branch         ::= "case", "(", case-label, { ",", case-label }, ")",
                        { NEWLINE }, block ;
case-label          ::= expression ;
default-branch      ::= "default", { NEWLINE }, block ;
next-statement      ::= "next", terminator ;
while-statement     ::= "while", "(", expression, ")", { NEWLINE }, block ;
do-while-statement  ::= "do", { NEWLINE }, block, { NEWLINE },
                        "while", "(", expression, ")" ;
foreach-statement   ::= "for", "(", IDENT, [ ",", IDENT ], "in",
                        expression, ")", { NEWLINE }, block ;
loop-control        ::= ("break" | "continue"), terminator ;
return-statement    ::= "return", [ "(", [ expression ], ")" ], terminator ;
                        (* in start: expression must be an integer; it is the
                           process exit status, and a bare return exits 0 *)
raise-statement     ::= "raise", [ "(", [ expression ], ")" ], terminator ;
try-statement       ::= "try", { NEWLINE }, block, { NEWLINE },
                        ( except-clause, { NEWLINE },
                          { except-clause, { NEWLINE } },
                          [ "finally", { NEWLINE }, block, { NEWLINE } ]
                        | "finally", { NEWLINE }, block, { NEWLINE } ) ;
except-clause       ::= "except", "(", [ QUALIFIED_IDENT ], ")",
                        [ "as", IDENT ], { NEWLINE }, block ;
super-initializer   ::= ( "super", [ "virtual" ] | "virtual", "super" ), IDENT,
                        "(", [ expression, { ",", expression } ], ")",
                        terminator ;
inline-c-statement  ::= "inline", [ capture-list ], INLINE_BODY, terminator ;
capture-list        ::= "(", [ capture, { ",", capture } ], ")" ;
capture             ::= capture-type, [ "." ], IDENT, { ".", IDENT } ;
capture-type        ::= type | "void" ;
terminator          ::= NEWLINE, { NEWLINE } | ε ;
```

`terminator ::= ε` is valid only immediately before `}` or `EOF`; it does not
allow adjacent simple statements on the same line. The declaration form that
places `inline` after a type and identifier declares that local and adds it
as an implicit capture. An initializer on that form is rejected.
A leading `const` is accepted only on a local declaration. It is not part of
a field, parameter, or method declaration. The local may omit its initializer.
The first store gives it a value; a later store, including a compound
assignment, raises a catchable exception. See
[Variables and scope](LANGUAGE-REFERENCE.md#variables-and-scope). An `inline`
capture of a `const` local is rejected during semantic analysis.
An unqualified capture resolves a local/parameter before an instance field.
Leading `.` selects the implicit receiver explicitly; other dotted capture
paths must resolve through that receiver's base classes. Only the final
identifier names the C parameter; final names must be unique within a list.
Field captures obey normal access, ambiguity, and exact-type checks and
require an instance context.
`direct-constructor-arguments` is accepted only when `type` is a class name
(a `QUALIFIED_IDENT`), not a built-in type such as `int8`, `strg`, or `buffer`.
It constructs the declared class directly; it does not declare a function.
Class fields accept `= expression` only for compile-time constant initializers;
runtime expressions and direct-constructor arguments are not accepted there.
See [compile-time field initializers](LANGUAGE-REFERENCE.md#compile-time-field-initializers).

Conditional `else (expression)` clauses lower to nested `if` statements in the
preceding branch's alternate block, so conditions are evaluated lazily in order
and at most one body executes. A bare `else` must be last. Every clause requires
a block; `else if` and `else ()` are not accepted. Newlines may separate `}` from
`else` or a condition from its block, but not `else` from its opening `(`.

A switch selector must be integral (`int8` through `uint64`, including class
enum constants, which have type `int64`). Labels and inclusive range endpoints
must be compile-time integer expressions. The evaluated value must fit the
selector type exactly; implicit conversion never truncates or wraps a label.
Existing explicit casts and constant arithmetic retain their numeric semantics.
Endpoint order does not matter: `1..3` and `3..1` both match 1, 2, and 3.
Groups such as `case (1..3, 5..8)` may mix ascending and descending ranges
and discrete alternatives. Duplicate/overlapping labels are errors after
endpoint normalization, including overlaps between signed and unsigned
spellings of the same value. There is at most one
`default`, and it must be last. Empty switches are allowed.

The selector is evaluated once. A matching branch executes in its own scope
and normally exits the switch; unmatched selectors execute `default`, if any.
`next` must be the final direct statement of a branch that has a following
branch. It executes that following body unconditionally, without testing its
labels, after normal branch cleanup. Nested or conditional `next` is rejected.
Branches block `break`/`continue` from targeting an outer loop; loops introduced
inside a branch retain their own loop transfers. `return` still exits the
enclosing method (or, inside `start`, the program) and runs its usual cleanup.

### Expressions

The first table gives the exact recursive-descent levels from lowest to
highest binding strength. The loop-based levels associate left-to-right;
unary operators associate right-to-left.

| Precedence | Operators / form | Associativity |
|---:|---|---|
| 1 | `or`, `\|\|` | left |
| 2 | `and`, `&&` | left |
| 3 | `not`, `!` | right (prefix) |
| 4 | `==`, `!=` | left |
| 5 | `is`, `in`, `<`, `<=`, `>`, `>=` | left |
| 6 | `..` | non-associative |
| 7 | `\|` | left |
| 8 | `^` | left |
| 9 | `&` | left |
| 10 | `<<`, `>>` | left |
| 11 | `+`, `-` | left |
| 12 | `*`, `/`, `%` | left |
| 13 | unary `+`, unary `-`, `~` | right (prefix) |
| 14 | member access, calls, indexing, slicing, `as` checked extraction | repeated left-to-right |

`is` consumes a type name rather than a right-hand expression. Equality
operators bind less tightly than `is` and relational operators because that
is how `parseComparison` and `parseRelational` are layered. Assignment is a
statement, not an expression.

```ebnf
expression          ::= or-expression ;
or-expression       ::= and-expression, { ("or" | "||"), and-expression } ;
and-expression      ::= not-expression, { ("and" | "&&"), not-expression } ;
not-expression      ::= ("not" | "!"), not-expression | comparison ;
bitwise-or          ::= bitwise-xor, { "|", bitwise-xor } ;
bitwise-xor         ::= bitwise-and, { "^", bitwise-and } ;
bitwise-and         ::= shift, { "&", shift } ;
comparison          ::= relational, { ("==" | "!="), relational } ;
relational          ::= range-expression,
                        { ("is", type-test-name | "in", range-expression
                          | "<", range-expression | "<=", range-expression
                          | ">", range-expression | ">=", range-expression) } ;
range-expression    ::= bitwise-or, [ "..", bitwise-or ] ;
shift               ::= addition, { ("<<" | ">>"), addition } ;
type-test-name      ::= QUALIFIED_IDENT | primitive-type | range-type | "void" ;
addition            ::= multiplication, { ("+" | "-"), multiplication } ;
multiplication      ::= unary, { ("*" | "/" | "%"), unary } ;
unary               ::= ("+" | "-" | "~"), unary | postfix ;

postfix             ::= primary, { member-suffix | index-or-slice-suffix
                                  | call-suffix | object-cast-suffix } ;
object-cast-suffix  ::= "as", cast-target ;
cast-target         ::= QUALIFIED_IDENT | primitive-type | range-type | "void" | "null" ;
member-suffix       ::= ".", IDENT ;
index-or-slice-suffix
                    ::= "[", expression, [ ":", [ expression ],
                        [ ":", [ expression ] ] ], "]"
                      | "[", ":", [ expression ], [ ":", [ expression ] ], "]" ;
call-suffix         ::= "(", [ argument-list ], ")" ;
format-expression   ::= "format", "(", STRING, [ ",", format-argument-list ], ")" ;
format-argument-list
                    ::= argument-list
                      | named-format-argument,
                         { ",", named-format-argument } ;
named-format-argument
                    ::= IDENT, "=", expression ;
argument-list       ::= expression, { ",", expression } ;

primary             ::= INTEGER | UNSIGNED_INT | FLOAT | STRING
                      | format-expression
                      | "true" | "false" | "null" | IDENT
                      | "type", "(", expression, ")"
                      | "bool", "(", expression, ")"
                      | numeric-type-name, "(", expression, ")"
                      | "buffer", "(", [ expression, { ",", expression } ], ")"
                      | buffer-literal
                      | "(", expression, ")"
                      | list-literal | dict-literal | type-value ;
buffer-literal      ::= "buffer", "[", [ argument-list ], "]" ;
list-literal        ::= "[", [ expression, { ",", expression }, [ "," ] ], "]" ;
dict-literal        ::= "[", ":", "]"
                      | "[", dict-entry, { ",", dict-entry }, [ "," ], "]" ;
dict-entry          ::= expression, ":", expression ;
type-value          ::= "strg" | "list" | "dict"
                      | "handle" | "any" | range-type
                      | "bool" | numeric-type-name (* only when not followed by "(" *)
                      | "buffer"                      (* only when not followed by "(" or "[" *) ;
```

`range-type` accepts only the eight integer types semantically, not `fp32` or
`fp64`. `first..last` forms an immutable, inclusive, directional integer value
with snapshot endpoints. `..` binds more tightly than `in` and comparisons,
but less tightly than bitwise operators, shifts, and arithmetic. Parenthesize
bitwise endpoint expressions. Chained ranges (`1..2..3`) and range-valued
endpoints are invalid.
`value in bounds` accepts an integer and a range; `for (value in bounds)`
binds a read-only integer. `collection[bounds]` is a copy slice when the index
expression has a range type, for lists, Strings, and buffers only; its endpoints
are strict inclusive indices. `text[index]` reads one String byte as `uint8`,
and assigning that index replaces one ASCII byte. Colon slices on lists,
buffers, and dicts remain half-open and clamped. String has no colon slice.
Switch case-label expressions are restricted to compile-time integer
values or a top-level range of compile-time integer endpoints; stored ranges
and runtime endpoints remain forbidden there.
Endpoint expressions run exactly once, left to right. Every formed interval
is nonempty; guard zero-count index traversal. Endpoint types must have a
lossless common integer type. Negative slice indices retain their ordinary
length-relative meaning, and String slices select bytes whose result must be
valid UTF-8. Null range consumers and invalid slice bounds throw catchable
exceptions. See [the range contract](LANGUAGE-REFERENCE.md#integer-ranges) and
[runnable examples](EXAMPLES.md#switches-and-integer-ranges).

The `postfix` shorthand accepts a call suffix after any value expression.
An identifier call is initially parsed as construction and resolves instead
to invocation when it names a callback variable or field. A member call
resolves to a method call or callback-field invocation. A returned callback
can be invoked directly, as in `object.capture()(argument)`; attempting to
call any non-callable value is diagnosed.
An `as` suffix accepts a supported non-void target and a value with a valid
checked-extraction source type. It binds at postfix precedence and can be
repeated.
Parenthesize the cast before member access, as in
`(items[index] as model.Foo).method()`, because dotted names after `as` are
parsed as qualified class names. Numeric conversions use the numeric type-name
call forms; `Foo(value)` constructs a class unless
`Foo` resolves to a callback value.
Name resolution may recognize a dotted qualified class construction. A
member expression such as `Base.field` or `Left.Root.method(args)` inside a
class method, constructor, or destructor may instead receive an implicit
current-object receiver when its initial class name denotes a direct base.
The remaining qualifiers must follow successive direct-base edges, as with
explicit `object.Left.Root.field` access. This is semantic resolution of the
existing postfix grammar, not static member syntax or a new parser production.
Anonymous enum constants also support `Class.NAME` and `object.NAME`;
class-qualified constant reads are not static fields or static method calls.
Local/parameter and field receiver names take precedence over implicit base
qualification; namespace/import class lookup otherwise follows ordinary
lexical rules. Type-valued name resolution is unchanged. A
`method-call-statement` must resolve to a method- or callback-call AST node; a bare
constructor call is not accepted as a statement. Identifier- and
parenthesis-started expressions are routed through statement parsing;
parenthesized receivers such as `(items[0] as Foo).method()` are valid
standalone calls, including calls returning `void`. Parenthesizing a noncall
does not make it a valid expression statement. Declaration and assignment
recognition still applies before the method-call-only check.
Member, index, and callable invocation suffixes may follow a call.
The `format` expression requires a literal template,
returns `strg`, and accepts either
positional expressions or named `IDENT=expression` arguments, never both.
Positional `{}` placeholders match positional arguments in order. Named
`{IDENT}` placeholders match named arguments by case-sensitive name; every
distinct placeholder name must have exactly one argument, and every argument
must be used. A named placeholder may appear more than once and reuses its
argument value. `{{` and `}}` produce literal braces; unmatched braces and
malformed placeholder names are compile-time errors. Fields may include
`:` followed by `[alignment][width][type]`, where alignment is `<`, `>`, or `^`,
width is decimal digits (maximum 1000000), and type is `d`, `x`, `X`, or `c`.
A leading-zero width requests integral zero padding; explicit alignment and
`c` cannot combine with it. See the language reference for type, ASCII,
padding, and exception rules. Validation happens only in `format` or
multi-argument `print`. String-literal calls are rejected.
Indexing and slicing bind as postfix forms. `type` always
starts `type(expression)`; it is not a standalone type-value expression.

## Parser coverage map

Each parser routine has a corresponding production or grammar note above:

| Parser routine | Production(s) / role |
|---|---|
| `parseProgram`, `parseModule` | `program`, `module`; exactly one `start` only in a program |
| `parseImport`, `parseQualifiedIdentifier`, `parseNamespace` | `import-declaration`, `QUALIFIED_IDENT`, `namespace-declaration` |
| `parseBlock`, `parseStatement` | `block`, `statement` |
| `parseInlineC`, `parseDeclaration`, `parseExpressionStatement` | `inline-c-statement`, `declaration`, `assignment`, `method-call-statement` |
| `parseReturn`, `parseSuperConstructorCall`, `parsePrint` | `return-statement`, `super-initializer`, `print-statement` |
| `parseIf`, `parseWhile`, `parseDoWhile`, `parseForEach`, `parseLoopControl` | matching statement productions |
| `parseRaise`, `parseTry` | `raise-statement`, `try-statement` |
| Expression-precedence routines | `expression` through `postfix`; see the precedence table and productions |
| `parseTypeTestName`, `parsePrimary`, `parseTypeName`, `parsePostfix` | `type-test-name`, `primary`, type-value primary, and postfix productions |
| `startsOutOfLineDefinition` | top-level lookahead for `out-of-line-definition`; not a separate syntax form |
| `parseClass`, `parseEnumMembers`, `parseOutOfLineMethodDefinition`, `parseType`, `parseParameters`, `parseMethod` | class/member/declaration productions, including `anonymous-enum-declaration` |
| `Parser` constructor, `current`, `previous`, `check`, `match`, `error` | token-stream setup/access, predicates, cursor movement, and diagnostics; these do not add productions |
| `skipNewlines`, `consumeStatementTerminator`, `consume`, `parseFormatArguments`, `validateFormatString`, `trace` | lexical/newline policy, `terminator`, positional/named format arguments and validation, and tracing |

The map covers syntax-producing methods in `Parser.cpp` and `ParserClass.cpp`
and identifies parser infrastructure and validation helpers. The
`tests/functional/positive/*.cw` fixtures
exercise scalar and float literal variants, declarations and assignments,
calls and overloads, casts and type tests, lists/dicts/buffers/handles,
indexing/slicing/iteration, conditionals and loops, classes and inheritance
(including anonymous enums, virtual and secondary bases), exceptions,
namespaces, imports, textual inclusion, native bindings, inline C, strings,
and thread bindings.
`include-directive` case is the only construct expanded before parsing.

## Notes and known irregularities

- Keywords are case-folded, but ordinary identifiers are case-sensitive.
  `String` is an identifier naming the builtin class, `strg` is the primitive
  string type keyword, and lowercase `string` is an ordinary identifier.
- `array` and `map` are ordinary identifiers, not collection type aliases.
- Newline suppression tracks both `()` and `[]` with one nesting counter. A
  mismatched closer can therefore affect whether later newlines are emitted;
  syntax diagnostics, not the lexer, report unmatched delimiters.
- Base modifiers may appear in any order and repeated access modifiers use
  the last one; repeating `virtual` is a parse error. Class member access
  begins as public and changes only at an access section.
- Conditional `else (expression)` clauses may be chained before one optional
  final bare `else`; conditions are tested in order and only the first matching
  branch runs. `else if` is not supported. `do { ... } while (...)` has no
  required trailing terminator.
- Newlines in `()` and `[]` are suppressed, but newlines inside `{}` are not.
  List and dict literals both use square brackets and can span lines.
- Non-void returns use `return(expression)`. Bare `return` and `return()` are
  valid void returns. A raise expression uses `raise(expression)`; bare
  `raise` and `raise()` both rethrow the active exception.
- `format` is recognized as an intrinsic in call position. `print` formats
  only when its literal first argument has additional arguments; otherwise
  a directly printed literal, including braces, is unchanged.
- A base initializer is spelled `super Base(args)`. A virtual-base initializer
  accepts either `super virtual Base(args)` or `virtual super Base(args)`;
  dotted forms are not part of the grammar.
  A constructor's leading initializer sequence may be enclosed in one ordinary
  `try-statement`. Its body must contain only ordered `super-initializer`
  statements, with no branches, loops, nested blocks, or ordinary statements.
  Required direct initializers must all be inside that sequence. Handlers must
  raise/rethrow on every path and contain no return; optional `finally` follows
  ordinary cleanup rules. No initializer is allowed in a handler or `finally`,
  after this leading try, or in a mixed direct/protected sequence. These are
  semantic constraints, not new parser productions.
- The parser allows some forms that later fail semantic analysis: for example
  `return` in `start` or within `finally` (including nested blocks),
  `break` outside a loop, invalid lvalues, inaccessible
  members, unknown types, bad argument/return conversions, an invalid
  `super` initializer, or a `raise` expression outside the exception class
  hierarchy. Constructor declarations must use their enclosing class name and omit a
  return type; a class-body `method-declaration` whose `IDENT` is the
  enclosing class name (for example `void Name()`) is a parser error;
  destructor parameters are rejected; native-bound constructors are rejected;
  and constructor/destructor placement and leading base-initializer rules are
  semantic checks.
- `void` is allowed by the type parser only where requested for a method
  return or inline-C capture syntax; fields, parameters, and locals do not
  have a meaningful `void` type. (Inline-C capture validation rejects it.)
- Direct identifier calls are constructed as constructor calls by the parser;
  dotted class names can be reclassified after semantic name resolution.
  There are no free-function declarations or arbitrary first-class callable
  expressions in the accepted subset.
- The grammar allows list literals to contain buffers and handles, while the
  semantic check for `list.append(...)` accepts a narrower list of element
  types. The syntax is shared, but those two construction routes are not
  type-equivalent in every case.
