#!/usr/bin/env python3
"""Stdio session for the Cwhip language server."""

import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import unittest


class LanguageServerTests(unittest.TestCase):
    def session(self):
        return subprocess.Popen(
            [str(self.args.server)], stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    def send(self, process, message):
        body = json.dumps(message).encode()
        process.stdin.write(f"Content-Length: {len(body)}\r\n\r\n".encode() + body)
        process.stdin.flush()

    def read(self, process):
        header = b""
        while b"\r\n\r\n" not in header:
            chunk = process.stdout.read(1)
            if not chunk:
                self.fail(f"server closed stdout: {header!r}")
            header += chunk
        length = int(header.split(b"Content-Length:")[1].split(b"\r\n")[0].strip())
        return json.loads(process.stdout.read(length))

    def test_publishes_each_recovered_diagnostic(self):
        process = self.session()
        try:
            self.send(process, {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
            started = self.read(process)
            self.assertEqual(started["id"], 1)
            capabilities = started["result"]["capabilities"]
            self.assertEqual(capabilities["textDocumentSync"], 1)
            self.assertIs(capabilities["documentFormattingProvider"], True)
            self.assertIs(capabilities["documentRangeFormattingProvider"], True)
            self.send(process, {"jsonrpc": "2.0", "method": "initialized", "params": {}})
            text = "start {\n int64 a = \"no\"\n int64 b = missing\n}\n"
            self.send(process, {
                "jsonrpc": "2.0",
                "method": "textDocument/didOpen",
                "params": {"textDocument": {
                    "uri": "file:///tmp/sample.cw",
                    "languageId": "cwhip",
                    "version": 1,
                    "text": text,
                }},
            })
            published = self.read(process)
            messages = [item["message"] for item in published["params"]["diagnostics"]]
            self.assertEqual(len(messages), 2)
            self.assertIn("cannot initialize int64 variable with String", messages)
            self.assertIn("undefined variable 'missing' or field", messages)
            self.assertEqual(published["params"]["diagnostics"][0]["range"]["start"]["line"], 1)
            self.send(process, {"jsonrpc": "2.0", "id": 2, "method": "shutdown"})
            self.assertIsNone(self.read(process)["result"])
            self.send(process, {"jsonrpc": "2.0", "method": "exit"})
            process.stdin.close()
            self.assertEqual(process.wait(timeout=5), 0)
        finally:
            if process.poll() is None:
                process.kill()

    def open_document(self, process, uri, text):
        self.send(process, {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
        self.read(process)
        self.send(process, {"jsonrpc": "2.0", "method": "initialized", "params": {}})
        self.send(process, {
            "jsonrpc": "2.0",
            "method": "textDocument/didOpen",
            "params": {"textDocument": {
                "uri": uri,
                "languageId": "cwhip",
                "version": 1,
                "text": text,
            }},
        })
        return self.read(process)

    def test_formats_the_open_document_and_a_range(self):
        process = self.session()
        try:
            uri = "file:///tmp/format-sample.cw"
            closed = {
                "jsonrpc": "2.0",
                "id": 2,
                "method": "textDocument/formatting",
                "params": {"textDocument": {"uri": uri}},
            }
            self.send(process, closed)
            missing = self.read(process)
            self.assertEqual(missing["error"]["code"], -32602)
            self.assertEqual(missing["error"]["message"], "document not open")
            original = "start {\n    value=1\n    other=2\n}\n"
            self.open_document(process, uri, original)
            self.send(process, {
                "jsonrpc": "2.0",
                "id": 3,
                "method": "textDocument/formatting",
                "params": {"textDocument": {"uri": uri}},
            })
            formatted = self.read(process)
            edits = formatted["result"]
            self.assertEqual(len(edits), 1)
            edit = edits[0]
            self.assertEqual(edit["range"]["start"], {"line": 0, "character": 0})
            self.assertEqual(edit["range"]["end"]["line"], 4)
            self.assertEqual(edit["range"]["end"]["character"], 0)
            self.assertEqual(edit["newText"], "start {\n    value = 1\n    other = 2\n}\n")
            self.send(process, {
                "jsonrpc": "2.0",
                "method": "textDocument/didChange",
                "params": {
                    "textDocument": {"uri": uri, "version": 2},
                    "contentChanges": [{"text": edit["newText"]}],
                },
            })
            self.read(process)
            self.send(process, {
                "jsonrpc": "2.0",
                "id": 4,
                "method": "textDocument/formatting",
                "params": {"textDocument": {"uri": uri}},
            })
            self.assertEqual(self.read(process)["result"], [])
            self.send(process, {
                "jsonrpc": "2.0",
                "method": "textDocument/didChange",
                "params": {
                    "textDocument": {"uri": uri, "version": 3},
                    "contentChanges": [{"text": original}],
                },
            })
            self.read(process)
            self.send(process, {
                "jsonrpc": "2.0",
                "id": 5,
                "method": "textDocument/rangeFormatting",
                "params": {
                    "textDocument": {"uri": uri},
                    "range": {
                        "start": {"line": 2, "character": 0},
                        "end": {"line": 3, "character": 0},
                    },
                },
            })
            ranged = self.read(process)["result"]
            self.assertEqual(len(ranged), 1)
            self.assertEqual(ranged[0]["newText"], "start {\n    value=1\n    other = 2\n}\n")
            self.send(process, {
                "jsonrpc": "2.0",
                "id": 6,
                "method": "textDocument/rangeFormatting",
                "params": {
                    "textDocument": {"uri": uri},
                    "range": {
                        "start": {"line": 1, "character": 0},
                        "end": {"line": 2, "character": 0},
                    },
                },
            })
            other = self.read(process)["result"]
            self.assertEqual(other[0]["newText"], "start {\n    value = 1\n    other=2\n}\n")
            self.send(process, {
                "jsonrpc": "2.0",
                "method": "textDocument/didChange",
                "params": {
                    "textDocument": {"uri": uri, "version": 4},
                    "contentChanges": [{"text": "start {\n    print(1) print(2)\n}\n"}],
                },
            })
            self.read(process)
            self.send(process, {
                "jsonrpc": "2.0",
                "id": 7,
                "method": "textDocument/formatting",
                "params": {"textDocument": {"uri": uri}},
            })
            failed = self.read(process)
            self.assertEqual(failed["error"]["code"], -32603)
            self.assertIn("expected newline after statement", failed["error"]["message"])
            self.send(process, {"jsonrpc": "2.0", "id": 8, "method": "shutdown"})
            self.assertIsNone(self.read(process)["result"])
            self.send(process, {"jsonrpc": "2.0", "method": "exit"})
            process.stdin.close()
            self.assertEqual(process.wait(timeout=5), 0)
        finally:
            if process.poll() is None:
                process.kill()

    def test_formatting_reports_a_bad_style_file(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".cwhip-format"
            config.write_text("TabWidth: 4\n", encoding="utf-8")
            process = subprocess.Popen(
                [str(self.args.server)],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                cwd=directory,
            )
            try:
                uri = "file:///tmp/styled.cw"
                self.open_document(process, uri, "start {\n    print(1)\n}\n")
                self.send(process, {
                    "jsonrpc": "2.0",
                    "id": 9,
                    "method": "textDocument/formatting",
                    "params": {"textDocument": {"uri": uri}},
                })
                failed = self.read(process)
                self.assertEqual(failed["error"]["code"], -32603)
                self.assertIn("unknown key: TabWidth", failed["error"]["message"])
                self.send(process, {"jsonrpc": "2.0", "id": 10, "method": "shutdown"})
                self.assertIsNone(self.read(process)["result"])
                self.send(process, {"jsonrpc": "2.0", "method": "exit"})
                process.stdin.close()
                self.assertEqual(process.wait(timeout=5), 0)
            finally:
                if process.poll() is None:
                    process.kill()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--server", required=True, type=Path)
    LanguageServerTests.args, remaining = parser.parse_known_args()
    unittest.main(argv=[__import__("sys").argv[0], *remaining])
