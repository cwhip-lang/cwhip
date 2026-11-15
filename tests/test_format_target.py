#!/usr/bin/env python3
"""The format target runs cwhip-format -i on repository Cwhip sources."""

import argparse
from pathlib import Path
import os
import subprocess
import tempfile
import unittest


class FormatTargetTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "source tree"
        self.record = Path(self.temp.name) / "record"
        self.record.mkdir()
        self.bin = Path(self.temp.name) / "bin"
        self.bin.mkdir()
        self.write_tree()

    def write_tree(self):
        files = {
            "builtin/String.cw": "start {}\n",
            "stdlib/pkg/lib.cw": "start {}\n",
            "tools/cwhip-format.cw": "start {}\n",
            "examples/hello.cw": "start {}\n",
            "examples/nested/more.cw": "start {}\n",
            "examples/out/generated.cw": "start {}\n",
            "tests/ok.cw": "start {}\n",
            "tests/build.cw": "start {}\n",
            "tests/build/skip.cw": "start {}\n",
            "share/staged.cw": "start {}\n",
            "src/nope.cw": "start {}\n",
            "build/generated.cw": "start {}\n",
        }
        for relative, text in files.items():
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8")
        (self.root / ".cwhip-format").write_text("ColumnLimit: 80\n", encoding="utf-8")

    def install_tool(self):
        tool = self.bin / "cwhip-format"
        tool.write_text(
            "#!/bin/sh\n"
            "printf '%s\\n' \"$PWD\" > \"$CWHIP_FORMAT_RECORD/cwd\"\n"
            "printf '%s\\n' \"$@\" > \"$CWHIP_FORMAT_RECORD/args\"\n"
            "exit \"${CWHIP_FORMAT_STATUS:-0}\"\n",
            encoding="utf-8",
        )
        tool.chmod(0o755)
        return tool

    def run_script(self, hint, path, status="0", find_system=False):
        env = os.environ.copy()
        env["CWHIP_FORMAT_RECORD"] = str(self.record)
        env["CWHIP_FORMAT_STATUS"] = status
        env["PATH"] = path
        find = "ON" if find_system else "OFF"
        return subprocess.run(
            [
                str(self.args.cmake),
                f"-DCWHIP_SOURCE_DIR={self.root}",
                f"-DCWHIP_BINARY_DIR={self.root / 'examples' / 'out'}",
                f"-DCWHIP_FORMAT_HINT={hint}",
                f"-DCMAKE_FIND_USE_CMAKE_PATH={find}",
                f"-DCMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH={find}",
                f"-DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH={find}",
                f"-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH={find}",
                "-P",
                str(self.args.script),
            ],
            text=True,
            capture_output=True,
            check=False,
            env=env,
        )

    def expected_files(self):
        relative = [
            "builtin/String.cw",
            "stdlib/pkg/lib.cw",
            "tools/cwhip-format.cw",
            "examples/hello.cw",
            "examples/nested/more.cw",
            "tests/ok.cw",
            "tests/build.cw",
        ]
        return sorted(str(self.root / name) for name in relative)

    def test_missing_tool_names_cwhip_format(self):
        result = self.run_script(self.root / "missing", "")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("cwhip-format is not available", result.stderr)
        self.assertFalse((self.record / "args").exists())
        self.assertEqual((self.root / "builtin/String.cw").read_text(encoding="utf-8"), "start {}\n")

    def test_present_tool_formats_sources_in_place(self):
        self.install_tool()
        result = self.run_script(self.bin, "")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = (self.record / "args").read_text(encoding="utf-8").splitlines()
        self.assertEqual(args[0], "-i")
        self.assertNotIn("cmake-format", args)
        self.assertEqual(args[1:], self.expected_files())
        self.assertEqual((self.record / "cwd").read_text(encoding="utf-8").strip(), str(self.root))
        self.assertTrue((self.root / ".cwhip-format").is_file())

    def test_tool_on_path_is_used(self):
        self.install_tool()
        result = self.run_script(self.root / "missing", str(self.bin), find_system=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        args = (self.record / "args").read_text(encoding="utf-8").splitlines()
        self.assertEqual(args[0], "-i")
        self.assertEqual(args[1:], self.expected_files())

    def test_tool_failure_fails_the_target(self):
        self.install_tool()
        result = self.run_script(self.bin, "", status="4")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("cwhip-format failed with status 4", result.stderr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--cmake", required=True, type=Path)
    parser.add_argument("--script", required=True, type=Path)
    FormatTargetTests.args, remaining = parser.parse_known_args()
    unittest.main(argv=[__import__("sys").argv[0], *remaining])
