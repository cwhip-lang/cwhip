# cwhip-format

`cwhip-format` rewrites Cwhip source to the style in a `.cwhip-format` file, or to the built-in style when no file is found. It formats each path you name. It reads a config from the directory you run it in.

After a build, the program is `bin/cwhip-format`, next to `cwhip`. An install places it on `PATH` under the same name.

## Run the tool

```
cwhip-format [options] <file...>
```

`file` is one or more paths to Cwhip source. The name does not have to end in `.cw`. Options may be mixed with the paths. A path that starts with `-` can be written after `--`, which ends option parsing.

| Option | Meaning |
|---|---|
| `-h`, `--help` | Print the usage text to standard output and exit 0. |
| `-V`, `--version` | Print `cwhip-format: v` plus the version, and exit 0. The version is the one `cwhip --version` prints after `cwhip: v`. |
| `-i`, `--in-place` | Rewrite each file in place. |
| `--dump-config` | Write the built-in configuration to standard output and exit 0. There is no short name. |

`--help` and `--version` stop the command at that flag, so a file list is not required. `--dump-config` still reads the rest of the command line: an unknown option is an error, and any file names are not opened.

With no action flag, at least one file is required.

### Standard output or `-i`

Without `-i`, the tool writes the formatted text of each file to standard output, in the order given, with nothing added between files. The source files stay as they are, including their modification times.

With `-i` or `--in-place`, standard output stays empty on success and each file is replaced with its formatted text. A file whose formatted text is already the same as its contents is left untouched, so its modification time does not change. A file that does change is written to `path.cwhip-format-tmp` and then renamed onto `path`. That temporary file is removed after a successful replace, and also if the write or the rename fails. A failed replace leaves the original file in place.

### `--dump-config`

`--dump-config` prints the built-in style, not the style that would apply in the current directory. Each key is two lines: a `#` comment, then `Key: Value`. The text ends with a newline. It is itself a valid `.cwhip-format` file, and reading it back produces the built-in style.

The dump does not format source. Combined with `-i` and file names, it still only prints that built-in text. It does not create missing files, and it does not change files that exist. A `.cwhip-format` in the current directory has no effect on the dump. `ColumnLimit` in the dump is `80`.

Four keys are left out of the dump because the built-in style does not choose them: `BreakBeforeBinaryOperators`, `SpaceBeforeParens`, `CommentPragmas`, and `BraceBinding`. Add those yourself when you want them. They are described at the end of this manual.

### Help, version, and errors

`--help` prints:

```
Usage: cwhip-format [options] <file...>

Format Cwhip source

Options:
  -h, --help	Print this helpful information
  -V, --version	Show the program version
  -i, --in-place	Rewrite each file in place
      --dump-config	Write the built-in default configuration
  file	Cwhip source file (required)
```

A command the tool cannot parse goes to standard error, then the same usage text, and the process exits 2. That includes a missing file list (`required argument not found: file`) and an unknown option (`unknown option: --not-an-option`, or `unknown option: -x`).

A file the tool cannot read or format is reported on standard error as `path:line:column: message`. The process keeps going through the rest of the list. The exit status is 1 if any file failed, and 0 if every file succeeded.

On a format failure, `-i` leaves that file unchanged. Without `-i`, the tool writes that file's original text to standard output after the message. A missing or unreadable source file produces no output for that path. A bad `.cwhip-format` is reported on standard error and produces no output for the file being processed.

## The configuration file

The file name is `.cwhip-format`. The tool looks for it from the process's current directory. It does not look next to each source file. Running `cwhip-format ../other/file.cw` from `~/work` uses `~/work/.cwhip-format` when that file exists, even if `../other/` has its own.

### Search order

1. `./.cwhip-format`
2. The same name in each parent, for five parents. The sixth parent is not searched.
3. `$HOME/.config/cwhip/.cwhip-format`, when `HOME` is set and not empty.

The walk stops at the first one it finds. An empty file counts as found: every key stays at the built-in default, and a file farther up the walk or in the home directory is not read.

A name that exists and is not a regular file stops the walk with an error (`path:1:1: .cwhip-format is not a regular file`). The tool does not skip that name and keep looking. A file that cannot be read is the same kind of error (`cannot read style file`).

From `root/a/b/c/d/e/f`, the directories examined are `f`, `e`, `d`, `c`, `b`, and `a`. `root/.cwhip-format` is one level too far. If none of those six exist, the home file is next.

### When no file is found

The built-in style is used, with no message. That is also what `--dump-config` prints. `ColumnLimit` is 80, `ContinuationIndentWidth` is 8, and the four keys omitted from the dump stay unset.

If the current directory cannot be read, the tool reports `.:1:1: cannot read the current directory` and does not format.

### How to write the file

The file is a list of `Key: Value` lines. A key you omit keeps its built-in value. The four unset keys stay unset until a line sets them.

```
# Wider lines in this tree. 0 turns wrapping off.
ColumnLimit: 100

# Leave else on the closing-brace line.
NewlineBeforeElse: false
```

Rules:

- Blank lines are ignored.
- Spaces around the key and the value are ignored.
- A line that begins with a space or a tab is an error (`nested map`).
- A line needs a colon and a value. `Key:` with nothing after it is an error.
- A key may appear once. A second line is `duplicate key: Key`.
- A key the tool does not know is `unknown key: Key`. `BasedOnStyle` is rejected that way. There is no named base style.
- `Language` may be omitted. The only accepted value is `Cwhip`.
- Integers are an optional `-` and digits. A negative value is `negative integer: Key`. `ColumnLimit: 0` is valid and means do not wrap.
- `true` and `false` are the only boolean spellings.
- A value may be quoted with `"` or `'`. Double quotes accept `\\`, `\"`, `\n`, and `\t`. A single-quoted value cannot contain `'`.
- `CommentPragmas` must be quoted, including the empty string `''` or `""`.

A problem in the file is `path:line:1: message`. The column is always 1. The whole file is refused; a later key does not repair an earlier error.

### Comments

`#` starts a comment, through the end of the line, unless the `#` is inside quotes. A comment can occupy the whole line or follow a value:

```
# NewlineAfterOpenBrace: true
NewlineAfterOpenBrace: false # body may stay on the brace line
```

The first line is ignored, so it does not set the key. The value on the second line is `false`. A `#` inside `"..."` or `'...'` is part of the value.

## Keys

Defaults below are the built-in style. `--dump-config` prints a `#` comment above each of these keys. The descriptions here follow those comments and the way the formatter applies them.

A short file replaces only the keys it names. Copy the dump to `.cwhip-format` when you want every dumped key written down.

### Language, indent, and columns

**Language** — default `Cwhip`. The language of the file. `Cwhip` is the only accepted value. The line may be left out.

**IndentWidth** — default `4`. Spaces for each indent level. A nested statement is indented by this many spaces times its depth. The value is a non-negative integer.

**UseTab** — default `Never`. Inserted indent uses spaces. `Never` is the only accepted value.

**ContinuationIndentWidth** — default `8`. Extra spaces past the block indent on a wrapped line. A wrapped item inside a block indented 4 spaces is indented 12 spaces. The value is a non-negative integer. The built-in width is 8, which is two indent levels when `IndentWidth` is 4.

**AlignOperands** — default `DontAlign`. The formatter does not line an operand up with the operator on the previous line. A wrapped line uses `ContinuationIndentWidth` instead. `DontAlign` and `false` are the accepted values.

**ColumnLimit** — default `80`. Preferred line length. `0` means do not wrap: long calls stay on one line, and comments are not reflowed. Any other non-negative integer is a column count. A line that has no legal break is left longer than the limit.

With a positive limit, a parenthesized or bracketed list that runs past the limit breaks after the opening `(` or `[`. Each item goes on its own line at the continuation indent, and the closing delimiter stays on the last item:

```
start {
    print(
            alpha,
            beta,
            gamma)
}
```

A list that fits on one line stays there. Wrapping stays inside `()` and `[]`. A generic, an assignment, a field initializer, and a class base list stay on one line, because a newline there would change the program. String literals are not split across lines.

### One-line blocks

A block that already spans several lines stays that way. These keys decide whether a block written on one line is split. Splitting puts the token after `{` on the next line and puts `}` on its own line.

**AllowShortFunctionsOnASingleLine** — default `None`. `None` and `false` split a one-line function body. `All`, `true`, `Inline`, and `Empty` leave it on one line. The dump writes `None` or `All`. `AllowShortBlocksOnASingleLine: Never` still splits function bodies.

**AllowShortBlocksOnASingleLine** — default `Never`. `Never` and `false` split a one-line block. That also splits functions, `if` bodies, loops, and other blocks (`start`, `else`, `try`, `namespace`, and the rest) even when their own key would leave them on one line. `Always`, `true`, and `Empty` allow a one-line block to stay. Enums follow `AllowShortEnumsOnASingleLine` on their own. The dump writes `Never` or `Always`.

**AllowShortIfStatementsOnASingleLine** — default `Never`. `Never` and `false` split a one-line `if` body. `Always` and `true` leave it, unless `AllowShortBlocksOnASingleLine` is `Never`.

**AllowShortLoopsOnASingleLine** — default `false`. `false` splits a one-line `while`, `for`, or `do` body. `true` leaves it, unless `AllowShortBlocksOnASingleLine` is `Never`.

**AllowShortEnumsOnASingleLine** — default `false`. `false` splits `enum { A, B }` onto several lines. `true` leaves that enum on one line.

Under the defaults, `start { print(1) }` becomes:

```
start {
    print(1)
}
```

The same split applies to a one-line `if`, loop, enum, or function. An empty `{}` becomes `{` and `}` on the following line.

### Braces

`false` on each of these keys leaves an existing newline where it is. `false` does not pull a brace, a body, or a clause back onto the previous line.

**NewlineBeforeOpenBrace** — default `false`. `true` puts `{` on the next line when that newline is legal and `{` currently shares its line with earlier code. `false` keeps the source break: `{` stays on the header when it was written there, and stays on the next line when it was written there.

`true` moves `{` for `start`, `if`, `while`, `for`, `switch`, `do`, `try`, `else`, `except`, `finally`, `namespace`, an out-of-line method, and `case` or `default`. A comment that sat on the `{` line stays with `{`. `class`, an in-class method, `destroy`, and `enum` keep `{` on the header line, because a newline before those braces does not parse. With `true`, `if (ready) { print(1) }` becomes an `if` whose `{` is on the next line, and the body is still split by the other brace keys.

**NewlineAfterOpenBrace** — default `true`. `true` puts the token after `{` on the next line. `false` lets the body stay on the `{` line. This key does not move `{` onto or off the header.

`false` leaves the body on the `{` line. A one-line `start { print(1) }` keeps `print(1)` on the brace line and puts `}` on the next line, because a one-line block is still expanded. A body that is already on the next line stays there. An empty `{}` stays on one line when this key is `false`. A one-line block that the `AllowShort*` keys are keeping on one line stays on one line when this key is `true`.

**NewlineAfterCloseBrace** — default `true`. `true` puts the token after `}` on the next line. `false` lets what follows stay on the `}` line.

`else` is `NewlineBeforeElse`. `except` and `finally` are `NewlineBeforeExcept`. The `while` of `do`/`while` stays on the `}` line under either value:

```
do {
    print(1)
} while (ready)
```

A one-line block is still expanded when this key is `false` and `NewlineAfterOpenBrace` is `true`, so `start { print(1) }` becomes a body line and a `}` line. A comment written between two closing braces stays on that line when this key is `false` (`} /* stay */ }`). When it is `true`, the comment moves with the following `}` onto the next line.

**NewlineBeforeElse** — default `true`. `true` puts `else` that shares the `}` line onto the next line. `false` leaves that `else` on the `}` line. An `else` that already has its own line keeps it. This key is independent of `NewlineAfterCloseBrace`: with the close key set to `false` and this key left at `true`, `else` still moves.

```
if (ready) {
    print(1)
}
else (other) {
    print(2)
}
```

`false` keeps `} else (other) {` together. `else (` stays on one line either way. `else if` is a format error.

**NewlineBeforeExcept** — default `true`. `true` puts `except` and `finally` that share the `}` line onto the next line. `false` leaves them on the `}` line. A clause that already has its own line keeps it. This key is independent of `NewlineAfterCloseBrace` and of `NewlineBeforeElse`. Turning the else key off leaves `except` and `finally` on their own lines, and turning this key off leaves `else` on its own line.

```
try {
    print(1)
}
except(Exception) {
    print(2)
}
finally {
    print(3)
}
```

`false` keeps `} except(Exception) {` and `} finally {` together. `except(` stays on one line. A newline between `except` and `(` is a format error.

### Wrapping and blank lines

**WrapLongParenthesizedList** — default `BreakAfterOpenParen`. A long parenthesized list breaks after the opening parenthesis, as in the `print` example under `ColumnLimit`. `BreakAfterOpenParen` is the only accepted value.

**BinPackParameters** — default `false`. Wrapped parameters go one per line. `true` and `false` are both accepted; parameters stay one per line either way.

**BinPackArguments** — default `false`. Wrapped arguments go one per line. `true` and `false` are both accepted; arguments stay one per line either way.

**BlankLinesAroundLongControlStatement** — default `true`. `true` inserts a blank line before and after a long `if`, `while`, `for`, `switch`, or `do`, when that blank line is not already there. `false` inserts none. Blank lines that are already present stay, including around a short control statement. The tool does not remove them.

Declarations written immediately above the keyword, each followed by a single newline, stay with the construct. The new blank line goes before those declarations, not between them and the keyword.

**LongControlStatementLines** — default `10`. A control statement longer than this many lines is long. The count is the output lines from the keyword through the end of the construct. A statement of exactly this many lines is left alone. The value is a non-negative integer.

### Comments in source

**ReflowComments** — default `true`. `true` reflows `#` and `//` comments to `ColumnLimit`, breaking them on spaces onto more comment lines with the same marker. `false` leaves those comments as written. `/* */` comments are not reflowed. Reflow also stays off when `ColumnLimit` is `0`. A line comment matched by `CommentPragmas` is left as written.

**PreserveBlockCommentNewlines** — default `true`. Newlines inside `/* */` comments stay. `true` and `false` are both accepted; those newlines stay either way. A block comment between two statements stays between them.

### Spelling and syntax the formatter keeps

These keys record behavior the formatter follows on every file. For a key whose only legal value is listed, any other value is `invalid value for Key`. For a boolean in this list, `true` and `false` are both accepted, and the behavior below is what you get either way.

**BreakStringLiterals** — default `false`. String literals stay on one line, including when that makes the line longer than `ColumnLimit`. The text inside the quotes is copied, escapes included.

**StatementTerminator** — default `Newline`. A newline ends a statement. `Newline` is the only accepted value. Two statements on one line are a format error, and the file is left unchanged under `-i`.

**InsertSemicolons** — default `false`. The formatter does not insert semicolons.

**AllowMultipleStatementsPerLine** — default `false`. The formatter does not put two statements on one line.

**WrapOnlyInsideParensAndBrackets** — default `true`. Wrapping happens inside parentheses and brackets. Generics, assignments, field initializers, and base lists are not wrapped.

**KeepElseParenOnSameLine** — default `true`. `else` and its `(` stay on one line.

**ForbidElseIf** — default `true`. `else if` is left as a format error. Write `else` and a following parenthesized condition, or `else` and a brace.

**PreserveLogicalSpelling** — default `true`. `and`, `or`, `not`, `&&`, `||`, and `!` stay as written.

**PreserveKeywordCase** — default `true`. Keyword capitalization stays as written, so `START` stays `START`.

**PreserveTypeAliasSpelling** — default `true`. `int`, `strg`, `String`, and other type spellings stay as written.

**PreserveNumericSpelling** — default `true`. Numeric spellings stay as written, including `.5`.

**PreserveStringLexeme** — default `true`. String text is copied without re-escaping.

**PreserveParentheses** — default `true`. Parentheses in the source stay.

**SplitDotDot** — default `false`. The `..` operator stays in one piece.

**SplitShiftRight** — default `false`. The `>>` operator stays in one piece.

**ExpandIncludes** — default `false`. `include` lines are copied. Their files are not read.

**ReorderIncludes** — default `false`. `include` lines stay in the order written.

**FormatInlineC** — default `false`. An inline C body is copied with its whitespace.

## Keys the dump leaves out

These four keys are valid in `.cwhip-format` and absent from `--dump-config`. Until you set one, the formatter does not apply it: it does not insert or remove an operator break, a space before `(`, a comment exemption, or a brace binding of its own. The `Newline*` keys still apply when these are unset.

**BreakBeforeBinaryOperators** — unset. Set it when a parenthesized expression past `ColumnLimit` should break at an operator.

- `NonAssignment` breaks before `&&`, `and`, and the other non-assignment operators. The operator starts the next line at the continuation indent.
- `None` and `false` break after the operator.

The break is inside `()` or `[]`. Operators outside those, and operators the formatter is not allowed to wrap, stay on their line. With the key unset, a long condition stays on one line.

**SpaceBeforeParens** — unset. Set it to change the space before `(`.

- `Never` removes that space, so `if (` becomes `if(` and `print (` becomes `print(`.
- `ControlStatements` puts one space between `if`, `while`, `for`, or `switch` and `(`. It removes a space before `(` after a name, `)`, `]`, `>`, or a string, so a call written `longCall (` becomes `longCall(`. It leaves the space after `print`, `return`, `raise`, and `except` as written.

Unset, `if (` and `print (` both stay as they were written.

**CommentPragmas** — unset. A quoted regular expression. A `#` or `//` comment whose text matches is not reflowed, and the source line that holds it is copied unchanged, code included. The match runs on the comment after the `#` or `//` marker and one optional space, so `'^test:'` protects `// test: ...`. `''` and `""` protect nothing. The value must be quoted. A pattern the tool cannot compile is `invalid CommentPragmas pattern`.

**BraceBinding** — unset.

- `PreserveWhereLegal` leaves `{` where the source put it, wherever both positions parse. `else`, `except`, and `finally` still follow `NewlineBeforeElse` and `NewlineBeforeExcept`.
- `Custom` attaches `{` to the previous line when the source has a single newline there and that newline is legal (`if (ready)` followed by `{` on the next line becomes `if (ready) {`). A blank line before `{` stays. `enum` braces stay where they are. `Custom` also puts `else`, `except`, and `finally` on the line after `}`, including when `NewlineBeforeElse` or `NewlineBeforeExcept` is `false`.

`class`, an in-class method, and `destroy` still need `{` on the header line. A newline before those braces is a format error under either value.
