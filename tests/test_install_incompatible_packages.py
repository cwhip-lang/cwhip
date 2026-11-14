"""Install-time handling of incompatible packages left in the SDK module directory."""

import argparse
import datetime
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


SOURCE_ROOT = Path(__file__).resolve().parent.parent
CHECKER = SOURCE_ROOT / "tools" / "cwhip-install-package-check.py"
CMAKE = "cmake"
BUILD_DIR: Path | None = None
DATADIR = "share"
BINDIR = "bin"
SDK_ABI = "numeric-v2"
STALE_CVM = ("cvm", "cvmfile", "cvmrun")
QUARANTINE = "CWHIP_QUARANTINE_INCOMPATIBLE_PACKAGES"


def write_package(root: Path, name: str, version: str = "1.0.0", *, abi: str | None = SDK_ABI,
                  manifest: str | None = None) -> Path:
    directory = root / name / version
    (directory / "lib").mkdir(parents=True)
    (directory / f"{name}.cw").write_text(
        f"class {name.capitalize()} {{\n    public:\n    {name.capitalize()}() {{}}\n}}\n")
    (directory / "lib" / f"lib{name}.a").write_bytes(b"!<arch>\nnative-" + name.encode())
    if manifest is None:
        abi_line = f'sdk-abi = "{abi}"\n' if abi is not None else ""
        manifest = (f'[package]\n{abi_line}name = "{name}"\nversion = "{version}"\n'
                    f'source = "{name}.cw"\nexport = "class:{name.capitalize()}"\n')
    (directory / "cwhip-package.toml").write_text(manifest)
    return directory


def snapshot(directory: Path) -> dict[str, bytes]:
    return {str(path.relative_to(directory)): path.read_bytes()
            for path in sorted(directory.rglob("*")) if path.is_file()}


def clean_environment(work: Path, **extra: str) -> dict[str, str]:
    environment = {key: value for key, value in os.environ.items()
                   if not key.startswith("CWHIP_") and key != "DESTDIR"}
    environment.update(HOME=str(work / "home"), XDG_CONFIG_HOME=str(work / "xdg"))
    environment.update(extra)
    return environment


class CheckerTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="cwhip-package-check-")
        self.addCleanup(temporary.cleanup)
        self.work = Path(temporary.name)
        self.modules = self.work / "share/cwhip/modules"
        self.owned = self.work / "stage/modules"
        self.backups = self.work / "share/cwhip/package-backups"
        write_package(self.owned, "math", "0.1.0")
        write_package(self.modules, "math", "0.1.0")

    def run_checker(self, quarantine: str | None = None) -> subprocess.CompletedProcess:
        environment = clean_environment(self.work)
        if quarantine is not None:
            environment[QUARANTINE] = quarantine
        return subprocess.run(
            [sys.executable, CHECKER, "--modules-dir", self.modules, "--owned-dir", self.owned,
             "--backup-dir", self.backups, "--sdk-abi", SDK_ABI],
            env=environment, capture_output=True, text=True, check=False)

    def stale_cvm(self) -> dict[str, dict[str, bytes]]:
        return {name: snapshot(write_package(self.modules, name, abi=None)) for name in STALE_CVM}

    def test_clean_install_is_silent(self):
        write_package(self.modules, "external")
        result = self.run_checker()
        self.assertEqual((result.returncode, result.stderr), (0, ""))

    def test_reports_stale_packages_without_changing_them(self):
        before = self.stale_cvm()
        compatible = snapshot(write_package(self.modules, "external"))
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stderr)
        for name in STALE_CVM:
            self.assertIn(f"{self.modules / name / '1.0.0'} (sdk-abi missing)", result.stderr)
            self.assertEqual(snapshot(self.modules / name / "1.0.0"), before[name])
        self.assertIn(f"{QUARANTINE}=1", result.stderr)
        self.assertIn("PKG2004", result.stderr)
        self.assertNotIn("external", result.stderr)
        self.assertEqual(snapshot(self.modules / "external/1.0.0"), compatible)
        self.assertFalse(self.backups.exists())

    def test_quarantine_moves_only_incompatible_versions(self):
        before = self.stale_cvm()
        old = snapshot(write_package(self.modules, "mixed", "1.0.0", abi="numeric-v1"))
        current = snapshot(write_package(self.modules, "mixed", "2.0.0"))
        compatible = snapshot(write_package(self.modules, "external"))
        owned = snapshot(self.modules / "math/0.1.0")
        result = self.run_checker("1")
        self.assertEqual(result.returncode, 0, result.stderr)
        (backup,) = self.backups.iterdir()
        for name in STALE_CVM:
            self.assertFalse((self.modules / name).exists())
            self.assertEqual(snapshot(backup / "modules" / name / "1.0.0"), before[name])
        self.assertEqual(snapshot(backup / "modules/mixed/1.0.0"), old)
        self.assertEqual(snapshot(self.modules / "mixed/2.0.0"), current)
        self.assertFalse((self.modules / "mixed/1.0.0").exists())
        self.assertEqual(snapshot(self.modules / "external/1.0.0"), compatible)
        self.assertEqual(snapshot(self.modules / "math/0.1.0"), owned)
        restore = (backup / "RESTORE.txt").read_text()
        self.assertIn(str(self.modules / "cvm/1.0.0"), restore)
        self.assertIn(str(backup / "modules/cvm/1.0.0"), restore)
        self.assertIn("sdk-abi 'numeric-v1'", restore)
        self.assertIn(str(backup / "RESTORE.txt"), result.stderr)

        # A repeated repair has nothing to move and creates no empty backup.
        result = self.run_checker("1")
        self.assertEqual((result.returncode, result.stderr), (0, ""))
        self.assertEqual(len(list(self.backups.iterdir())), 1)

    def test_backups_never_collide(self):
        self.stale_cvm()
        self.assertEqual(self.run_checker("1").returncode, 0)
        (first,) = self.backups.iterdir()
        first_contents = snapshot(first)
        write_package(self.modules, "cvm", abi=None)
        # Occupy the timestamp names the next run could choose.
        now = datetime.datetime.now(datetime.timezone.utc)
        occupied = []
        for offset in range(-1, 10):
            stamp = (now + datetime.timedelta(seconds=offset)).strftime("%Y%m%dT%H%M%SZ")
            for name in (stamp, f"{stamp}-1"):
                if not (self.backups / name).exists():
                    (self.backups / name).mkdir()
                    occupied.append(self.backups / name)
        result = self.run_checker("1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(snapshot(first), first_contents)
        for directory in occupied:
            self.assertEqual(list(directory.iterdir()), [])
        populated = [path for path in self.backups.iterdir() if (path / "RESTORE.txt").exists()]
        self.assertEqual(len(populated), 2)
        self.assertRegex(max(populated, key=lambda path: path.stat().st_mtime).name, r"-2$")

    def test_malformed_and_unreadable_manifests_fail_without_moving(self):
        stale = self.stale_cvm()
        cases = {
            "badtoml": "[package\nname = 1\n",
            "nopackage": 'name = "nopackage"\n',
            "badabi": '[package]\nsdk-abi = 2\nname = "badabi"\n',
        }
        for name, manifest in cases.items():
            write_package(self.modules, name, manifest=manifest)
        for mode in (None, "1"):
            with self.subTest(mode=mode):
                result = self.run_checker(mode)
                self.assertEqual(result.returncode, 1)
                self.assertIn("nothing was moved", result.stderr)
                for name in cases:
                    self.assertIn(str(self.modules / name / "1.0.0/cwhip-package.toml"), result.stderr)
                self.assertFalse(self.backups.exists())
                for name in STALE_CVM:
                    self.assertEqual(snapshot(self.modules / name / "1.0.0"), stale[name])
        if os.geteuid() != 0:
            for name in cases:
                shutil.rmtree(self.modules / name)
            manifest = write_package(self.modules, "locked") / "cwhip-package.toml"
            manifest.chmod(0)
            self.addCleanup(manifest.chmod, 0o644)
            result = self.run_checker("1")
            self.assertEqual(result.returncode, 1)
            self.assertIn("cannot read manifest", result.stderr)
            self.assertFalse(self.backups.exists())

    def test_failed_move_is_reported(self):
        if os.geteuid() == 0:
            self.skipTest("permission checks do not apply to root")
        self.stale_cvm()
        (self.modules / "cvmrun").chmod(0o555)
        self.addCleanup((self.modules / "cvmrun").chmod, 0o755)
        result = self.run_checker("1")
        self.assertEqual(result.returncode, 1)
        self.assertIn(f"cannot move {self.modules / 'cvmrun/1.0.0'}", result.stderr)
        self.assertIn(f"moved {self.modules / 'cvm/1.0.0'}", result.stderr)
        self.assertTrue((self.modules / "cvmrun/1.0.0/cwhip-package.toml").is_file())

    def test_restore_instructions_quote_paths(self):
        root = self.work / "it's here; $(touch pwned)"
        self.modules = root / "share/cwhip/modules"
        self.backups = root / "share/cwhip/package-backups"
        write_package(self.modules, "math", "0.1.0")
        before = snapshot(write_package(self.modules, "cvm", abi=None))
        result = self.run_checker("1")
        self.assertEqual(result.returncode, 0, result.stderr)
        (backup,) = self.backups.iterdir()
        command = next(line.strip() for line in (backup / "RESTORE.txt").read_text().splitlines()
                       if line.strip().startswith("mkdir -p "))
        restored = subprocess.run(["sh", "-c", command], cwd=self.work,
                                  capture_output=True, text=True, check=False)
        self.assertEqual(restored.returncode, 0, restored.stderr)
        self.assertEqual(snapshot(self.modules / "cvm/1.0.0"), before)
        self.assertFalse((self.work / "pwned").exists())

    def symlink_fixture(self, link: Path, target: Path) -> None:
        link.parent.mkdir(parents=True, exist_ok=True)
        link.symlink_to(target, target_is_directory=True)

    def test_symlinked_packages_refuse_repair_before_any_move(self):
        external = self.work / "external-tree"
        cases = {
            "package": lambda: self.symlink_fixture(
                self.modules / "cvmfile", write_package(external, "cvmfile", abi=None).parent),
            "version": lambda: self.symlink_fixture(
                self.modules / "cvmrun/1.0.0", write_package(external, "cvmrun", abi=None)),
        }
        for kind, make in cases.items():
            with self.subTest(kind=kind):
                for path in (self.modules / "cvm", self.modules / "cvmfile",
                             self.modules / "cvmrun", external):
                    if path.is_symlink():
                        path.unlink()
                    elif path.exists():
                        shutil.rmtree(path)
                stale = snapshot(write_package(self.modules, "cvm", abi=None))
                make()
                outside = snapshot(external)
                report = self.run_checker()
                self.assertEqual(report.returncode, 0, report.stderr)
                self.assertIn("symlinked, so the repair below refuses it", report.stderr)
                result = self.run_checker("1")
                self.assertEqual(result.returncode, 1)
                self.assertIn("refusing CWHIP_QUARANTINE_INCOMPATIBLE_PACKAGES=1 repair; "
                              "nothing was moved", result.stderr)
                self.assertIn("is a symlink", result.stderr)
                self.assertFalse(self.backups.exists())
                self.assertEqual(snapshot(self.modules / "cvm/1.0.0"), stale)
                self.assertEqual(snapshot(external), outside)

    def test_compatible_symlinked_package_is_left_alone(self):
        target = write_package(self.work / "external-tree", "linked")
        self.symlink_fixture(self.modules / "linked", target.parent)
        self.stale_cvm()
        result = self.run_checker("1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.modules / "linked").is_symlink())
        self.assertTrue((target / "cwhip-package.toml").is_file())

    def test_backup_symlinked_into_modules_is_refused(self):
        stale = self.stale_cvm()
        self.backups.parent.mkdir(parents=True, exist_ok=True)
        self.symlink_fixture(self.work / "share/cwhip/redirect", self.modules / "cvm")
        self.backups = self.work / "share/cwhip/redirect/package-backups"
        result = self.run_checker("1")
        self.assertEqual(result.returncode, 1)
        self.assertIn("inside the package directory", result.stderr)
        self.assertIn("nothing was moved", result.stderr)
        self.assertFalse((self.modules / "cvm/package-backups").exists())
        for name in STALE_CVM:
            self.assertEqual(snapshot(self.modules / name / "1.0.0"), stale[name])

    def test_sdk_owned_incompatible_package_is_an_error(self):
        (self.modules / "math/0.1.0/cwhip-package.toml").write_text(
            '[package]\nname = "math"\nversion = "0.1.0"\n')
        result = self.run_checker("1")
        self.assertEqual(result.returncode, 1)
        self.assertIn("SDK-installed package", result.stderr)
        self.assertTrue((self.modules / "math/0.1.0").is_dir())

    def test_rejects_unexpected_quarantine_value(self):
        self.stale_cvm()
        for value in ("yes", "ON", "2"):
            result = self.run_checker(value)
            self.assertEqual(result.returncode, 1)
            self.assertIn(f"{QUARANTINE} must be 1", result.stderr)
        self.assertEqual(self.run_checker("0").returncode, 0)
        self.assertFalse(self.backups.exists())

    def test_missing_module_directory_is_an_error(self):
        shutil.rmtree(self.modules)
        result = self.run_checker()
        self.assertEqual(result.returncode, 1)
        self.assertIn("does not exist", result.stderr)


class InstallTests(unittest.TestCase):
    def setUp(self):
        if BUILD_DIR is None:
            self.skipTest("set --build-dir to run real install checks")
        temporary = tempfile.TemporaryDirectory(prefix="cwhip-package-install-")
        self.addCleanup(temporary.cleanup)
        self.work = Path(temporary.name)
        for directory in ("home", "xdg"):
            (self.work / directory).mkdir()

    def install(self, prefix: str, **environment: str) -> subprocess.CompletedProcess:
        result = subprocess.run(
            [CMAKE, "--install", str(BUILD_DIR), "--prefix", prefix],
            env=clean_environment(self.work, **environment),
            capture_output=True, text=True, check=False)
        return result

    def init(self, prefix: Path, name: str) -> subprocess.CompletedProcess:
        project = self.work / name
        (project / "modules").mkdir(parents=True)
        return subprocess.run(
            [sys.executable, str(prefix / BINDIR / "cwhip-pkg"), "init", str(project)],
            env=clean_environment(self.work), capture_output=True, text=True, check=False)

    def test_stale_cvm_install_report_then_repair(self):
        prefix = self.work / "prefix"
        modules = prefix / DATADIR / "cwhip/modules"
        stale = {name: snapshot(write_package(modules, name, abi=None)) for name in STALE_CVM}
        compatible = snapshot(write_package(modules, "external"))

        result = self.install(str(prefix))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn(f"{QUARANTINE}=1", result.stderr)
        for name in STALE_CVM:
            self.assertEqual(snapshot(modules / name / "1.0.0"), stale[name])
        failed = self.init(prefix, "before-repair")
        self.assertEqual(failed.returncode, 1, failed.stdout + failed.stderr)
        self.assertIn("PKG2004", failed.stderr)
        self.assertIn(QUARANTINE, failed.stderr)

        result = self.install(str(prefix), **{QUARANTINE: "1"})
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        (backup,) = (prefix / DATADIR / "cwhip/package-backups").iterdir()
        for name in STALE_CVM:
            self.assertFalse((modules / name).exists())
            self.assertEqual(snapshot(backup / "modules" / name / "1.0.0"), stale[name])
        self.assertEqual(snapshot(modules / "external/1.0.0"), compatible)
        self.assertTrue((modules / "math").is_dir())
        repaired = self.init(prefix, "after-repair")
        self.assertEqual(repaired.returncode, 0, repaired.stdout + repaired.stderr)
        lock = (self.work / "after-repair/cwhip-pkg.lock").read_text()
        self.assertIn("external", lock)
        self.assertNotIn("cvm", lock)

        for environment in ({}, {QUARANTINE: "1"}):
            result = self.install(str(prefix), **environment)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("cwhip-install", result.stderr)
        self.assertEqual(len(list(backup.parent.iterdir())), 1)

    def test_destdir_install_checks_staged_prefix(self):
        destdir = self.work / "destdir"
        staged_prefix = "/opt/cwhip-package-check"
        modules = destdir / staged_prefix.lstrip("/") / DATADIR / "cwhip/modules"
        stale = snapshot(write_package(modules, "cvm", abi=None))
        result = self.install(staged_prefix, DESTDIR=str(destdir))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn(str(modules / "cvm/1.0.0"), result.stderr)
        self.assertEqual(snapshot(modules / "cvm/1.0.0"), stale)
        result = self.install(staged_prefix, DESTDIR=str(destdir), **{QUARANTINE: "1"})
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse((modules / "cvm").exists())
        self.assertFalse(Path(staged_prefix).exists())
        (backup,) = (modules.parent / "package-backups").iterdir()
        self.assertEqual(snapshot(backup / "modules/cvm/1.0.0"), stale)

    def test_malformed_external_manifest_fails_install(self):
        prefix = self.work / "prefix"
        modules = prefix / DATADIR / "cwhip/modules"
        write_package(modules, "broken", manifest="[package\n")
        result = self.install(str(prefix))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("malformed manifest", result.stderr)
        self.assertIn("Installed package check failed", result.stderr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--build-dir", type=Path)
    parser.add_argument("--cmake", default=CMAKE)
    parser.add_argument("--datadir", default=DATADIR)
    parser.add_argument("--bindir", default=BINDIR)
    arguments, remaining = parser.parse_known_args()
    BUILD_DIR = arguments.build_dir
    CMAKE, DATADIR, BINDIR = arguments.cmake, arguments.datadir, arguments.bindir
    unittest.main(argv=[sys.argv[0], *remaining])
