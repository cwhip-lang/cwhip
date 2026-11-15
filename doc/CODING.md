# CWHIP Coding standard

This document is intended to be used by the AI programmer when writing code in the
Cwhip programming language. This is a superset of the guidelines that is intended to be 
used by a human programmer.

Other proof-of-concept applications may keep their own `CODING.md` if
those rules do not conflict with this document.

## General guidelines

- Prefer to define class methods outside of the class body. This keeps
  the definition of the class small and readable.
- Always use a new line after a **{** and before a **}**. Including
  one line code blocks. This helps to visually define code blocks.
- Indents are 4 spaces. No tabs for indent. Continuations are allowed
  inside **[]** and **()** and indent is 8 spaces past the normal
  indent. A long call or dict breaks after `(` or `[`, one item per
  line, including a call or dict on the right of `=`. A long
  out-of-line method breaks before `from` at the block indent. A
  generic and a class base list stay on one line.
- One space around `=` and around binary operators. Unary `+`, `-`,
  `!`, and `~` stay tight. `not` has one space after it. `..` stays
  tight. One space after a comma, none before. No space inside `()`,
  `[]`, or `<>`. One space before `{` when it shares the line.
- A comment-only line, `case`, `default`, a `{` on its own line, and
  `except`, `finally`, and `from` when they start a line use the
  block indent.
- Line length should be kept to less than 80 characters to allow clean
  editing on a console.
- Reflow all comments to the column limit.
- Put a blank line before and after a control statement longer than
  10 lines. When variables are defined for a test or a loop, keep
  those definitions inside the blank-line boundary, with the
  construct. For a shorter test or loop, extra newlines are optional.

## File size

- **Usual target:** about 200 physical lines, when practical.
- **Soft ceiling:** about 400 physical lines. Smaller is fine.
- Prefer **one class per file**. Split when a file mixes two jobs.
- Source files over **1000 lines** must be broken into submodules.
- Prefer short files over packing related helpers into one large
  unit.

## File header

Every source file starts with a multi-line comment header that
describes the file's contents, plus:

- **Date created.** Set this once when the file is created. Do not
  bump the create date on later edits.
- **Author.** For agent-written files use **Auto** (Composer / Cursor
  coding agent), or the worker's reported identity if that is what
  the run uses. For human-authored files, use the human's name.

Record every update in a `Changelog:` list in the file header or
immediately under it. Each entry is a date plus a short note.

```text
/*
 * src/lib/example.cw — short description of this file's job.
 *
 * Created: 2026-11-05
 * Author: Auto
 *
 * Changelog:
 *   2026-11-05  Initial file.
 *   2026-11-06  Split helper into submodule.
 */
```

## Class and method comments

Agent-written code is often denser than typical human code. That
density is respectable, but harder to skim. Full method comments
carry the narrative humans need to read it.

- **Every class:** a multi-line comment describing what it does and
  how it fits the program.
- **Every method**, public API and private helpers alike: a full
  method comment covering purpose, parameters, and return value. Do
  not substitute a bare one-liner for the method block.

## Naming

- **Classes:** CamelCase, first letter capital.
- **Methods:** lowercase `with_under_score`.
- **Variables:** camelCase, first letter lower.
- **Enums:** `ALL_CAPS` with underscores — symbolic names for `int64`
  literals. Prefer enum/names over magic number literals.
- There is no `const` style requirement. Enums are named `int64`
  values.
- **Dict keys** are strings. The key may be the content of a string
  variable. The runtime implements **dict** as a simple hash table.

## Visibility / ownership

- Default visibility was intended private, but hiding data is seldom
  required — do **not** treat encapsulation as mandatory secrecy.
- Data allocated by an object (for example file handles) is **owned**
  by that object.
- Do not mix related attributes across objects without a good reason.
- Keep public class elements together, and document the interface to
  the class.
- Speak in **ownership** terms. Avoid "borrowed" jargon.

## Init / empty

- Null, empty, and missing are language territory. Class attribute
  initial values are discoverable at compile time.
- Do **not** require initializing all class variables in the
  constructor.
- No forward-declaration requirement, since Cwhip is a multi-pass
  compiler.
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

- **Inline C** is the preferred way to interface external libraries
  unless you are implementing actual runtime code for Cwhip. Users
  typically lack runtime source access.

## User-facing binaries and argv

Operator-facing executables (`cplanets-server`, `cplanets`,
`cplanets-ai`, `cplanets-tick`, and any later user tools) must parse
argv with the Cwhip stdlib `cli` package (`import cli as Cli`).
Include generated help via `-h` / `--help` (`Action.HELP` and
`helpText()`). Do not hand-roll flag loops for those programs. Unit
and fn test programs are exempt unless migration is trivial.

- `--config PATH` is optional on `cplanets-server`, `cplanets`, and
  `cplanets-ai`. If it is omitted, ensure and load
  `~/.config/cplanets/…`. `cplanets-tick` still requires `--config`.
- If `--config` is present but the path is empty, print the same help
  text as `-h` / `--help` and exit **2** (usage). Explicit `-h` /
  `--help` still exits **0**.
- Every other parameter must be settable as a default in that file.
  Load the file first. Any flag present on argv (`wasProvided`)
  overrides the file value silently (no warning).
- Mode flags follow the same rule. The file stores `true` / `false`.
  Presence on argv forces the switch on.
- `--config` itself has no in-file key.
- The server uses one unified `config/server-*.cfg`. That file holds
  process and network settings and the §14 scenario knobs
  ([SERVER-CONFIG.md](SERVER-CONFIG.md)).
- Legacy `setup=` / `--setup` / `spawn_ai_count` /
  `spawn_ai_template` are rejected and removed.
- An explicit `--config` that cannot be opened is a hard error (no
  silent builtin).
- AI, human, and tick keep their own `--config` surfaces.
  `config/tick-default.cfg` is a placeholder until advance-N.
- Key catalogs: [SERVER-CONFIG.md](SERVER-CONFIG.md),
  [AI-CLIENT-CONFIG.md](AI-CLIENT-CONFIG.md),
  [HUMAN-CLIENT-CONFIG.md](HUMAN-CLIENT-CONFIG.md).
- XDG defaults for the server, human, and AI are implemented
  (CPL-115).

Headless operator programs that emit decision or settings logs use
one pattern:

- The text file key is `verbosity = N` (default `0`). CLI
  `--verbosity N` overlays the file when `wasProvided("verbosity")`.
- The scale is **0–10**. Out-of-range values clamp (not reject).
- Level `0` is errors-only for optional lines. Higher levels open
  provisional categories (server: settings about 3, combat about 6,
  full about 10; AI: decisions about 3, full about 10).
- Thresholds will firm up over time. Do not invent log spam under
  reserved bands.
- Server and AI share the flag and key name. Log payloads differ
  (combat versus seat, policy, and cycle).
- Server verbosity defaults live in the server config. They are
  copied onto `Scenario.verbosity` at serve start.

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
# Pack wrapped parameters onto one line.
BinPackParameters: false
# Pack wrapped arguments onto one line.
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

## Out of scope

Not done here. See [PLAN.md](PLAN.md) for work order.

- Mass-apply these rules across all proof-of-concept applications.
  Per-app `CODING.md` copies that do not conflict with the rules
  above.
- Spot-check language feature coverage (a future list; not demo work
  now).
- Document and split long Cwhip **runtime** sources. Compiler source
  is not a priority for that track.
