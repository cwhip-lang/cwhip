#!/usr/bin/env python3
"""Command-line tests for cwhip-format."""

import argparse
from pathlib import Path
import os
import subprocess
import tempfile
import unittest


class FormatCommandTests(unittest.TestCase):
    def run_tool(self, *args):
        return subprocess.run(
            [str(self.args.cwhip_format), *args],
            input=None,
            text=True,
            capture_output=True,
            check=False,
        )

    def compiler_version(self):
        compiler = self.args.cwhip_format.parent / "cwhip"
        result = subprocess.run(
            [str(compiler), "--version"], text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        text = result.stdout
        self.assertTrue(text.startswith("cwhip: v"), text)
        return text.removeprefix("cwhip: v")

    def test_help(self):
        for flag in ("--help", "-h"):
            result = self.run_tool(flag)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(
                result.stdout.startswith("Usage: cwhip-format [options] <file...>"),
                result.stdout)
            self.assertIn("-i, --in-place", result.stdout)
            self.assertIn("      --dump-config\tWrite the built-in default configuration",
                          result.stdout)
            self.assertNotIn("-d, --dump-config", result.stdout)
            self.assertIn("file", result.stdout)
            self.assertIn("Cwhip source file", result.stdout)

    def test_version(self):
        version = self.compiler_version()
        for flag in ("--version", "-V"):
            result = self.run_tool(flag)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "cwhip-format: v" + version)

    def test_dump_config(self):
        result = self.run_tool("--dump-config")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        lines = result.stdout.splitlines()
        self.assertEqual(len(lines), 78)
        self.assertEqual(len(lines) % 2, 0)
        self.assertTrue(result.stdout.endswith("\n"))
        keys = []
        for index in range(0, len(lines), 2):
            comment, key = lines[index], lines[index + 1]
            self.assertTrue(comment.startswith("# "), comment)
            self.assertGreater(len(comment.strip()), 2, comment)
            self.assertRegex(key, r"^[A-Za-z]+: \S+$", key)
            keys.append(key)
        self.assertIn("Language: Cwhip", keys)
        self.assertIn("ContinuationIndentWidth: 8", keys)
        self.assertIn("ColumnLimit: 80", keys)
        self.assertIn("UseTab: Never", keys)
        self.assertIn("PreserveBlockCommentNewlines: true", keys)
        self.assertIn("NewlineBeforeOpenBrace: false", keys)
        self.assertIn("NewlineAfterOpenBrace: true", keys)
        self.assertIn("NewlineAfterCloseBrace: true", keys)
        for key in (
            "BreakBeforeBinaryOperators",
            "BraceBinding",
            "CommentPragmas",
            "SpaceBeforeParens",
        ):
            self.assertNotIn(key, result.stdout)

        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".cwhip-format"
            config.write_text("ColumnLimit: 0\nLanguage: Cwhip\n", encoding="utf-8")
            path = Path(directory) / "sample.cw"
            original = "start { print(1) }\n"
            path.write_text(original, encoding="utf-8")
            before = path.stat().st_mtime_ns
            dumped = subprocess.run(
                [str(self.args.cwhip_format), "-i", str(path), "--dump-config"],
                text=True,
                capture_output=True,
                check=False,
                cwd=directory,
            )
            self.assertEqual(dumped.returncode, 0, dumped.stderr)
            self.assertEqual(dumped.stderr, "")
            self.assertEqual(dumped.stdout, result.stdout)
            self.assertIn("ColumnLimit: 80", dumped.stdout.splitlines())
            self.assertEqual(path.read_text(encoding="utf-8"), original)
            self.assertEqual(path.stat().st_mtime_ns, before)
            missing = Path(directory) / "missing.cw"
            absent = subprocess.run(
                [str(self.args.cwhip_format), "--dump-config", str(missing)],
                text=True,
                capture_output=True,
                check=False,
                cwd=directory,
            )
            self.assertEqual(absent.returncode, 0, absent.stderr)
            self.assertEqual(absent.stdout, result.stdout)
            self.assertFalse(missing.exists())
            unknown = subprocess.run(
                [str(self.args.cwhip_format), "--dump-config", "--not-an-option"],
                text=True,
                capture_output=True,
                check=False,
                cwd=directory,
            )
            self.assertEqual(unknown.returncode, 2)
            self.assertIn("unknown option: --not-an-option", unknown.stderr)

    def test_no_files(self):
        result = self.run_tool()
        self.assertEqual(result.returncode, 2)
        self.assertIn("required argument not found: file", result.stderr)
        self.assertIn("Usage: cwhip-format [options] <file...>", result.stderr)

    def test_unknown_flag(self):
        result = self.run_tool("--not-an-option")
        self.assertEqual(result.returncode, 2)
        self.assertIn("unknown option: --not-an-option", result.stderr)
        short = self.run_tool("-x")
        self.assertEqual(short.returncode, 2)
        self.assertIn("unknown option: -x", short.stderr)

    def test_stdout_concatenates_and_leaves_files(self):
        with tempfile.TemporaryDirectory() as directory:
            first = Path(directory) / "first.cw"
            second = Path(directory) / "second.cw"
            first.write_text("start {\n    print(1)\n}\n", encoding="utf-8")
            second.write_text("start {\n    print(2)\n}\n", encoding="utf-8")
            before = (first.read_bytes(), second.read_bytes())
            result = self.run_tool(str(first), str(second))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "start {\n    print(1)\n}\nstart {\n    print(2)\n}\n")
            self.assertEqual((first.read_bytes(), second.read_bytes()), before)

    def test_in_place_rewrites_once(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.cw"
            path.write_text("start { print(1) }\n", encoding="utf-8")
            formatted = self.run_tool(str(path))
            self.assertEqual(formatted.returncode, 0, formatted.stderr)
            self.assertNotEqual(formatted.stdout, "start { print(1) }\n")
            rewritten = self.run_tool("-i", str(path))
            self.assertEqual(rewritten.returncode, 0, rewritten.stderr)
            self.assertEqual(path.read_text(encoding="utf-8"), formatted.stdout)
            previous = path.stat().st_mtime_ns
            os.utime(path, ns=(previous, previous))
            again = self.run_tool("--in-place", str(path))
            self.assertEqual(again.returncode, 0, again.stderr)
            self.assertEqual(path.stat().st_mtime_ns, previous)
            self.assertEqual(path.read_text(encoding="utf-8"), formatted.stdout)
            self.assertFalse((Path(str(path) + ".cwhip-format-tmp")).exists())

    def test_in_place_keeps_a_file_the_walk_cannot_group(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "bad.cw"
            original = "start {\n    print(1) print(2)\n}\n"
            path.write_text(original, encoding="utf-8")
            mode = path.stat().st_mode
            result = self.run_tool("-i", str(path))
            self.assertEqual(result.returncode, 1)
            self.assertIn(str(path), result.stderr)
            self.assertEqual(path.read_text(encoding="utf-8"), original)
            self.assertEqual(path.stat().st_mode, mode)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--cwhip-format", required=True, type=Path)
    FormatCommandTests.args, remaining = parser.parse_known_args()
    unittest.main(argv=[__import__("sys").argv[0], *remaining])
