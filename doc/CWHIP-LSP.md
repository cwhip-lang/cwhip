# cwhip-lsp

`cwhip-lsp` is a language server for Cwhip source. It speaks a Language Server Protocol session on standard input and standard output. It checks the text of open documents and publishes diagnostics.

After a build, the program is `bin/cwhip-lsp`, next to `cwhip`. An install places it on `PATH` under the same name.

## Run the server

```
cwhip-lsp
```

The program reads no arguments. Anything on the command line is ignored, and it does not print help or a version. An editor starts it and leaves both pipes open for the life of the session. There is no socket and no port.

The process ends when standard input ends, or when it receives `exit`. The exit status is 0 when `shutdown` was received, and 1 otherwise.

| How the process ends | Status |
|---|---|
| Standard input ends after `shutdown` | 0 |
| Standard input ends and `shutdown` was not received | 1 |
| `exit` after `shutdown` | 0 |
| `exit` and `shutdown` was not received | 1 |

`exit` stops the process immediately. It sends no message.

The server finds the SDK from its own executable, the same way `cwhip` does. Use the `cwhip-lsp` from a build tree or from an installation. Resource variables such as `CWHIP_HOME` are described in [Build and installation](INSTALLATION.md).

## What it speaks

Each message is a JSON-RPC 2.0 body with a `Content-Length` header. The length is the number of bytes in the body. Header lines end with `\r\n`, and a blank line (`\r\n`) separates the headers from the body. The server reads `Content-Length` and ignores any other header line. A header block with no `Content-Length`, or a body shorter than that length, ends the session.

A message the server sends uses the same framing. The server writes protocol messages only. It does not write a log.

A request carries a numeric `id`. `initialize` and `shutdown` copy that number into the response. When either of those has no numeric `id`, the response `id` is `null`. A notification has no `id`. The server sends no response for a notification, apart from the diagnostic notifications below.

The server handles one message at a time. It finishes that message, including a diagnostic notification, before it reads the next one.

`initialize` answers with one capability:

```json
{"jsonrpc":"2.0","id":1,"result":{"capabilities":{"textDocumentSync":1}}}
```

`textDocumentSync` is `1`, full-document sync. On open and on change, the client sends the whole text of the document. The result lists no other capability. `initialize` does not read its parameters, so a workspace folder or a root URI in that request does not choose the project. The project comes from the document path, described under Diagnostics.

A request for any other method is answered with error code `-32601` and the message `method not found`:

```json
{"jsonrpc":"2.0","id":3,"error":{"code":-32601,"message":"method not found"}}
```

The `id` in that error is the request's numeric id. A notification for a method the server does not handle gets no reply.

## Requests and notifications

| Method | Role | What the server does |
|---|---|---|
| `initialize` | request | Returns `textDocumentSync` `1`. Parameters are ignored. |
| `initialized` | notification | No reply. |
| `shutdown` | request | Returns `result` `null` and records that shutdown was requested. |
| `exit` | notification | Ends the process. See the status table above. |
| `textDocument/didOpen` | notification | Stores the document and publishes diagnostics. |
| `textDocument/didChange` | notification | Replaces the stored text and publishes diagnostics. |
| `textDocument/didSave` | notification | May replace the stored text, then publishes diagnostics. |
| `textDocument/didClose` | notification | Drops the document and publishes an empty diagnostic list. |
| `$/cancelRequest` | notification | No reply. A check already running runs to the end. |

`shutdown` records shutdown and answers even when the caller sent no `id`. The response `id` is `null` in that case. Until `exit`, or until standard input ends, a later request is handled the same way as before `shutdown`. The flag only chooses the exit status.

A normal session is `initialize`, then `initialized`, then document notifications, then `shutdown`, then `exit`. The server still accepts a document notification that arrives before `initialize`.

### Open

`textDocument/didOpen` reads `params.textDocument`.

| Field | Use |
|---|---|
| `uri` | Document key. Later diagnostic notifications copy this string. |
| `text` | Source to check. |
| `version` | A JSON number. Missing, or not a number, means version 0. |
| `languageId` | Ignored. |

A second open for the same `uri` replaces the stored document. If `textDocument` is missing, the server sends nothing.

### Change

`textDocument/didChange` updates a document that is already open. If `textDocument` is missing, or the uri is not open, the server publishes nothing.

The new text is the `text` string of the last object in `params.contentChanges`. That string replaces the whole document. A `range` on the change is not applied. If `contentChanges` is missing, empty, or the last object has no string `text`, the stored text becomes empty, and that empty text is checked.

`textDocument.version`, when it is a JSON number, replaces the stored version. Otherwise the stored version stays.

### Save

`textDocument/didSave` updates a document that is already open. If `textDocument` is missing, or the uri is not open, the server publishes nothing.

If `textDocument.text` is a string, it replaces the stored text. Otherwise the stored text stays as it is. The server does not read the file from disk. It checks the stored text and publishes diagnostics. The save does not change the stored version.

### Close

`textDocument/didClose` drops `textDocument.uri`. It publishes `textDocument/publishDiagnostics` for that uri with `"diagnostics":[]` and no `version`. That publish is sent whenever `textDocument` is present, including when the uri was not open. A close with no `textDocument` sends nothing.

## Diagnostics

After an open, change, or save of a known document, the server checks the stored text and sends `textDocument/publishDiagnostics`. A document with no errors still gets that notification, with an empty `diagnostics` array, so the client can clear older results.

The check is the compiler's source check on the stored text. It does not generate code. The document does not need a `start` block. The check continues at the next statement or declaration, so one mistake does not hide a later one. A lexical error, such as an unexpected character or an unterminated string, stops the scan of that text. One check publishes at most 100 diagnostics. Each `message` is the explanation from [Diagnostic contract and code registry](DIAGNOSTICS.md): the text the compiler prints after `error:` on a source line. The notification does not include the `cwhip: error[CWHIP1001]` header or the `file:line:column:` prefix.

An `import` is resolved from the project that contains the document path and from the SDK, as in [project module search](INSTALLATION.md#project-module-search). An `include` reads the named file from disk. An absolute include path is used as given. A relative include path is resolved from the document's directory. When the check can report a failure, that failure is a diagnostic. A failure raised while resolving the project or the SDK, before a source location exists, is published at line 0, character 0. `missing cwhip-pkg.lock; run 'cwhip-pkg install --yes'` is one such message. The server keeps running.

A diagnostic object looks like this:

```json
{
  "range": {
    "start": {"line": 1, "character": 11},
    "end": {"line": 1, "character": 11}
  },
  "severity": 1,
  "source": "cwhip",
  "message": "cannot initialize int64 variable with String"
}
```

| Field | Value |
|---|---|
| `range` | `start` and `end` are the same position. The range is a caret, not a span. |
| `severity` | Always `1`, an error. |
| `source` | Always `cwhip`. |
| `message` | The explanation. |

`line` and `character` are 0-based. The compiler's line and column are 1-based, and the server subtracts 1. A reported line or column of 0 is sent as 0. `character` counts bytes from the start of the line. The server does not advertise a position encoding.

Every diagnostic uses the open document's `uri`. A location the check reports in another file, such as an included file, is still published on the open document, at that location's line and column.

`version` on an open, change, or save notification is the stored document version. Close omits `version`.

### File paths

The check turns the document `uri` into a filesystem path. The document key remains the original `uri` string. Two different URI strings are two documents, even when they name the same path.

| URI | Path used for the check |
|---|---|
| `file:///tmp/sample.cw` | `/tmp/sample.cw` |
| `file://localhost/tmp/sample.cw` | `/tmp/sample.cw` |
| `file:///tmp/my%20file.cw` | `/tmp/my file.cw` |

A host before the first slash is dropped. Percent-encoded bytes are decoded. A URI that does not start with `file://` is percent-decoded and used as the path. `file://` with no slash in the remainder is an empty path, and the check names that text `untitled.cw`.

## A short session

Frames use `\r\n`. This initialize body is 58 bytes:

```
Content-Length: 58

{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}
```

The blank line in that block is the empty line before the body. Then the client sends `initialized` and opens a buffer. `languageId` may be `cwhip`; the server does not read it.

```json
{"jsonrpc":"2.0","method":"initialized","params":{}}
```

```json
{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///tmp/sample.cw","languageId":"cwhip","version":1,"text":"start {\n int64 a = \"no\"\n int64 b = missing\n}\n"}}}
```

`initialize` is answered with the capability result and id `1`. `initialized` has no reply. The open produces one `textDocument/publishDiagnostics` notification for `file:///tmp/sample.cw`, with `version` 1. The text above yields two diagnostics:

| `message` | `line` | `character` |
|---|---|---|
| `cannot initialize int64 variable with String` | 1 | 11 |
| `undefined variable 'missing' or field` | 2 | 11 |

Line 1 is the `int64 a = "no"` line. Both carets sit on the first byte of the bad expression.

The client then shuts the server down:

```json
{"jsonrpc":"2.0","id":2,"method":"shutdown"}
```

```json
{"jsonrpc":"2.0","method":"exit"}
```

`shutdown` is answered with `"result": null` and id `2`. `exit` ends the process with status 0.
