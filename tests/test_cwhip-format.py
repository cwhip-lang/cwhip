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
            self.assertIn(
                "-v, --verbose\tPrint each file name when rewriting in place",
                result.stdout)
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
        self.assertEqual(len(lines), 84)
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
        self.assertIn("ReflowBlockComments: false", keys)
        self.assertIn(
            "# Reflow block comments to the column limit.",
            result.stdout.splitlines(),
        )
        self.assertIn("NewlineBeforeOpenBrace: false", keys)
        self.assertIn("NewlineAfterOpenBrace: true", keys)
        self.assertIn("NewlineAfterCloseBrace: true", keys)
        self.assertIn("NewlineBeforeElse: true", keys)
        self.assertIn("NewlineBeforeExcept: true", keys)
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
            mtimes = (first.stat().st_mtime_ns, second.stat().st_mtime_ns)
            result = self.run_tool(str(first), str(second))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "start {\n    print(1)\n}\nstart {\n    print(2)\n}\n")
            self.assertEqual((first.read_bytes(), second.read_bytes()), before)
            self.assertEqual((first.stat().st_mtime_ns, second.stat().st_mtime_ns), mtimes)

    def test_verbose_prints_in_place_names(self):
        with tempfile.TemporaryDirectory() as directory:
            first = Path(directory) / "first.cw"
            second = Path(directory) / "second.cw"
            first.write_text("start { print(1) }\n", encoding="utf-8")
            second.write_text("start { print(2) }\n", encoding="utf-8")
            quiet = self.run_tool("-i", str(first), str(second))
            self.assertEqual(quiet.returncode, 0, quiet.stderr)
            self.assertEqual(quiet.stdout, "")
            self.assertEqual(quiet.stderr, "")
            self.assertNotIn("first.cw", quiet.stdout)
            self.assertNotIn("second.cw", quiet.stdout)
            self.assertEqual(
                first.read_text(encoding="utf-8"),
                "start {\n    print(1)\n}\n")
            self.assertEqual(
                second.read_text(encoding="utf-8"),
                "start {\n    print(2)\n}\n")
            loud = self.run_tool("-v", "--in-place", str(first), str(second))
            self.assertEqual(loud.returncode, 0, loud.stderr)
            self.assertEqual(loud.stdout, "")
            self.assertEqual(loud.stderr, f"{first}\n{second}\n")
            self.assertEqual(
                first.read_text(encoding="utf-8"),
                "start {\n    print(1)\n}\n")
            long_form = self.run_tool("--verbose", "-i", str(first))
            self.assertEqual(long_form.returncode, 0, long_form.stderr)
            self.assertEqual(long_form.stdout, "")
            self.assertEqual(long_form.stderr, f"{first}\n")
            shown = self.run_tool("-v", str(first), str(second))
            self.assertEqual(shown.returncode, 0, shown.stderr)
            self.assertEqual(shown.stderr, "")
            self.assertNotIn(str(first), shown.stdout)
            self.assertNotIn("first.cw", shown.stdout)
            self.assertEqual(
                shown.stdout,
                "start {\n    print(1)\n}\nstart {\n    print(2)\n}\n")
            missing = Path(directory) / "missing.cw"
            failed = self.run_tool("-v", "-i", str(missing))
            self.assertEqual(failed.returncode, 1)
            self.assertEqual(failed.stdout, "")
            self.assertTrue(failed.stderr.startswith(f"{missing}\n"), failed.stderr)
            self.assertIn("cannot read file", failed.stderr)

    def test_in_place_rewrites_once(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.cw"
            path.write_text("start { print(1) }\n", encoding="utf-8")
            formatted = self.run_tool(str(path))
            self.assertEqual(formatted.returncode, 0, formatted.stderr)
            self.assertNotEqual(formatted.stdout, "start { print(1) }\n")
            rewritten = self.run_tool("-i", str(path))
            self.assertEqual(rewritten.returncode, 0, rewritten.stderr)
            self.assertEqual(rewritten.stdout, "")
            self.assertEqual(rewritten.stderr, "")
            self.assertEqual(path.read_text(encoding="utf-8"), formatted.stdout)
            previous = path.stat().st_mtime_ns
            os.utime(path, ns=(previous, previous))
            again = self.run_tool("--in-place", str(path))
            self.assertEqual(again.returncode, 0, again.stderr)
            self.assertEqual(path.stat().st_mtime_ns, previous)
            self.assertEqual(path.read_text(encoding="utf-8"), formatted.stdout)
            self.assertFalse((Path(str(path) + ".cwhip-format-tmp")).exists())

    def test_stdout_failure_keeps_the_original_text(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "bad.cw"
            original = "start {\n    print(1) print(2)\n}\n"
            path.write_text(original, encoding="utf-8")
            before = path.stat().st_mtime_ns
            result = self.run_tool(str(path))
            self.assertEqual(result.returncode, 1)
            self.assertEqual(result.stdout, original)
            self.assertIn(str(path), result.stderr)
            self.assertIn("expected newline after statement", result.stderr)
            self.assertEqual(path.read_text(encoding="utf-8"), original)
            self.assertEqual(path.stat().st_mtime_ns, before)

    def test_missing_and_unreadable_sources_write_nothing(self):
        with tempfile.TemporaryDirectory() as directory:
            missing = Path(directory) / "missing.cw"
            absent = self.run_tool(str(missing))
            self.assertEqual(absent.returncode, 1)
            self.assertEqual(absent.stdout, "")
            self.assertIn(str(missing), absent.stderr)
            self.assertIn("cannot read file", absent.stderr)
            secret = Path(directory) / "secret.cw"
            secret.write_text("start { print(1) }\n", encoding="utf-8")
            os.chmod(secret, 0)
            try:
                blocked = self.run_tool(str(secret))
            finally:
                os.chmod(secret, 0o644)
            self.assertEqual(blocked.returncode, 1)
            self.assertEqual(blocked.stdout, "")
            self.assertIn(str(secret), blocked.stderr)
            self.assertIn("cannot read file", blocked.stderr)
            self.assertEqual(secret.read_text(encoding="utf-8"), "start { print(1) }\n")
            folder = self.run_tool(directory)
            self.assertEqual(folder.returncode, 0, folder.stderr)
            self.assertEqual(folder.stdout, "")
            self.assertEqual(folder.stderr, "")

    def test_bad_config_reports_on_stderr_and_writes_nothing(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".cwhip-format"
            config.write_text("TabWidth: 4\n", encoding="utf-8")
            path = Path(directory) / "sample.cw"
            original = "start { print(1) }\n"
            path.write_text(original, encoding="utf-8")
            result = subprocess.run(
                [str(self.args.cwhip_format), str(path)],
                text=True,
                capture_output=True,
                check=False,
                cwd=directory,
            )
            self.assertEqual(result.returncode, 1)
            self.assertEqual(result.stdout, "")
            self.assertIn("unknown key: TabWidth", result.stderr)
            self.assertIn(str(config), result.stderr)
            self.assertEqual(path.read_text(encoding="utf-8"), original)

    def test_a_failed_file_does_not_stop_the_list(self):
        with tempfile.TemporaryDirectory() as directory:
            bad = Path(directory) / "bad.cw"
            good = Path(directory) / "good.cw"
            later = Path(directory) / "later.cw"
            missing = Path(directory) / "missing.cw"
            bad_text = "start {\n    print(1) print(2)\n}\n"
            good_text = "start { print(1) }\n"
            later_text = "start { print(2) }\n"
            bad.write_text(bad_text, encoding="utf-8")
            good.write_text(good_text, encoding="utf-8")
            later.write_text(later_text, encoding="utf-8")
            formatted_good = "start {\n    print(1)\n}\n"
            formatted_later = "start {\n    print(2)\n}\n"
            result = self.run_tool(str(bad), str(good), str(missing), str(later))
            self.assertEqual(result.returncode, 1)
            self.assertEqual(result.stdout, bad_text + formatted_good + formatted_later)
            self.assertIn(str(bad), result.stderr)
            self.assertIn(str(missing), result.stderr)
            self.assertNotIn(str(good), result.stderr)
            self.assertEqual(bad.read_text(encoding="utf-8"), bad_text)
            self.assertEqual(good.read_text(encoding="utf-8"), good_text)
            self.assertEqual(later.read_text(encoding="utf-8"), later_text)

    def test_in_place_rewrites_every_file_and_keeps_going(self):
        with tempfile.TemporaryDirectory() as directory:
            first = Path(directory) / "first.cw"
            second = Path(directory) / "second.cw"
            first.write_text("start { print(1) }\n", encoding="utf-8")
            second.write_text("start { print(2) }\n", encoding="utf-8")
            result = self.run_tool("-i", str(first), str(second))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "")
            self.assertEqual(result.stderr, "")
            self.assertEqual(first.read_text(encoding="utf-8"), "start {\n    print(1)\n}\n")
            self.assertEqual(second.read_text(encoding="utf-8"), "start {\n    print(2)\n}\n")
            self.assertFalse((Path(str(first) + ".cwhip-format-tmp")).exists())
            self.assertFalse((Path(str(second) + ".cwhip-format-tmp")).exists())
            bad = Path(directory) / "bad.cw"
            bad_text = "start {\n    print(1) print(2)\n}\n"
            bad.write_text(bad_text, encoding="utf-8")
            third = Path(directory) / "third.cw"
            third.write_text("start { print(3) }\n", encoding="utf-8")
            mixed = self.run_tool("-i", str(bad), str(third))
            self.assertEqual(mixed.returncode, 1)
            self.assertEqual(mixed.stdout, "")
            self.assertIn(str(bad), mixed.stderr)
            self.assertEqual(bad.read_text(encoding="utf-8"), bad_text)
            self.assertEqual(third.read_text(encoding="utf-8"), "start {\n    print(3)\n}\n")

    def test_help_and_version_stop_before_files(self):
        with tempfile.TemporaryDirectory() as directory:
            missing = Path(directory) / "missing.cw"
            for flag in ("--help", "-h"):
                result = subprocess.run(
                    [str(self.args.cwhip_format), flag, str(missing)],
                    text=True,
                    capture_output=True,
                    check=False,
                    cwd=directory,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(
                    result.stdout.startswith("Usage: cwhip-format [options] <file...>"),
                    result.stdout)
                self.assertNotIn("cannot read file", result.stderr)
                self.assertFalse(missing.exists())
            version = self.compiler_version()
            for flag in ("--version", "-V"):
                result = subprocess.run(
                    [str(self.args.cwhip_format), flag, str(missing)],
                    text=True,
                    capture_output=True,
                    check=False,
                    cwd=directory,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, "cwhip-format: v" + version)
                self.assertNotIn("cannot read file", result.stderr)

    def test_double_dash_takes_a_path_that_starts_with_a_dash(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "-sample.cw"
            original = "start { print(1) }\n"
            path.write_text(original, encoding="utf-8")
            bare = subprocess.run(
                [str(self.args.cwhip_format), "-sample.cw"],
                text=True,
                capture_output=True,
                check=False,
                cwd=directory,
            )
            self.assertEqual(bare.returncode, 2)
            self.assertIn("unknown option", bare.stderr)
            self.assertEqual(path.read_text(encoding="utf-8"), original)
            dashed = subprocess.run(
                [str(self.args.cwhip_format), "--", "-sample.cw"],
                text=True,
                capture_output=True,
                check=False,
                cwd=directory,
            )
            self.assertEqual(dashed.returncode, 0, dashed.stderr)
            self.assertEqual(dashed.stdout, "start {\n    print(1)\n}\n")
            self.assertEqual(path.read_text(encoding="utf-8"), original)

    def test_config_comes_from_the_current_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sub = root / "sub"
            sub.mkdir()
            (root / ".cwhip-format").write_text("ColumnLimit: 0\n", encoding="utf-8")
            (sub / ".cwhip-format").write_text("ColumnLimit: 40\n", encoding="utf-8")
            source = (
                "start {\n"
                "    print(alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, kappa, "
                "lambda, mu)\n"
                "}\n"
            )
            path = sub / "sample.cw"
            path.write_text(source, encoding="utf-8")
            from_parent = subprocess.run(
                [str(self.args.cwhip_format), str(path)],
                text=True,
                capture_output=True,
                check=False,
                cwd=root,
            )
            self.assertEqual(from_parent.returncode, 0, from_parent.stderr)
            self.assertEqual(from_parent.stdout, source)
            from_file = subprocess.run(
                [str(self.args.cwhip_format), "sample.cw"],
                text=True,
                capture_output=True,
                check=False,
                cwd=sub,
            )
            self.assertEqual(from_file.returncode, 0, from_file.stderr)
            self.assertNotEqual(from_file.stdout, source)
            self.assertIn("\n            alpha,\n", from_file.stdout)
            self.assertEqual(path.read_text(encoding="utf-8"), source)

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
