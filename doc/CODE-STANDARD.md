# CWHIP Coding standard

This document is intended to be used by programmers writing code in the Cwhip programming language. This is a subset of the guidelines that is used by the AI that generated much of the proof of concept code that is located in this repository and others. 

## General guidelines

- Prefer to define class methods outside of the class body. This keeps the definition of the class small and readable.
- Always use a new line after a **{** and before a **}**. Including one line code blocks. This helps to visually define code blocks.
- Indents are 4 spaces. Continuations are allowed inside **[]** and **()** and indent is 8 spaces past the normal indent. A long call or dict breaks after `(` or `[`, one item per line, including a call or dict on the right of `=`. A long out-of-line method breaks before `from` at the block indent. A generic and a class base list stay on one line.
- One space around `=` and around binary operators. Unary `+`, `-`, `!`, and `~` stay tight. `not` has one space after it. `..` stays tight. One space after a comma, none before. No space inside `()`, `[]`, or `<>`. One space before `{` when it shares the line.
- A comment-only line, `case`, `default`, a `{` on its own line, and `except`, `finally`, and `from` when they start a line use the block indent.
- Line length should be kept to less than 80 characters to allow clean editing on a console.

## Naming

- **Classes:** CamelCase, first letter capital.
- **Methods:** lowercase `with_under_score`.
- **Variables:** camelCase, first letter lower.
- **Enums:** `ALL_CAPS` with underscores — symbolic names for `int64`
  literals. Prefer enum/names over magic number literals.
- **Dict keys** are strings. The runtime implements **dict** as a simple hash table.

## Visibility / ownership

- Default visibility was intended private, but hiding data is seldom
  required — do **not** treat encapsulation as mandatory secrecy.
- Data allocated by an object (for example file handles) is **owned**
  by that object.
- Do not mix related attributes across objects without a good reason.
- Keep public class elements together, and document the interface to the class.

## Init / empty

- Do **not** require initializing all class variables in the
  constructor.
- No forward-declaration requirement, since Cwhip is a multi-pass compiler.
- An empty string is still a valid string (no extra validity rules).

## Exceptions / errors

- Use exceptions for **error recovery**, not for ordinary flow control.
- **Fatal:** rethrow so the stack trace surfaces.
- **Recoverable:** a console print is OK (it may go unseen).
- Prefer exceptions over return codes.
- There is **no** assertion feature that compiles out for production.

## Tests

- No tests embedded in production code unless unavoidable.
- All testing code and data live under `tests/` (no outside data unless
  unavoidable).
- All testing goes through **CTest**.
- Keep tests as small as practical; treat them as example code when
  practical.
- [PLAN.md](PLAN.md) still owns broader test-suite shape and work
  order; this section locks placement and delivery rules.

## FFI

- **Inline C** is the preferred way to interface external libraries unless you
  are implementing actual runtime code for Cwhip.

## Formatter defaults

The block below came from the `cwhip-format` built-in defaults
(`--dump-config`). Spacing, list wrapping, and the block indent of a
comment-only line, `case`, `default`, a brace that starts a line, and
`except`, `finally`, and `from` are always applied. They are not keys
in this dump. `BreakBeforeBinaryOperators`, `BraceBinding`,
`CommentPragmas`, and `SpaceBeforeParens` stay unset.

```
# Language of the file. Cwhip is the only accepted value.
Language: Cwhip
# Spaces for each indent level.
IndentWidth: 4
# Inserted indent uses spaces.
UseTab: Never
# Extra spaces past the block indent on a wrapped line.
ContinuationIndentWidth: 8
# Do not line up an operand with the operator.
AlignOperands: DontAlign
# Preferred line length. 0 means do not wrap.
ColumnLimit: 80
# Do not split a string literal across lines.
BreakStringLiterals: false
# Allow a function body on one line. None does not.
AllowShortFunctionsOnASingleLine: None
# Allow a block on one line. Never does not.
AllowShortBlocksOnASingleLine: Never
# Allow an if body on one line. Never does not.
AllowShortIfStatementsOnASingleLine: Never
# Allow a loop body on one line.
AllowShortLoopsOnASingleLine: false
# Allow an enum body on one line.
AllowShortEnumsOnASingleLine: false
# Put { on the next line. False keeps the source break.
NewlineBeforeOpenBrace: false
# Put the token after { on the next line.
NewlineAfterOpenBrace: true
# Put the token after } on the next line.
NewlineAfterCloseBrace: true
# Put } on its own line. False leaves it at the end of the line.
NewlineBeforeCloseBrace: true
# Put else on the line after }. False leaves it on the } line.
NewlineBeforeElse: true
# Put except on the line after }. Also applies to finally. False leaves it on the } line.
NewlineBeforeExcept: true
# Break a long parenthesized list after the opening parenthesis.
WrapLongParenthesizedList: BreakAfterOpenParen
# Wrapped parameters stay one per line.
BinPackParameters: false
# Wrapped arguments stay one per line.
BinPackArguments: false
# Insert a blank line around a long control statement.
BlankLinesAroundLongControlStatement: true
# A control statement longer than this many lines is long.
LongControlStatementLines: 10
# Reflow hash and slash comments to the column limit.
ReflowComments: true
# Reflow block comments to the column limit.
ReflowBlockComments: false
# A newline ends a statement.
StatementTerminator: Newline
# Do not insert semicolons.
InsertSemicolons: false
# Allow more than one statement on a line.
AllowMultipleStatementsPerLine: false
# Wrap only inside parentheses and brackets.
WrapOnlyInsideParensAndBrackets: true
# Keep else and its parenthesis on one line.
KeepElseParenOnSameLine: true
# Do not write else if.
ForbidElseIf: true
# Keep and, or, and not as written.
PreserveLogicalSpelling: true
# Keep keyword capitalization as written.
PreserveKeywordCase: true
# Keep int, strg, and other type spellings as written.
PreserveTypeAliasSpelling: true
# Keep numeric spellings as written.
PreserveNumericSpelling: true
# Copy string text without re-escaping.
PreserveStringLexeme: true
# Keep parentheses that are in the source.
PreserveParentheses: true
# Do not split the .. operator.
SplitDotDot: false
# Do not split the >> operator.
SplitShiftRight: false
# Do not expand include directives.
ExpandIncludes: false
# Do not reorder include directives.
ReorderIncludes: false
# Do not format an inline C body.
FormatInlineC: false
# Keep newlines inside block comments.
PreserveBlockCommentNewlines: true
```
