#!/usr/bin/env python3
"""Offline integration tests for the cwhip-pkg command."""

from __future__ import annotations

import argparse
import hashlib
import importlib.machinery
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import tempfile
import tomllib
import unittest
from unittest import mock
import zipfile


def run(command: list[str], *, cwd: Path | None = None, env: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(
        command,
        cwd=cwd,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        stdin=subprocess.DEVNULL,
        timeout=30,
        check=False,
    )


class CwhipkgTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.git = shutil.which("git")
        if cls.git is None:
            raise RuntimeError("git is required for cwhip-pkg integration tests")

    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix=".cwhip-pkg-test-", dir=Path.cwd())
        self.root = Path(self.temporary.name)
        self.project = self.root / "project"
        self.project.mkdir()
        self.bin_directory = self.root / "fake-bin"
        self.bin_directory.mkdir()
        self.remote_map: dict[str, str] = {}
        fake_git = self.bin_directory / "git"
        fake_git.write_text(
            "#!" + os.sys.executable + "\n"
            "import json, os, subprocess, sys\n"
            "args = sys.argv[1:]\n"
            "with open(os.environ['cwhip-pkg_TEST_GIT_LOG'], 'a') as log:\n"
            "    log.write(json.dumps(args) + '\\n')\n"
            "remotes = json.loads(os.environ.get('cwhip-pkg_TEST_GIT_REMOTES', '{}'))\n"
            "for index, argument in enumerate(args):\n"
            "    if argument.startswith('https://github.com/'):\n"
            "        if argument not in remotes:\n"
            "            print('test git: unmapped remote ' + argument, file=sys.stderr)\n"
            "            raise SystemExit(1)\n"
            "        args[index] = remotes[argument]\n"
            "raise SystemExit(subprocess.run(["
            + repr(self.git)
            + ", *args], check=False).returncode)\n",
            encoding="utf-8",
        )
        fake_git.chmod(0o755)
        self.base_environment = os.environ.copy()
        self.base_environment["PATH"] = str(self.bin_directory) + os.pathsep + self.base_environment.get("PATH", "")
        self.base_environment["cwhip-pkg_TEST_GIT_REMOTES"] = json.dumps(self.remote_map)
        self.git_log = self.root / "git.log"
        self.base_environment["cwhip-pkg_TEST_GIT_LOG"] = str(self.git_log)
        self.base_environment.pop("XDG_CONFIG_HOME", None)
        for name in (
            "CWHIP_SDK",
            "CWHIP_HOME",
            "CWHIP_MODULE_DIR",
            "CWHIP_PACKAGE_PATH",
            "CWHIP_MODULE_REGISTRY",
            "CWHIP_STDLIB_MODULE_DIR",
        ):
            self.base_environment.pop(name, None)
        self.base_environment["HOME"] = str(self.root / "home")
        Path(self.base_environment["HOME"]).mkdir()
        self.init_project()

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def run_cwhip_pkg(
        self,
        *arguments: str,
        cwd: Path | None = None,
        env: dict | None = None,
    ) -> subprocess.CompletedProcess:
        child_environment = self.base_environment.copy()
        child_environment["cwhip-pkg_TEST_GIT_REMOTES"] = json.dumps(self.remote_map)
        if env:
            child_environment.update(env)
        return run(
            [os.sys.executable, str(self.args.cwhip_pkg), *arguments],
            cwd=cwd or self.project,
            env=child_environment,
        )

    def init_project(self) -> None:
        result = self.run_cwhip_pkg("init")
        self.assertEqual(result.returncode, 0, result.stderr)

    def lock(self) -> dict:
        return tomllib.loads((self.project / "cwhip-pkg.lock").read_text())

    def project_manifest(self) -> dict:
        return tomllib.loads((self.project / "cwhip-pkg.toml").read_text())

    def script_module(self):
        loader = importlib.machinery.SourceFileLoader("cwhip-pkg_test_subject", str(self.args.cwhip_pkg))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        module = importlib.util.module_from_spec(spec)
        loader.exec_module(module)
        return module

    def make_remote(
        self,
        repository: str,
        manifests: dict[str, str],
        *,
        create_source: bool = True,
        source_content: str = "class Greeter { public: int64 answer() { return(42) } }\n",
    ) -> None:
        working = self.root / f"{repository}-work"
        working.mkdir()
        self.git_run(["init", "-q", str(working)])
        for version, manifest in manifests.items():
            (working / "cwhip-package.toml").write_text(manifest, encoding="utf-8")
            source = manifest.split('source = "', 1)[1].split('"', 1)[0]
            source_path = working / source
            source_path.parent.mkdir(parents=True, exist_ok=True)
            if create_source and not source_path.exists():
                source_path.write_text(source_content, encoding="utf-8")
            self.git_run(["-C", str(working), "add", "."])
            self.git_run(
                [
                    "-C",
                    str(working),
                    "-c",
                    "user.name=Test",
                    "-c",
                    "user.email=test@example.invalid",
                    "commit",
                    "-q",
                    "-m",
                    version,
                ]
            )
            self.git_run(["-C", str(working), "tag", version])
        bare = self.root / f"{repository}.git"
        self.git_run(["clone", "-q", "--bare", str(working), str(bare)])
        self.remote_map[f"https://github.com/acme/{repository}.git"] = bare.as_uri()

    def git_run(self, arguments: list[str]) -> None:
        result = run([self.git, *arguments])
        if result.returncode:
            raise AssertionError(f"git command failed: {result.stdout}{result.stderr}")

    @staticmethod
    def manifest(
        name: str = "greeting",
        version: str = "1.0.0",
        source: str = "greeting.cw",
        export: str = "class:Greeter",
        extras: str = "",
    ) -> str:
        return (
            "[package]\n"
            'sdk-abi = "numeric-v2"\n'
            f'name = "{name}"\n'
            f'version = "{version}"\n'
            f'source = "{source}"\n'
            f'export = "{export}"\n'
            f"{extras}"
        )

    def test_init_creates_manifest_and_complete_builtin_lock(self) -> None:
        self.assertEqual(self.project_manifest(), {"schema": 1, "sources": {}})
        self.assertFalse((self.project / "modules/modules.toml").exists())
        lock = self.lock()
        self.assertEqual(lock["schema"], 1)
        self.assertEqual(lock["modules"]["math"], ["0.1.0"])
        self.assertEqual(lock["modules"]["system"], ["0.1.0"])
        self.assertNotIn("String", lock["modules"])
        for entry in lock["packages"].values():
            self.assertEqual(entry["repo"], "builtin")
            self.assertEqual(entry["ref"], "builtin")
            self.assertEqual(len(entry["sha256"]), 64)
        verified = self.run_cwhip_pkg("install")
        self.assertEqual(verified.returncode, 0, verified.stderr)

    def make_template(self) -> Path:
        root = self.root / "template"
        (root / "src").mkdir(parents=True)
        (root / "scripts").mkdir()
        (root / "doc").mkdir()
        (root / ".git").mkdir()
        (root / ".git/history").write_text("must not be copied")
        (root / "CMakeLists.txt").write_text(
            "cmake_minimum_required(VERSION 3.24)\n"
            "project(cwhip_template LANGUAGES C)\n"
            "find_package(Cwhip 0.0.2 EXACT CONFIG REQUIRED)\n"
            'cwhip_add_program(hello SOURCE "${PROJECT_SOURCE_DIR}/src/main.cw")\n'
            "get_target_property(hello_executable hello CWHIP_EXECUTABLE)\n"
            'install(PROGRAMS "${hello_executable}" DESTINATION bin)\n'
        )
        (root / "src/main.cw").write_text('start { print("Hello, world!") }\n')
        (root / "scripts/setup").write_text("#!/bin/sh\nexit 0\n")
        (root / "scripts/setup").chmod(0o755)
        (root / "README.md").write_text("# CWhip project template\nRun bin/hello\n")
        (root / "doc/BUILDING.md").write_text("Build cwhip_template; run bin/hello\n")
        return root

    def assert_new_project(self, destination: Path) -> None:
        self.assertFalse((destination / ".git").exists())
        self.assertIn("project(MyApp LANGUAGES C)", (destination / "CMakeLists.txt").read_text())
        self.assertIn("cwhip_add_program(MyApp ", (destination / "CMakeLists.txt").read_text())
        self.assertIn("MyApp_executable MyApp", (destination / "CMakeLists.txt").read_text())
        self.assertIn("${MyApp_executable}", (destination / "CMakeLists.txt").read_text())
        self.assertEqual((destination / "README.md").read_text(), "# MyApp\nRun bin/MyApp\n")
        self.assertEqual((destination / "doc/BUILDING.md").read_text(), "Build MyApp; run bin/MyApp\n")
        self.assertTrue(os.access(destination / "scripts/setup", os.X_OK))
        self.assertEqual((destination / "src/main.cw").read_text(), 'start { print("Hello, world!") }\n')
        self.assertEqual(list(destination.parent.glob(".cwhip-new-*")), [])

    def test_new_directory_and_archives_rename_without_history_or_network(self) -> None:
        template = self.make_template()
        tar_path = self.root / "template.tar.gz"
        zip_path = self.root / "template.zip"
        with tarfile.open(tar_path, "w:gz") as archive:
            archive.add(template, arcname="app-template-main")
        with zipfile.ZipFile(zip_path, "w") as archive:
            for path in template.rglob("*"):
                archive.write(path, "app-template-main/" + path.relative_to(template).as_posix())
        module = self.script_module()
        for index, source in enumerate((template, tar_path, zip_path)):
            destination = self.root / f"destination {index}"
            if index == 1:
                destination.mkdir()  # An existing empty directory is allowed.
            with mock.patch.object(module.urllib.request, "urlopen", side_effect=AssertionError("network")), \
                    mock.patch.object(module.subprocess, "run", side_effect=AssertionError("subprocess")):
                module.command_new("MyApp", str(destination), "main", str(source))
            self.assert_new_project(destination)
        default = self.run_cwhip_pkg("new", "MyApp", "--source", str(template))
        self.assertEqual(default.returncode, 0, default.stderr)
        self.assert_new_project(self.project / "MyApp")
        self.assertIn("no Git repository initialized", default.stdout)
        self.assertIn("project(cwhip_template", (template / "CMakeLists.txt").read_text())

    def test_new_ref_download_and_transport_failure_are_mocked(self) -> None:
        template = self.make_template()
        archive_bytes = io.BytesIO()
        with tarfile.open(fileobj=archive_bytes, mode="w:gz") as archive:
            archive.add(template, arcname="template-ref")
        module = self.script_module()
        destination = self.root / "downloaded"
        with mock.patch.object(module.urllib.request, "urlopen",
                               return_value=io.BytesIO(archive_bytes.getvalue())) as download:
            module.command_new("MyApp", str(destination), "feature/starter", None)
        self.assertIn("/tar.gz/feature%2Fstarter", download.call_args.args[0])
        self.assert_new_project(destination)
        with mock.patch.object(module.urllib.request, "urlopen", side_effect=OSError("offline")):
            with self.assertRaises(module.CwhipkgError) as caught:
                module.command_new("MyApp", str(self.root / "failed"), "main", None)
        self.assertEqual(caught.exception.code, "PKG3002")
        self.assertIn("offline", str(caught.exception))
        self.assertFalse((self.root / "failed").exists())
        self.assertEqual(list(self.root.glob(".cwhip-new-*")), [])
        with mock.patch.object(module.urllib.request, "urlopen",
                               return_value=io.BytesIO(archive_bytes.getvalue())), \
                mock.patch.object(module, "TEMPLATE_MAX_DOWNLOAD", 1):
            with self.assertRaises(module.CwhipkgError) as caught:
                module.command_new("MyApp", str(self.root / "oversized"), "main", None)
        self.assertEqual(caught.exception.code, "PKG3002")
        self.assertFalse((self.root / "oversized").exists())

    def test_new_refuses_invalid_names_and_existing_destinations(self) -> None:
        template = self.make_template()
        for name in ("../oops", "a-b", "3app", "_app", "int", "test", "all", "a;b", "é", "a" * 129):
            result = self.run_cwhip_pkg("new", name, "--source", str(template))
            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertIn("error[PKG1003]", result.stderr)
        for destination in (self.project, self.root / "file", self.root / "link"):
            if destination.name == "file":
                destination.write_text("preserved")
            if destination.name == "link":
                destination.symlink_to(template, target_is_directory=True)
            result = self.run_cwhip_pkg("new", "MyApp", str(destination), "--source", str(template))
            self.assertIn("error[PKG1004]", result.stderr)
        self.assertEqual((self.root / "file").read_text(), "preserved")
        self.assertTrue((self.project / "cwhip-pkg.lock").is_file())
        self.assertEqual(list(self.root.glob(".cwhip-new-*")), [])

    def test_new_rejects_unsafe_archives_and_cleans_partial_output(self) -> None:
        module = self.script_module()
        for index, (name, kind) in enumerate((
            ("../escape", "file"), ("/absolute", "file"), ("C:\\escape", "file"),
            ("root/link", "symlink"), ("root/link", "hardlink"), ("root/fifo", "fifo"),
        )):
            source = self.root / f"unsafe{index}.tar"
            with tarfile.open(source, "w") as archive:
                good = tarfile.TarInfo("root/partial")
                good.size = 1
                archive.addfile(good, io.BytesIO(b"x"))
                entry = tarfile.TarInfo(name)
                if kind != "file":
                    entry.type = {"symlink": tarfile.SYMTYPE, "hardlink": tarfile.LNKTYPE,
                                  "fifo": tarfile.FIFOTYPE}[kind]
                    entry.linkname = "../../escape"
                archive.addfile(entry)
            destination = self.root / f"unsafe-output{index}"
            destination.mkdir()
            result = self.run_cwhip_pkg("new", "MyApp", str(destination), "--source", str(source))
            self.assertIn("error[PKG1005]", result.stderr)
            self.assertEqual(list(destination.iterdir()), [])
        source = self.root / "unsafe.zip"
        with zipfile.ZipFile(source, "w") as archive:
            archive.writestr("../escape", "bad")
        result = self.run_cwhip_pkg("new", "MyApp", str(self.root / "zip-output"), "--source", str(source))
        self.assertIn("error[PKG1005]", result.stderr)
        self.assertFalse((self.root / "escape").exists())
        template = self.make_template()
        for limit in ("TEMPLATE_MAX_SIZE", "TEMPLATE_MAX_ENTRIES"):
            with mock.patch.object(module, limit, 1):
                with self.assertRaises(module.CwhipkgError) as caught:
                    module.command_new("MyApp", str(self.root / "limited"), "main", str(template))
            self.assertEqual(caught.exception.code, "PKG1005")
            self.assertFalse((self.root / "limited").exists())
        (template / "link").symlink_to(self.project)
        result = self.run_cwhip_pkg("new", "MyApp", str(self.root / "linked"), "--source", str(template))
        self.assertIn("error[PKG1005]", result.stderr)
        self.assertEqual(list(self.root.glob(".cwhip-new-*")), [])

    def test_new_rejects_bad_template_and_missing_parent(self) -> None:
        template = self.make_template()
        (template / "CMakeLists.txt").write_text("project(other)\n")
        destination = self.root / "bad-template"
        result = self.run_cwhip_pkg("new", "MyApp", str(destination), "--source", str(template))
        self.assertIn("error[PKG1005]", result.stderr)
        self.assertFalse(destination.exists())
        result = self.run_cwhip_pkg("new", "MyApp", str(self.root / "missing/child"), "--source", str(template))
        self.assertIn("error[PKG1004]", result.stderr)
        self.assertFalse((self.root / "missing").exists())
        result = self.run_cwhip_pkg("new", "MyApp", "--ref", "", "--source", str(template))
        self.assertEqual(result.returncode, 2)
        self.assertIn("error[PKG0001]", result.stderr)

    def test_new_cleanup_failure_retains_original_error_and_fails_after_publish(self) -> None:
        module = self.script_module()
        template = self.make_template()
        for fail_before_publish in (False, True):
            stderr = io.StringIO()
            if fail_before_publish:
                (template / "CMakeLists.txt").write_text("unsupported")
            destination = self.root / f"cleanup-{fail_before_publish}"
            with mock.patch.object(module.shutil, "rmtree", side_effect=OSError("cleanup denied")), \
                    mock.patch.object(module.sys, "stderr", stderr):
                with self.assertRaises(module.CwhipkgError) as caught:
                    module.command_new("MyApp", str(destination), "main", str(template))
            self.assertEqual(caught.exception.code, "PKG1005" if fail_before_publish else "PKG9002")
            self.assertIn("error[PKG9002]", stderr.getvalue())
            self.assertIn("cleanup denied", stderr.getvalue())
            self.assertEqual(destination.exists(), not fail_before_publish)

    def test_doctor_sdk_selection_precedence_and_settings_validation(self) -> None:
        module = self.script_module()
        environment = {"HOME": str(self.root / "home"), "XDG_CONFIG_HOME": str(self.root / "xdg")}
        settings = self.root / "home/.config/cwhip/settings.toml"
        settings.parent.mkdir(parents=True)
        settings.write_text(f"sdk_prefix = {json.dumps(str(self.root))}\n")
        with mock.patch.dict(os.environ, environment, clear=True):
            self.assertEqual(module.doctor_sdk_prefix()[0], module.SDK_PREFIX)
            os.environ["XDG_CONFIG_HOME"] = ""
            self.assertEqual(module.doctor_sdk_prefix()[0], self.root)
            for value in ("''", "42", "'relative'", "'/nonexistent/sdk'", "'\\u0000'"):
                settings.write_text("sdk_prefix = " + value)
                with self.assertRaises(module.CwhipkgError) as caught:
                    module.doctor_sdk_prefix()
                self.assertEqual(caught.exception.code, "PKG2003")
            settings.write_text("invalid = [")
            os.environ["CWHIP_SDK"] = str(self.root)
            os.environ["XDG_CONFIG_HOME"] = "relative"
            self.assertEqual(module.doctor_sdk_prefix(), (self.root, "CWHIP_SDK"))
            os.environ.pop("CWHIP_SDK")
            with self.assertRaises(module.CwhipkgError):
                module.doctor_sdk_prefix()
            os.environ["XDG_CONFIG_HOME"] = ""
            with self.assertRaises(module.CwhipkgError):
                module.doctor_sdk_prefix()
            settings.write_text("[editor]\nsdk_prefix = '/ignored'\n")
            self.assertEqual(module.doctor_sdk_prefix()[0], module.SDK_PREFIX)

    def test_doctor_dedicated_sdk_configuration_is_authoritative_and_read_only(self) -> None:
        module = self.script_module()
        environment = {"HOME": str(self.root / "home"), "XDG_CONFIG_HOME": ""}
        directory = self.root / "home/.config/cwhip"
        directory.mkdir(parents=True)
        legacy = directory / "settings.toml"
        settings = directory / "sdk.toml"
        legacy.write_text(f"# keep\nsdk_prefix = {json.dumps(str(self.root))}\n")
        original = legacy.read_bytes()
        with mock.patch.dict(os.environ, environment, clear=True):
            self.assertEqual(module.doctor_sdk_prefix(), (self.root, str(legacy)))
            self.assertFalse(settings.exists())
            self.assertEqual(legacy.read_bytes(), original)
            for content in ("", "# no selection\n", "[editor]\nsdk_prefix = '/ignored'\n"):
                settings.write_text(content)
                self.assertEqual(module.doctor_sdk_prefix()[0], module.SDK_PREFIX)
                self.assertEqual(settings.read_text(), content)
            for content in ("invalid = [", "sdk_prefix = ''", "sdk_prefix = 42",
                            "sdk_prefix = 'relative'", "sdk_prefix = '/nonexistent/sdk'",
                            'sdk_prefix = "\\u0000"', 'sdk_prefix = "/tmp\\n"',
                            'sdk_prefix = "/tmp\\r"'):
                settings.write_text(content)
                with self.assertRaises(module.CwhipkgError) as caught:
                    module.doctor_sdk_prefix()
                self.assertEqual(caught.exception.code, "PKG2003")
                self.assertIn(str(settings), str(caught.exception))
                self.assertEqual(settings.read_text(), content)
            settings.unlink()
            settings.mkdir()
            with self.assertRaises(module.CwhipkgError):
                module.doctor_sdk_prefix()
            settings.rmdir()
            settings.symlink_to(directory / "missing.toml")
            with self.assertRaises(module.CwhipkgError):
                module.doctor_sdk_prefix()
            settings.unlink()
            settings.write_text("invalid = [")
            with mock.patch.object(Path, "open", side_effect=PermissionError("read denied")):
                with self.assertRaises(module.CwhipkgError) as caught:
                    module.doctor_sdk_prefix()
            self.assertIn(str(settings), str(caught.exception))
            self.assertIn("read denied", str(caught.exception))
            os.environ["CWHIP_SDK"] = str(self.root)
            self.assertEqual(module.doctor_sdk_prefix(), (self.root, "CWHIP_SDK"))
            os.environ["CWHIP_SDK"] = ""
            settings.write_text(f"sdk_prefix = {json.dumps(str(self.project))}\n")
            legacy.write_text("invalid = [")
            self.assertEqual(module.doctor_sdk_prefix(), (self.project, str(settings)))
            xdg = self.root / "xdg"
            os.environ["XDG_CONFIG_HOME"] = str(xdg)
            self.assertEqual(module.doctor_sdk_prefix()[0], module.SDK_PREFIX)
            (xdg / "cwhip").mkdir(parents=True)
            xdg_settings = xdg / "cwhip/sdk.toml"
            xdg_settings.write_text(f"sdk_prefix = {json.dumps(str(self.root))}\n")
            self.assertEqual(module.doctor_sdk_prefix(), (self.root, str(xdg_settings)))
            self.assertEqual(legacy.read_text(), "invalid = [")
            os.environ.clear()
            self.assertEqual(module.doctor_sdk_prefix()[0], module.SDK_PREFIX)
            os.environ["HOME"] = "relative"
            with self.assertRaises(module.CwhipkgError):
                module.doctor_sdk_prefix()

    def test_sdk_registration_survives_app_preference_rewrites(self) -> None:
        module = self.script_module()
        directory = self.root / "home/.config/cwhip"
        directory.mkdir(parents=True)
        legacy = directory / "settings.toml"
        legacy.write_text("# preferences\nsdk_prefix = '/old/sdk'\n[editor]\nsize = 12\n")
        original = legacy.read_bytes()
        environment = {**self.base_environment, "DESTDIR": "", "XDG_CONFIG_HOME": ""}
        result = run(["cmake", f"-DCWHIP_SDK_PREFIX={self.root}", "-P",
                      str(Path(__file__).resolve().parents[1] / "cmake/CwhipRegisterSdk.cmake")],
                     env=environment)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(legacy.read_bytes(), original)
        settings = directory / "sdk.toml"
        registered = settings.read_bytes()
        with mock.patch.dict(os.environ, environment, clear=True):
            for preferences in ("version = 1\n[editor]\nsize = 14\n", "invalid = [", ""):
                legacy.write_text(preferences)
                self.assertEqual(module.doctor_sdk_prefix(), (self.root, str(settings)))
                self.assertEqual(settings.read_bytes(), registered)
                self.assertEqual(legacy.read_text(), preferences)

    def test_doctor_pass_fail_optional_checks_and_no_side_effects(self) -> None:
        module = self.script_module()
        prefix = self.root / "sdk"
        prefix.mkdir()
        # Mirror the configured installation directories, including custom libdirs.
        script = self.args.cwhip_pkg.read_text()
        for relative in re.findall(r'prefix / "([^"@]+)"', script):
            path = prefix / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture")
            if path.name == "cwhip":
                path.chmod(0o755)
        shutil.copytree(module.STDLIB_DIRECTORY, prefix / module.PREFIX_STDLIB_RELATIVE_PATH)
        output = io.StringIO()

        def probe(command, **kwargs):
            if command[0] == "pkg-config":
                return subprocess.CompletedProcess(command, 1, "", "optional packages unavailable")
            text = ("cwhip: v0.0.2" if Path(command[0]).name == "cwhip" else
                    "cmake version 3.24.0" if command[0] == "cmake" else
                    "clang version 22" if command[0] == "chosen-clang" else "git version 2")
            return subprocess.CompletedProcess(command, 0, text, "")

        def snapshot():
            return {path.relative_to(self.root).as_posix(): path.read_bytes()
                    for path in self.root.rglob("*") if path.is_file()}

        before = snapshot()
        environment = {**self.base_environment, "CWHIP_SDK": str(prefix), "CC": "chosen-clang"}
        with mock.patch.dict(os.environ, environment, clear=True), \
                mock.patch.object(module.subprocess, "run", side_effect=probe) as processes, \
                mock.patch.object(module.urllib.request, "urlopen", side_effect=AssertionError("network")), \
                mock.patch.object(module.sys, "stdout", output):
            module.command_doctor()
            self.assertIn("PASS required", output.getvalue())
            self.assertIn("WARN optional gtk4", output.getvalue())
            self.assertEqual(before, snapshot())
            self.assertIn(["chosen-clang", "--version"], [call.args[0] for call in processes.call_args_list])
            with mock.patch.object(module, "doctor_probe", return_value=(False, "not found")):
                with self.assertRaises(module.CwhipkgError) as caught:
                    module.command_doctor()
            self.assertEqual(caught.exception.code, "PKG2002")
            self.assertIn("Remedy:", output.getvalue())
            with mock.patch.object(module, "discover_standard_modules", return_value={}):
                with self.assertRaises(module.CwhipkgError):
                    module.command_doctor()
            runtime = next(prefix.glob("**/libcwhip_runtime.a"))
            runtime.unlink()
            with self.assertRaises(module.CwhipkgError):
                module.command_doctor()
            self.assertIn("FAIL required runtime:", output.getvalue())
        result = self.run_cwhip_pkg("doctor", env={"CWHIP_SDK": "/missing-sdk"})
        self.assertEqual(result.returncode, 1)
        self.assertIn("error[PKG2003]", result.stderr)
        self.assertIn("error[PKG2002]", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_doctor_reports_probe_failures_and_does_not_fallback_from_explicit_cc(self) -> None:
        module = self.script_module()
        for failure in (FileNotFoundError("missing tool"), subprocess.TimeoutExpired(["tool"], 10)):
            with mock.patch.object(module.subprocess, "run", side_effect=failure):
                passed, detail = module.doctor_probe(["tool"])
            self.assertFalse(passed)
            self.assertTrue(detail)
        output = io.StringIO()
        with mock.patch.dict(os.environ, {**self.base_environment, "CC": "explicit-missing-cc"}, clear=True), \
                mock.patch.object(module, "doctor_probe", return_value=(False, "tool unavailable")) as probe, \
                mock.patch.object(module.sys, "stdout", output):
            with self.assertRaises(module.CwhipkgError):
                module.command_doctor()
        self.assertIn(["explicit-missing-cc", "--version"], [call.args[0] for call in probe.call_args_list])
        self.assertNotIn(["clang", "--version"], [call.args[0] for call in probe.call_args_list])
        self.assertIn("Remedy:", output.getvalue())

    def test_git_failure_diagnostics_retain_both_streams_and_status(self) -> None:
        module = self.script_module()
        failure = subprocess.CalledProcessError(
            17, ["git"], output="stdout detail\n",
            stderr="fatal: repository unavailable\n  upstream note\n",
        )
        with mock.patch.object(module.subprocess, "run", side_effect=failure):
            with self.assertRaises(module.CwhipkgError) as caught:
                module.run_git(["ls-remote"], error_context="could not list package tags")
        self.assertEqual(caught.exception.code, "PKG3001")
        self.assertIn("could not list package tags (git exit status 17)", str(caught.exception))
        self.assertIn("stdout detail\n", str(caught.exception))
        self.assertIn("fatal: repository unavailable\n  upstream note\n", str(caught.exception))
        with mock.patch.object(module.subprocess, "run", side_effect=FileNotFoundError):
            with self.assertRaises(module.CwhipkgError) as caught:
                module.run_git(["ls-remote"], error_context="could not list package tags")
        self.assertEqual(caught.exception.code, "PKG3001")
        self.assertIn("install git", str(caught.exception))

        result = self.run_cwhip_pkg("add", "acme/unmapped", "1.0.0", "--yes")
        self.assertEqual(result.returncode, 1)
        self.assertIn("cwhip-pkg: error[PKG3001]: ", result.stderr)
        self.assertIn("git exit status 1", result.stderr)
        self.assertIn("test git: unmapped remote", result.stderr)
        self.assertNotIn("Installed graph", result.stdout)
        self.assertNotIn("Traceback", result.stderr)

    def test_rollback_diagnostic_does_not_hide_original_failure(self) -> None:
        module = self.script_module()
        stderr = io.StringIO()
        with mock.patch.object(module, "atomic_write",
                               side_effect=OSError("injected write failure")), \
                mock.patch.object(module.sys, "stderr", stderr):
            with self.assertRaisesRegex(OSError, "injected write failure"):
                module.persist(self.project, self.lock()["packages"], {})
        self.assertIn("cwhip-pkg: error[PKG9001]: rollback could not restore ",
                      stderr.getvalue())
        self.assertIn("cwhip-pkg.lock", stderr.getvalue())
        self.assertIn("injected write failure", stderr.getvalue())

    def test_init_locks_standard_modules_and_keeps_string_inheritance_builtin(self) -> None:
        self.assertEqual(self.project_manifest(), {"schema": 1, "sources": {}})
        self.assertFalse((self.project / "modules/modules.toml").exists())
        lock = self.lock()
        self.assertEqual(lock["schema"], 1)
        self.assertEqual(lock["modules"]["math"], ["0.1.0"])
        self.assertEqual(lock["modules"]["system"], ["0.1.0"])
        self.assertNotIn("String", lock["modules"])
        self.assertNotIn("String", lock["packages"])
        source = self.project / "string.cw"
        source.write_text(
            "class Text : String { public: Text() { super String() } }\n"
            "start {\n"
            "String value = Text()\n"
            'value.append("built in")\n'
            "print(value)\n"
            "}\n",
            encoding="utf-8",
        )
        executable = self.project / "string-program"
        environment = self.base_environment.copy()
        environment.pop("CWHIP_MODULE_DIR", None)
        compiled = run(
            [str(self.args.compiler), str(source), "-o", str(executable)],
            cwd=self.project,
            env=environment,
        )
        self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
        result = run([str(executable)], cwd=self.project, env=self.base_environment)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "built in")

    def test_init_does_not_overwrite_existing_policy(self) -> None:
        policy_path = self.project / "cwhip-pkg.toml"
        original = policy_path.read_text(encoding="utf-8")
        result = self.run_cwhip_pkg("init")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing to overwrite", result.stderr)
        self.assertEqual(policy_path.read_text(encoding="utf-8"), original)

    def test_multiple_bundled_versions_select_highest_stable_singleton(self) -> None:
        module = self.script_module()
        stdlib = self.root / "stdlib"
        shutil.copytree(module.STDLIB_DIRECTORY, stdlib)
        for version in ("1.0.0", "2.0.0", "3.0.0-rc.1"):
            root = stdlib / "bundled" / version
            root.mkdir(parents=True)
            (root / "cwhip-package.toml").write_text(self.manifest(name="bundled", version=version))
            (root / "greeting.cw").write_text("class Greeter {}\n")
        project = self.root / "multiple-builtin-project"
        with mock.patch.object(module, "STDLIB_DIRECTORY", stdlib):
            module.command_init(str(project))
            lock_text = (project / "cwhip-pkg.lock").read_text()
            lock = tomllib.loads(lock_text)
            self.assertEqual(lock["modules"]["bundled"], ["2.0.0"])
            self.assertTrue(all(len(versions) == 1 for versions in lock["modules"].values()))
            self.assertIn("bundled", lock["packages"])
            self.assertIn("[packages.bundled]", lock_text)
            self.assertNotIn("@", lock_text)
            packages = module.read_lock(project, module.read_project(project))
            self.assertEqual(module.inspect_installed(project, packages), [])
            document = {"dependencies": {"top": {"repo": "acme/top", "version": "=1.0.0"}}, "sources": {}}
            root = self.root / "builtin-dependent"
            root.mkdir()
            (root / "cwhip-package.toml").write_text(self.manifest(
                name="top", extras='[dependencies]\nbundled = "=1.0.0"\n'))
            (root / "greeting.cw").write_text("class Greeter {}\n")
            manifest = module.read_manifest(root, check_directory_version=False)
            with self.assertRaisesRegex(module.CwhipkgError, "exact version conflict"):
                module.resolve_graph(document, self.root, seed=("top", manifest, root, "1" * 40), yes=True)
        if self.args.compiler is not None:
            source = project / "app.cw"
            source.write_text('start { print("singleton lock") }\n')
            environment = self.base_environment.copy()
            environment.pop("CWHIP_MODULE_DIR", None)
            compiled = run([str(self.args.compiler), "--check-only", str(source)],
                           cwd=self.root, env=environment)
            self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
        shutil.rmtree(stdlib / "bundled/1.0.0")
        shutil.rmtree(stdlib / "bundled/2.0.0")
        with mock.patch.object(module, "STDLIB_DIRECTORY", stdlib):
            with self.assertRaisesRegex(module.CwhipkgError, "no stable SemVer version"):
                module.command_init(str(self.root / "unstable-builtin-project"))

    def test_init_validates_builtin_dependency_edges_before_writing_lock(self) -> None:
        module = self.script_module()
        stdlib = self.root / "builtin-deps"
        for name, extras in (("base", ""), ("dependent", '[dependencies]\nbase = "=1.0.0"\n')):
            root = stdlib / name / "1.0.0"
            root.mkdir(parents=True)
            (root / "cwhip-package.toml").write_text(self.manifest(name=name, extras=extras))
            (root / "greeting.cw").write_text("class Greeter {}\n")
        project = self.root / "builtin-deps-project"
        with mock.patch.object(module, "STDLIB_DIRECTORY", stdlib):
            module.command_init(str(project))
            packages = module.read_lock(project, module.read_project(project))
            self.assertEqual(packages["dependent"]["dependencies"], ["base=1.0.0"])
            self.assertEqual(module.inspect_installed(project, packages), [])
            manifest_path = stdlib / "dependent/1.0.0/cwhip-package.toml"
            manifest_path.write_text(self.manifest(name="dependent", extras='[dependencies]\nbase = "=2.0.0"\n'))
            invalid = self.root / "invalid-builtin-deps-project"
            with self.assertRaisesRegex(module.CwhipkgError, "missing dependency base=2.0.0"):
                module.command_init(str(invalid))
            self.assertFalse((invalid / "cwhip-pkg.toml").exists())
            self.assertFalse((invalid / "cwhip-pkg.lock").exists())

    def test_add_records_exact_pin_and_selects_highest_stable_when_unspecified(self) -> None:
        self.make_remote(
            "greeting",
            {
                "1.0.0": self.manifest(version="1.0.0"),
                "2.0.0": self.manifest(version="2.0.0"),
                "3.0.0-rc.1": self.manifest(version="3.0.0-rc.1"),
            },
        )
        explicit = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertEqual(explicit.returncode, 0, explicit.stderr)
        explicit_manifest = self.project_manifest()
        self.assertEqual(explicit_manifest["dependencies"]["greeting"]["version"], "=1.0.0")
        implicit = self.run_cwhip_pkg("add", "acme/greeting", "--yes")
        self.assertEqual(implicit.returncode, 0, implicit.stderr)
        self.assertTrue((self.project / "modules/greeting/1.0.0/greeting.cw").is_file())
        self.assertTrue((self.project / "modules/greeting/2.0.0/greeting.cw").is_file())
        self.assertEqual(self.project_manifest()["dependencies"]["greeting"]["version"], "=2.0.0")
        prerelease = self.run_cwhip_pkg("add", "acme/greeting", "3.0.0-rc.1", "--yes")
        self.assertEqual(prerelease.returncode, 0, prerelease.stderr)
        self.assertEqual(self.project_manifest()["dependencies"]["greeting"]["version"],
                         "=3.0.0-rc.1")

    def test_add_rejects_invalid_manifests(self) -> None:
        cases = [
            ("name", self.manifest(name="not-valid"), True),
            ("version", self.manifest(version="2.0.0"), True),
            ("source", self.manifest(source="missing.cw"), False),
            ("export", self.manifest(export="method:Greeter"), True),
        ]
        for repository, manifest, create_source in cases:
            with self.subTest(repository=repository):
                self.make_remote(
                    repository,
                    {"1.0.0": manifest},
                    create_source=create_source,
                )
                result = self.run_cwhip_pkg("add", f"acme/{repository}", "1.0.0", "--yes")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("cwhip-package.toml", result.stderr)
                self.assertEqual(
                    list((self.project / "modules").glob(".cwhip-pkg-*")),
                    [],
                )

    def test_add_duplicate_version_does_not_clobber_existing_files(self) -> None:
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        installed = self.project / "modules/greeting/1.0.0"
        installed.mkdir(parents=True)
        (installed / "cwhip-package.toml").write_text(self.manifest(), encoding="utf-8")
        (installed / "greeting.cw").write_text(
            "class Greeter { public: int64 answer() { return(42) } }\n",
            encoding="utf-8",
        )
        sentinel = installed / "keep.txt"
        sentinel.write_text("keep me", encoding="utf-8")
        result = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("integrity mismatch", result.stderr)
        self.assertEqual(sentinel.read_text(encoding="utf-8"), "keep me")

    def test_failed_clone_cleans_temporary_checkout(self) -> None:
        result = self.run_cwhip_pkg("add", "acme/missing", "1.0.0", "--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("could not clone", result.stderr)
        self.assertEqual(list((self.project / "modules").glob(".cwhip-pkg-*")), [])
        self.assertEqual(list((self.project / "modules").glob("missing")), [])

    def test_dependency_must_be_installed_and_allowed_before_install(self) -> None:
        self.make_remote(
            "dependent",
            {
                "1.0.0": self.manifest(
                    name="dependent",
                    extras='[dependencies]\nmissing = "=1.0.0"\n',
                )
            },
        )
        result = self.run_cwhip_pkg("add", "acme/dependent", "1.0.0", "--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unmapped dependency missing=1.0.0", result.stderr)
        self.assertFalse((self.project / "modules/dependent").exists())

    def test_network_requires_consent_and_offline_dry_run_does_not_fetch(self) -> None:
        for arguments in (
            ("add", "acme/unknown", "1.0.0"),
            ("add", "acme/unknown"),
            ("add", "acme/unknown", "--dry-run"),
        ):
            with self.subTest(arguments=arguments):
                result = self.run_cwhip_pkg(*arguments)
                self.assertIn("Initial plan", result.stdout)
                if "--dry-run" in arguments:
                    self.assertEqual(result.returncode, 0, result.stderr)
                else:
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("consent", result.stderr)
                self.assertFalse(self.git_log.exists())

    def create_graph(self) -> None:
        self.make_remote("leaf", {"1.0.0": self.manifest(name="leaf")})
        self.make_remote("middle", {"1.0.0": self.manifest(
            name="middle",
            extras='[dependencies]\nleaf = "=1.0.0"\n[sources]\nleaf = "acme/leaf"\n',
        )})
        self.make_remote("top", {"1.0.0": self.manifest(
            name="top",
            extras='[dependencies]\nmiddle = "=1.0.0"\n[sources]\nmiddle = "acme/middle"\n',
        )})

    def test_transitive_graph_direct_manifest_and_deterministic_lock(self) -> None:
        self.create_graph()
        result = self.run_cwhip_pkg("add", "acme/top", "1.0.0", "--yes")
        self.assertEqual(result.returncode, 0, result.stderr)
        manifest = self.project_manifest()
        self.assertEqual(manifest["dependencies"], {"top": {"repo": "acme/top", "version": "=1.0.0"}})
        lock = self.lock()
        self.assertEqual(lock["manifest-sha256"], hashlib.sha256(
            (self.project / "cwhip-pkg.toml").read_bytes()).hexdigest())
        for name in ("leaf", "middle", "top"):
            entry = lock["packages"][name]
            self.assertEqual(entry["repo"], f"acme/{name}")
            self.assertEqual(entry["ref"], "refs/tags/1.0.0")
            self.assertEqual(len(entry["commit"]), 40)
            self.assertEqual(lock["modules"][name], ["1.0.0"])
            self.assertTrue((self.project / f"modules/{name}/1.0.0/greeting.cw").is_file())
        self.assertEqual(lock["packages"]["top"]["dependencies"], ["middle=1.0.0"])
        self.assertEqual(lock["packages"]["middle"]["dependencies"], ["leaf=1.0.0"])
        self.assertLess(result.stdout.index("Transitive source plan: leaf=1.0.0"),
                        result.stdout.index("Fetch acme/leaf"))
        text = (self.project / "cwhip-pkg.lock").read_bytes()
        self.assertIn(b"[packages.top]", text)
        self.assertNotIn(b'[packages."top"]', text)
        self.assertIn(b'top = ["1.0.0"]', text)
        self.assertIn("[dependencies.top]", (self.project / "cwhip-pkg.toml").read_text())
        again = self.run_cwhip_pkg("add", "acme/top", "1.0.0", "--yes")
        self.assertEqual(again.returncode, 0, again.stderr)
        self.assertEqual((self.project / "cwhip-pkg.lock").read_bytes(), text)
        graph = result.stdout.split("Resolved graph:\n")[1].split("Installed graph")[0]
        self.assertEqual(graph.splitlines(), sorted(graph.splitlines()))
        self.assertFalse((self.project / "modules/modules.toml").exists())

    def test_dry_run_with_consent_resolves_without_persistent_writes(self) -> None:
        self.create_graph()
        before = {path.relative_to(self.project): path.read_bytes() for path in self.project.rglob("*") if path.is_file()}
        result = self.run_cwhip_pkg("add", "acme/top", "--yes", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("leaf=1.0.0", result.stdout)
        after = {path.relative_to(self.project): path.read_bytes() for path in self.project.rglob("*") if path.is_file()}
        self.assertEqual(before, after)
        self.assertEqual(list((self.project / "modules").iterdir()), [])
        self.assertEqual(list(self.project.glob(".cwhip-pkg-*")), [])

    def test_unmapped_dependency_never_fetches_an_inferred_repository(self) -> None:
        self.make_remote("top", {"1.0.0": self.manifest(
            name="top", extras='[dependencies]\nunknown = "=1.0.0"\n',
        )})
        before = (self.project / "cwhip-pkg.lock").read_bytes()
        result = self.run_cwhip_pkg("add", "acme/top", "1.0.0", "--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unmapped dependency unknown=1.0.0", result.stderr)
        self.assertNotIn("acme/unknown", self.git_log.read_text())
        self.assertEqual((self.project / "cwhip-pkg.lock").read_bytes(), before)
        self.assertEqual(list((self.project / "modules").iterdir()), [])

    def test_project_sources_map_package_dependencies(self) -> None:
        self.make_remote("leaf", {"1.0.0": self.manifest(name="leaf")})
        self.make_remote("top", {"1.0.0": self.manifest(
            name="top", extras='[dependencies]\nleaf = "=1.0.0"\n',
        )})
        (self.project / "cwhip-pkg.toml").write_text('schema = 1\n[sources]\nleaf = "acme/leaf"\n')
        (self.project / "cwhip-pkg.lock").unlink()
        result = self.run_cwhip_pkg("add", "acme/top", "1.0.0", "--yes")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.lock()["packages"]["leaf"]["repo"], "acme/leaf")

    def test_graph_conflicts_and_cycles_roll_back(self) -> None:
        self.make_remote("leaf", {
            "1.0.0": self.manifest(name="leaf"),
            "2.0.0": self.manifest(name="leaf", version="2.0.0"),
        })
        self.make_remote("middle", {"1.0.0": self.manifest(
            name="middle", extras='[dependencies]\nleaf = "=2.0.0"\n[sources]\nleaf = "acme/leaf"\n',
        )})
        self.make_remote("conflict", {"1.0.0": self.manifest(
            name="conflict",
            extras='[dependencies]\nleaf = "=1.0.0"\nmiddle = "=1.0.0"\n[sources]\nleaf = "acme/leaf"\nmiddle = "acme/middle"\n',
        )})
        self.make_remote("cycle", {"1.0.0": self.manifest(
            name="cycle", extras='[dependencies]\ncycle = "=1.0.0"\n[sources]\ncycle = "acme/cycle"\n',
        )})
        self.make_remote("repo_conflict", {"1.0.0": self.manifest(
            name="repo_conflict",
            extras='[dependencies]\nleaf = "=1.0.0"\n[sources]\nleaf = "acme/different"\n',
        )})
        for repo, error in (("conflict", "conflict"), ("cycle", "cycle"), ("repo_conflict", "repository conflict")):
            with self.subTest(repo=repo):
                (self.project / "cwhip-pkg.toml").write_text('schema = 1\n[sources]\nleaf = "acme/leaf"\n')
                (self.project / "cwhip-pkg.lock").unlink(missing_ok=True)
                result = self.run_cwhip_pkg("add", f"acme/{repo}", "1.0.0", "--yes")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(error, result.stderr)
                self.assertFalse((self.project / "cwhip-pkg.lock").exists())
                self.assertEqual(list((self.project / "modules").iterdir()), [])
        self.assertNotIn("acme/different", self.git_log.read_text())

    def test_new_add_selects_highest_stable_exact_version(self) -> None:
        self.make_remote("greeting", {
            "1.0.0": self.manifest(),
            "2.0.0": self.manifest(version="2.0.0"),
            "3.0.0-rc.1": self.manifest(version="3.0.0-rc.1"),
        })
        result = self.run_cwhip_pkg("add", "acme/greeting", "--yes")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.project_manifest()["dependencies"]["greeting"]["version"], "=2.0.0")
        self.assertEqual(self.lock()["modules"]["greeting"], ["2.0.0"])
        for version in ("bad", "01.0.0", "1.0.0-01"):
            self.git_log.unlink(missing_ok=True)
            bad = self.run_cwhip_pkg("add", "acme/greeting", version, "--yes")
            self.assertNotEqual(bad.returncode, 0)
            self.assertIn("SemVer", bad.stderr)
            self.assertFalse(self.git_log.exists())

    def test_frozen_install_restores_commit_without_moving_tag_and_preserves_lock(self) -> None:
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        added = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertEqual(added.returncode, 0, added.stderr)
        entry = self.lock()["packages"]["greeting"]
        manifest_bytes = (self.project / "cwhip-pkg.toml").read_bytes()
        lock_bytes = (self.project / "cwhip-pkg.lock").read_bytes()
        working = self.root / "greeting-work"
        (working / "greeting.cw").write_text("changed tag contents\n")
        self.git_run(["-C", str(working), "add", "."])
        self.git_run(["-C", str(working), "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
                      "commit", "-q", "-m", "move tag"])
        self.git_run(["-C", str(working), "tag", "-f", "1.0.0"])
        self.git_run(["-C", str(working), "push", "-q", "--force", str(self.root / "greeting.git"), "refs/tags/1.0.0"])
        shutil.rmtree(self.project / "modules/greeting/1.0.0")
        denied = self.run_cwhip_pkg("install")
        self.assertNotEqual(denied.returncode, 0)
        self.assertIn("consent", denied.stderr)
        self.git_log.unlink()
        restored = self.run_cwhip_pkg("install", "--yes")
        self.assertEqual(restored.returncode, 0, restored.stderr)
        self.assertIn(entry["commit"], self.git_log.read_text())
        self.assertEqual((self.project / "modules/greeting/1.0.0/greeting.cw").read_text(),
                         "class Greeter { public: int64 answer() { return(42) } }\n")
        self.assertEqual((self.project / "cwhip-pkg.toml").read_bytes(), manifest_bytes)
        self.assertEqual((self.project / "cwhip-pkg.lock").read_bytes(), lock_bytes)
        self.git_log.unlink()
        verified = self.run_cwhip_pkg("install")
        self.assertEqual(verified.returncode, 0, verified.stderr)
        self.assertFalse(self.git_log.exists())

    def test_integrity_mismatch_never_overwrites_installed_files(self) -> None:
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        added = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertEqual(added.returncode, 0, added.stderr)
        source = self.project / "modules/greeting/1.0.0/greeting.cw"
        source.write_text("tampered\n")
        lock_bytes = (self.project / "cwhip-pkg.lock").read_bytes()
        self.git_log.unlink()
        result = self.run_cwhip_pkg("install", "--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("integrity mismatch", result.stderr)
        self.assertFalse(self.git_log.exists())
        result = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing to overwrite", result.stderr)
        self.assertEqual(source.read_text(), "tampered\n")
        self.assertEqual((self.project / "cwhip-pkg.lock").read_bytes(), lock_bytes)

    def test_lock_schemas_staleness_metadata_and_hash_tampering_reject_offline(self) -> None:
        lock_path = self.project / "cwhip-pkg.lock"
        original = lock_path.read_text()
        manifest_path = self.project / "cwhip-pkg.toml"
        original_manifest = manifest_path.read_text()
        for content, error in (
            (original.replace("schema = 1", "schema = 2"), "schema"),
            (original.replace("schema = 1", "schema = true"), "schema"),
            (original.replace('math = ["0.1.0"]', 'math = ["9.0.0"]'), "modules"),
            (original.replace('repo = "builtin"', 'repo = "acme/evil"', 1), "commit"),
            (original.replace('dependencies = []', 'dependencies = ["missing=1.0.0"]', 1), "missing dependency"),
            (original.replace(self.lock()["packages"]["math"]["sha256"], "0" * 64), "integrity mismatch"),
        ):
            with self.subTest(error=error):
                lock_path.write_text(content)
                result = self.run_cwhip_pkg("install", "--yes")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(error, result.stderr)
                self.assertFalse(self.git_log.exists())
                lock_path.write_text(original)
        manifest_path.write_text(original_manifest + "\n")
        stale = self.run_cwhip_pkg("install", "--yes")
        self.assertNotEqual(stale.returncode, 0)
        self.assertIn("stale lock", stale.stderr)
        stale_add = self.run_cwhip_pkg("add", "acme/unknown", "1.0.0", "--yes")
        self.assertNotEqual(stale_add.returncode, 0)
        self.assertIn("stale lock", stale_add.stderr)
        self.assertFalse(self.git_log.exists())
        manifest_path.write_text("schema = 2\n")
        invalid = self.run_cwhip_pkg("install")
        self.assertNotEqual(invalid.returncode, 0)
        self.assertIn("manifest schema", invalid.stderr)

    def test_install_without_lock_requires_consent_then_resolves(self) -> None:
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        (self.project / "cwhip-pkg.lock").unlink()
        content = 'schema = 1\n[dependencies.greeting]\nrepo = "acme/greeting"\nversion = "=1.0.0"\n'
        (self.project / "cwhip-pkg.toml").write_text(content)
        denied = self.run_cwhip_pkg("install")
        self.assertNotEqual(denied.returncode, 0)
        self.assertFalse(self.git_log.exists())
        dry = self.run_cwhip_pkg("install", "--dry-run", "--yes")
        self.assertEqual(dry.returncode, 0, dry.stderr)
        self.assertFalse((self.project / "cwhip-pkg.lock").exists())
        self.assertFalse((self.project / "modules/greeting").exists())
        installed = self.run_cwhip_pkg("install", "--yes")
        self.assertEqual(installed.returncode, 0, installed.stderr)
        self.assertEqual((self.project / "cwhip-pkg.toml").read_text(), content)
        self.assertEqual(self.lock()["packages"]["greeting"]["version"], "1.0.0")

    def test_nested_directory_discovers_project_root(self) -> None:
        nested = self.project / "src/nested"
        nested.mkdir(parents=True)
        again = self.run_cwhip_pkg("init", cwd=nested)
        self.assertNotEqual(again.returncode, 0)
        self.assertIn("refusing to overwrite", again.stderr)
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        added = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes", cwd=nested)
        self.assertEqual(added.returncode, 0, added.stderr)
        for command in ("install", "list"):
            result = self.run_cwhip_pkg(command, cwd=nested)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("greeting", result.stdout if command == "list" else self.run_cwhip_pkg("list", cwd=nested).stdout)
        self.assertFalse((nested / "modules").exists())
        env = self.run_cwhip_pkg("env", cwd=nested)
        self.assertNotIn("CWHIP_MODULE_DIR", env.stdout)

    def test_symlinks_and_existing_untracked_content_are_rejected(self) -> None:
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        destination = self.project / "modules/greeting/1.0.0"
        destination.mkdir(parents=True)
        sentinel = destination / "keep"
        sentinel.write_text("do not overwrite\n")
        refused = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertNotEqual(refused.returncode, 0)
        self.assertIn("integrity mismatch", refused.stderr)
        self.assertEqual(sentinel.read_text(), "do not overwrite\n")
        shutil.rmtree(destination)
        outside = self.root / "outside"
        outside.mkdir()
        destination.symlink_to(outside, target_is_directory=True)
        refused = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertNotEqual(refused.returncode, 0)
        self.assertIn("unsafe", refused.stderr)
        self.assertEqual(list(outside.iterdir()), [])
        destination.unlink()
        destination.parent.rmdir()
        destination.parent.symlink_to(outside, target_is_directory=True)
        parent_escape = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertNotEqual(parent_escape.returncode, 0)
        self.assertIn("unsafe", parent_escape.stderr)
        self.assertEqual(list(outside.iterdir()), [])

    def test_checkout_symlink_rejected_without_install(self) -> None:
        self.make_remote("unsafe", {"1.0.0": self.manifest(name="unsafe")})
        working = self.root / "unsafe-work"
        (working / "escape").symlink_to("../../outside")
        self.git_run(["-C", str(working), "add", "."])
        self.git_run(["-C", str(working), "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
                      "commit", "-q", "-m", "unsafe"])
        self.git_run(["-C", str(working), "tag", "-f", "1.0.0"])
        self.git_run(["-C", str(working), "push", "-q", "--force", str(self.root / "unsafe.git"), "refs/tags/1.0.0"])
        result = self.run_cwhip_pkg("add", "acme/unsafe", "1.0.0", "--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unsafe package entry", result.stderr)
        self.assertEqual(list((self.project / "modules").iterdir()), [])

    def test_tree_hash_contract_and_rejection_of_git_and_special_entries(self) -> None:
        module = self.script_module()
        root = self.root / "tree"
        root.mkdir()
        (root / "z").write_bytes(b"last")
        (root / "a").write_bytes(b"first")
        digest = hashlib.sha256()
        for name, content in ((b"a", b"first"), (b"z", b"last")):
            digest.update(name)
            digest.update(b"\0")
            digest.update(content)
            digest.update(b"\0")
        self.assertEqual(module.tree_digest(root), digest.hexdigest())
        (root / "a").chmod(0o755)
        (root / "empty").mkdir()
        self.assertEqual(module.tree_digest(root), digest.hexdigest())
        git_dir = root / "empty/.git"
        git_dir.mkdir()
        with self.assertRaisesRegex(module.CwhipkgError, "unsafe package entry"):
            module.tree_digest(root)
        git_dir.rmdir()
        fifo = root / "pipe"
        os.mkfifo(fifo)
        with self.assertRaisesRegex(module.CwhipkgError, "unsafe package entry"):
            module.tree_digest(root)
        fifo.unlink()
        (root / "link").symlink_to("a")
        with self.assertRaisesRegex(module.CwhipkgError, "unsafe package entry"):
            module.tree_digest(root)

    def test_interactive_graph_requires_specific_transitive_repository_approval(self) -> None:
        module = self.script_module()
        root = self.root / "top"
        root.mkdir()
        (root / "cwhip-package.toml").write_text(self.manifest(
            name="top", extras='[dependencies]\nleaf = "=1.0.0"\n[sources]\nleaf = "acme/leaf"\n'))
        (root / "greeting.cw").write_text("class Greeter {}\n")
        manifest = module.read_manifest(root, check_directory_version=False)
        document = {"dependencies": {"top": {"repo": "acme/top", "version": "=1.0.0"}}, "sources": {}}
        with mock.patch.object(module.sys.stdin, "isatty", return_value=True), \
                mock.patch("builtins.input", return_value="n") as prompt, \
                mock.patch.object(module, "checkout_package") as checkout:
            with self.assertRaisesRegex(module.CwhipkgError, "explicit network consent"):
                module.resolve_graph(document, self.root, seed=("top", manifest, root, "1" * 40))
            checkout.assert_not_called()
            self.assertIn("acme/leaf", prompt.call_args.args[0])
    def test_atomic_configuration_failure_rolls_back_packages_and_manifest(self) -> None:
        module = self.script_module()
        packages = self.lock()["packages"]
        staged_root = self.root / "staged"
        staged_root.mkdir()
        (staged_root / "cwhip-package.toml").write_text(self.manifest())
        (staged_root / "greeting.cw").write_text("class Greeter {}\n")
        manifest = module.read_manifest(staged_root, check_directory_version=False)
        packages["greeting"] = module.package_record(manifest, "acme/greeting", "1" * 40, module.tree_digest(staged_root))
        original_manifest = (self.project / "cwhip-pkg.toml").read_bytes()
        original_lock = (self.project / "cwhip-pkg.lock").read_bytes()
        replace = module.os.replace
        failed = False

        def fail_once(source, destination):
            nonlocal failed
            if Path(destination).name == "cwhip-pkg.lock" and not failed:
                failed = True
                raise OSError("injected lock write failure")
            return replace(source, destination)

        with mock.patch.object(module.os, "replace", side_effect=fail_once):
            with self.assertRaisesRegex(OSError, "injected lock write failure"):
                module.persist(self.project, packages, {"greeting": staged_root},
                               'schema = 1\n[dependencies.greeting]\nrepo = "acme/greeting"\nversion = "=1.0.0"\n')
        self.assertEqual((self.project / "cwhip-pkg.toml").read_bytes(), original_manifest)
        self.assertEqual((self.project / "cwhip-pkg.lock").read_bytes(), original_lock)
        self.assertFalse((self.project / "modules/greeting").exists())
        self.assertEqual(list(self.project.glob(".cwhip-pkg-write-*")), [])

    def test_frozen_restore_rejects_tampered_hash_without_installing(self) -> None:
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        added = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertEqual(added.returncode, 0, added.stderr)
        lock = self.lock()
        path = self.project / "cwhip-pkg.lock"
        tampered = path.read_text().replace(lock["packages"]["greeting"]["sha256"], "0" * 64)
        path.write_text(tampered)
        shutil.rmtree(self.project / "modules/greeting")
        result = self.run_cwhip_pkg("install", "--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("integrity mismatch", result.stderr)
        self.assertFalse((self.project / "modules/greeting").exists())
        self.assertEqual(path.read_text(), tampered)
        self.assertEqual(list(self.project.glob(".cwhip-pkg-*")), [])

    def test_env_loads_xdg_preferences_and_quotes_posix_values(self) -> None:
        xdg = self.root / "xdg"
        preferences = xdg / "cwhip" / "preferences.toml"
        preferences.parent.mkdir(parents=True)
        value = "single ' quote; $(touch nope)\nsecond line"
        preferences.write_text(
            "[environment]\nCUSTOM_VALUE = " + json.dumps(value) + "\n",
            encoding="utf-8",
        )
        result = self.run_cwhip_pkg("env", env={"XDG_CONFIG_HOME": str(xdg)})
        self.assertEqual(result.returncode, 0, result.stderr)
        shell = (
            'eval "$("$1" env)"; '
            'printf "%s" "$CUSTOM_VALUE"'
        )
        activated = run(
            ["sh", "-c", shell, "sh", str(self.args.cwhip_pkg)],
            cwd=self.project,
            env={**self.base_environment, "XDG_CONFIG_HOME": str(xdg)},
        )
        self.assertEqual(activated.returncode, 0, activated.stderr)
        self.assertEqual(
            activated.stdout.encode(),
            value.encode(),
        )

    def test_env_explicit_preferences_emit_configured_environment(self) -> None:
        preferences = self.root / "custom.toml"
        preferences.write_text('[environment]\nCUSTOM_VALUE = "loaded"\n', encoding="utf-8")
        result = self.run_cwhip_pkg(
            "env",
            "--preferences",
            str(preferences),
            env={"CWHIP_MODULE_DIR": "/unrelated"},
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("export CUSTOM_VALUE='loaded'", result.stdout)
        self.assertNotIn("CWHIP_MODULE_DIR", result.stdout)
        self.assertFalse((self.root / "not-created.toml").exists())
        missing = self.run_cwhip_pkg("env", "--preferences", str(self.root / "not-created.toml"))
        self.assertNotEqual(missing.returncode, 0)
        self.assertIn("does not exist", missing.stderr)

    def test_env_rejects_invalid_preferences_and_allows_module_root_override(self) -> None:
        cases = [
            ("[environment\n", "cannot read TOML"),
            ('[environment]\nVALUE = 42\n', "must be a string"),
            ('[environment]\n"BAD-NAME" = "x"\n', "invalid environment variable name"),
        ]
        for index, (content, error) in enumerate(cases):
            with self.subTest(error=error):
                path = self.root / f"invalid-{index}.toml"
                path.write_text(content, encoding="utf-8")
                result = self.run_cwhip_pkg("env", "--preferences", str(path))
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(error, result.stderr)
        override = self.root / "module-root.toml"
        override.write_text('[environment]\nCWHIP_MODULE_DIR = "/tmp/modules"\n',
                            encoding="utf-8")
        result = self.run_cwhip_pkg("env", "--preferences", str(override))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("export CWHIP_MODULE_DIR='/tmp/modules'", result.stdout)

    def test_env_uses_default_home_config_path(self) -> None:
        preferences = Path(self.base_environment["HOME"]) / ".config/cwhip/preferences.toml"
        preferences.parent.mkdir(parents=True)
        preferences.write_text('[environment]\nFROM_HOME = "yes"\n', encoding="utf-8")
        result = self.run_cwhip_pkg("env")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("export FROM_HOME='yes'", result.stdout)

    def test_compiler_resolves_added_package_without_environment_from_nested_absolute_source(self) -> None:
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        added = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertEqual(added.returncode, 0, added.stderr)
        nested = self.project / "src/nested"
        nested.mkdir(parents=True)
        source = nested / "app.cw"
        source.write_text(
            "import greeting as Greeter\nstart { print(Greeter().answer()) }\n",
            encoding="utf-8",
        )
        environment = self.base_environment.copy()
        environment.pop("CWHIP_MODULE_DIR", None)
        result = run([str(self.args.compiler), "--check-only", str(source)],
                     cwd=self.root, env=environment)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_compiler_storage_overrides_cannot_relocate_or_bypass_project_lock(self) -> None:
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        added = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertEqual(added.returncode, 0, added.stderr)
        source = self.project / "app.cw"
        source.write_text("import greeting\nstart { print(Greeter().answer()) }\n")
        environment = self.base_environment.copy()
        environment.pop("CWHIP_MODULE_DIR", None)
        compiler = str(self.args.compiler)
        default = run([compiler, "--check-only", str(source)], cwd=self.root, env=environment)
        self.assertEqual(default.returncode, 0, default.stdout + default.stderr)
        independent = self.root / "independent-modules"
        independent.mkdir()
        shutil.copytree(self.project / "modules/greeting", independent / "greeting")
        lock_path = self.project / "cwhip-pkg.lock"
        valid_lock = lock_path.read_text()
        lock_path.write_text(valid_lock.replace("schema = 1", "schema = 2"))
        overridden_env = {**environment, "CWHIP_MODULE_DIR": str(independent)}
        from_env = run([compiler, "--check-only", str(source)], cwd=self.root, env=overridden_env)
        self.assertNotEqual(from_env.returncode, 0)
        self.assertIn("schema", from_env.stdout + from_env.stderr)
        from_flag = run([compiler, "--check-only", "-M", str(independent), str(source)],
                        cwd=self.root, env=environment)
        self.assertNotEqual(from_flag.returncode, 0)
        self.assertIn("schema", from_flag.stdout + from_flag.stderr)
        lock_path.write_text(valid_lock)
        override_hash = independent / "greeting/1.0.0/greeting.cw"
        override_hash.write_text("class Greeter { public: int64 answer() { return(99) } }\n")
        hash_failure = run([compiler, "--check-only", "-M", str(independent), str(source)],
                           cwd=self.root, env=environment)
        self.assertNotEqual(hash_failure.returncode, 0)
        self.assertIn("integrity mismatch", hash_failure.stdout + hash_failure.stderr)

    def test_compiler_runs_package_from_home_when_xdg_is_unset(self) -> None:
        project = self.root / "home-lookup-project"
        (project / "modules").mkdir(parents=True)
        source = project / "app.cw"
        source.write_text("import greeting\nstart { print(Greeter().answer()) }\n")
        package = Path(self.base_environment["HOME"]) / ".config/cwhip/modules/greeting/1.0.0"
        package.mkdir(parents=True)
        (package / "cwhip-package.toml").write_text(self.manifest())
        (package / "greeting.cw").write_text(
            "class Greeter { public: int64 answer() { return(73) } }\n"
        )
        installation = self.root / "empty-installation-modules"
        installation.mkdir()
        environment = {
            **self.base_environment,
            "CWHIP_STDLIB_MODULE_DIR": str(installation),
        }
        environment.pop("XDG_CONFIG_HOME", None)
        executable = self.root / "home-lookup-app"
        compiled = run(
            [str(self.args.compiler), str(source), "-o", str(executable)],
            cwd=self.root,
            env=environment,
        )
        self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
        executed = run([str(executable)], cwd=self.root, env=environment)
        self.assertEqual(executed.returncode, 0, executed.stdout + executed.stderr)
        self.assertEqual(executed.stdout, "73")

    def test_compiler_five_root_collisions_select_each_precedence_level(self) -> None:
        project = self.root / "precedence-project"
        nested = project / "src/nested"
        nested.mkdir(parents=True)
        source = nested / "app.cw"
        source.write_text("import greeting\nstart { print(Greeter().answer()) }\n")
        config_home = self.root / "precedence-config"
        roots = [
            self.root / "cli-modules",
            project / "modules",
            self.root / "environment-modules",
            config_home / "cwhip/modules",
            self.root / "installation-modules",
        ]
        for value, root in enumerate(roots, start=1):
            package = root / "greeting/1.0.0"
            package.mkdir(parents=True)
            (package / "cwhip-package.toml").write_text(self.manifest())
            (package / "greeting.cw").write_text(
                f"class Greeter {{ public: int64 answer() {{ return({value}) }} }}\n"
            )
        environment = {
            **self.base_environment,
            "XDG_CONFIG_HOME": str(config_home),
            "CWHIP_MODULE_DIR": str(roots[2]),
            "CWHIP_STDLIB_MODULE_DIR": str(roots[4]),
        }
        executable = self.root / "precedence-app"
        for index, origin in enumerate(("CLI", "project", "environment", "home", "installation")):
            with self.subTest(selected=origin):
                arguments = ["-M", str(roots[0])] if index == 0 else []
                compiled = run(
                    [str(self.args.compiler), *arguments, str(source), "-o", str(executable)],
                    cwd=self.root,
                    env=environment,
                )
                self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
                executed = run([str(executable)], cwd=self.root, env=environment)
                self.assertEqual(executed.returncode, 0, executed.stdout + executed.stderr)
                self.assertEqual(executed.stdout, str(index + 1))
            shutil.rmtree(roots[index] / "greeting")

    def test_compiler_rejects_legacy_registry_files_in_cwd_and_discovered_project(self) -> None:
        project = self.root / "registry-project"
        (project / "modules").mkdir(parents=True)
        nested = project / "src/nested"
        nested.mkdir(parents=True)
        source = nested / "app.cw"
        source.write_text("start { print(1) }\n")
        cwd = self.root / "registry-cwd"
        cwd.mkdir()
        command = [str(self.args.compiler), "--check-only", str(source)]
        baseline = run(command, cwd=cwd, env=self.base_environment)
        self.assertEqual(baseline.returncode, 0, baseline.stdout + baseline.stderr)
        for origin, directory in (("cwd", cwd), ("discovered project", project)):
            with self.subTest(registry=origin):
                registry = directory / "cwhip-modules.tsv"
                registry.write_text("greeting\t1.0.0\tgreeting.cw\tclass\tGreeter\t\n")
                try:
                    rejected = run(command, cwd=cwd, env=self.base_environment)
                    self.assertNotEqual(rejected.returncode, 0)
                    self.assertIn(
                        "cwhip-modules.tsv registries are no longer supported",
                        rejected.stdout + rejected.stderr,
                    )
                    self.assertIn(
                        "cwhip-package.toml",
                        rejected.stdout + rejected.stderr,
                    )
                finally:
                    registry.unlink()

    def test_user_package_root_satisfies_only_matching_locked_content(self) -> None:
        module = self.script_module()
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        added = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertEqual(added.returncode, 0, added.stderr)
        package = self.project / "modules/greeting/1.0.0"
        user_root = Path(self.base_environment["HOME"]) / ".config/cwhip/modules"
        user_package = user_root / "greeting/1.0.0"
        user_package.parent.mkdir(parents=True)
        shutil.copytree(package, user_package)
        shutil.rmtree(package)
        with mock.patch.dict(os.environ, self.base_environment, clear=True):
            self.assertEqual(
                module.inspect_installed(self.project, self.lock()["packages"]), []
            )
        source = self.project / "home-app.cw"
        source.write_text("import greeting\nstart { print(Greeter().answer()) }\n")
        compiled = run([str(self.args.compiler), "--check-only", str(source)],
                       cwd=self.root, env=self.base_environment)
        self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
        (user_package / "greeting.cw").write_text("class Greeter {}\n")
        with mock.patch.dict(os.environ, self.base_environment, clear=True):
            with self.assertRaisesRegex(module.CwhipkgError, "integrity mismatch"):
                module.inspect_installed(self.project, self.lock()["packages"])

    def test_locked_install_does_not_skip_higher_precedence_version_conflict(self) -> None:
        module = self.script_module()
        self.make_remote("greeting", {"1.0.0": self.manifest()})
        added = self.run_cwhip_pkg("add", "acme/greeting", "1.0.0", "--yes")
        self.assertEqual(added.returncode, 0, added.stderr)
        locked_package = self.project / "modules/greeting/1.0.0"
        user_package = Path(self.base_environment["HOME"]) / ".config/cwhip/modules/greeting/1.0.0"
        user_package.parent.mkdir(parents=True)
        shutil.copytree(locked_package, user_package)
        shutil.rmtree(locked_package.parent)
        environment_root = self.root / "environment-modules"
        conflicting = environment_root / "greeting/2.0.0"
        conflicting.parent.mkdir(parents=True)
        shutil.copytree(user_package, conflicting)
        manifest = conflicting / "cwhip-package.toml"
        manifest.write_text(
            manifest.read_text(encoding="utf-8").replace(
                'version = "1.0.0"', 'version = "2.0.0"', 1
            ),
            encoding="utf-8",
        )
        environment = {
            **self.base_environment,
            "CWHIP_MODULE_DIR": str(environment_root),
        }
        with mock.patch.dict(os.environ, environment, clear=True):
            packages = self.lock()["packages"]
            self.assertIn("greeting", module.inspect_installed(self.project, packages))

    def test_legacy_project_configuration_is_not_migrated(self) -> None:
        legacy = self.root / "legacy-project"
        (legacy / "modules").mkdir(parents=True)
        config = legacy / "modules/modules.toml"
        config.write_text("[modules]\n")
        result = self.run_cwhip_pkg("init", cwd=legacy)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("legacy modules.toml is not imported or modified", result.stderr)
        self.assertEqual(config.read_text(), "[modules]\n")
        self.assertFalse((legacy / "cwhip-pkg.toml").exists())
        self.assertFalse((legacy / "cwhip-pkg.lock").exists())

    def test_compiler_graph_rejects_default_namespace_collision(self) -> None:
        namespace = "namespace Shared { class Greeter { public: int64 answer() { return(42) } } }\n"
        self.make_remote("helper", {"1.0.0": self.manifest(name="helper", export="namespace:Shared")},
                         source_content=namespace)
        self.make_remote("top", {"1.0.0": self.manifest(
            name="top", export="namespace:Shared",
            extras='[dependencies]\nhelper = "=1.0.0"\n[sources]\nhelper = "acme/helper"\n',
        )}, source_content=namespace)
        added = self.run_cwhip_pkg("add", "acme/top", "1.0.0", "--yes")
        self.assertEqual(added.returncode, 0, added.stderr)
        source = self.project / "app.cw"
        source.write_text("import top\nimport helper\nstart { print(Shared.Greeter().answer()) }\n")
        environment = self.base_environment.copy()
        environment.pop("CWHIP_MODULE_DIR", None)
        command = [str(self.args.compiler), "--check-only", str(source)]
        collision = run(command, cwd=self.root, env=environment)
        self.assertNotEqual(collision.returncode, 0)
        self.assertIn("Shared", collision.stdout + collision.stderr)


def parse_test_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cwhip-pkg", type=Path, required=True)
    parser.add_argument("--compiler", type=Path, required=True)
    arguments, unittest_arguments = parser.parse_known_args()
    arguments.unittest_arguments = unittest_arguments
    return arguments


if __name__ == "__main__":
    CwhipkgTest.args = parse_test_arguments()
    unittest.main(argv=[__file__, *CwhipkgTest.args.unittest_arguments])
