# Build and installation

For source-independent external CMake projects and whole-prefix relocation,
see [the installed SDK contract](CMAKE-SDK.md).
The [cedit editor](https://github.com/cwhip-lang/cedit) and
[cdbg debugger](https://github.com/cwhip-lang/cdbg) are standalone SDK consumers;
this repository does not build or install either application.

For that SDK-first, standalone-editor workflow from an empty source directory,
see [Your first program](FIRST-PROGRAM.md). It uses a dedicated user-local
prefix and explicit SDK selection without registering user SDK settings.

The compiler uses CMake and requires Clang on `PATH` to compile and link its
generated LLVM IR. The project uses C11 and C++17. Building and running
`cwhip-pkg` also requires Python 3.11 or newer; installing packages requires
`git`. A repository build stages
the compiler resources beside `bin/cwhip`, so the executable can run directly
from the source tree:

```sh
scripts/setup debug
build
ctest --output-on-failure
exit
```

The current native compiler/runtime target is POSIX (including `unistd.h`
and pthreads); non-POSIX targets are not supported. CMake reports a missing
`unistd.h`, and generated inline-C compilation diagnoses any required target
header that Clang cannot find rather than silently omitting it.
Installed application resources include the public opaque C API
`include/cwhip/Stdlib.h` and the linked runtime archive; application developers
do not need runtime implementation source. See
[the inline C API](STDLIB.md#inline-c-api) for supported bindings.

The CMake project, compiler executable, and compiler target are `cwhip`.
Language source inputs must use the `.cw` extension.

The root build is the recommended build. The `include/`, `src/`, and `tests/`
directories also have component `CMakeLists.txt` files; standalone
configuration is optional. To build only the compiler outside the repository's
in-tree build directory:

```sh
cmake -S src -B /tmp/cwhip-compiler-build -DCWHIP_GTK=OFF -DCWHIP_GTK_SOURCEVIEW=OFF
cmake --build /tmp/cwhip-compiler-build
```

Standalone `src/` configurations use the same fresh install-prefix default;
they remain separate from the root project's SDK registration step.

`tests/functional/` contains fixtures, not a separate buildable component.
The root build places the compiler and test executables in `bin/` and the
front-end archive in `lib/libcwhip_frontend.a`.

## Developer shell

Installation (`cmake --install`, below) puts a relocatable `cwhip` tree under a
prefix for users. Development of this checkout does not need installation:
`scripts/setup` configures the checkout and starts a project shell whose
`PATH` uses this checkout's freshly staged tools. It is an optional
convenience for bash; it installs no packages, never builds, commits or pushes
by itself, and leaves the shell you started it from unchanged.

```sh
~/Src/cwhip/scripts/setup debug
build
rebuild cwhip
exit
~/Src/cwhip/scripts/setup --clean release
```

`scripts/setup [--clean] [debug|release|profile]` works from any directory;
invoke the actual checkout script, not a symlink outside its `scripts/` directory.
Paths with spaces are supported.
`debug`, `release`, and `profile` select `CMAKE_BUILD_TYPE` `Debug`, `Release`,
and `RelWithDebInfo`. With no type, the existing cache is preserved; a fresh
build uses CMake's default (no forced Debug or Clang native compiler).
`--clean` can precede or follow the type and invokes `scripts/clean` before
configuration: it deletes `bin/`, `build/`, `lib/`, `share/`, and `doc/out/`,
not source or user settings. Duplicate/unknown arguments print usage and exit 2;
an active project shell is refused before parsing or cleaning.

Setup follows the template's interface. It does not discover an installed SDK
because this repository builds the SDK. The former `--build-dir`, `--submodules`,
`-D...`, and `-- CMAKE_ARGS...` options are no longer accepted. Update submodules
explicitly with Git if needed. For specialized configurations, use CMake directly
(as in the compiler-only, sanitizer and packaging examples below). To change a
cache option inside the shell, use `cmake -S "$_PROJECT_LOC" -B . -DNAME=VALUE`,
then `build`. Keep setup's default staging layout; custom build/staging prefixes
are direct-CMake workflows. GUI support uses normal
[GTK auto-detection](#optional-gtk-packages).

If CMake (or a required tool such as Clang) is missing or configuration fails,
setup prints the error and exits nonzero without starting a shell. Otherwise
it starts `bash -i` with `.project_env`, which:

- sources `~/.bashrc` when readable (it must not overwrite project variables);
- exports `_PROJECT_NAME` (checkout basename), `_PROJECT_LOC` (checkout),
  `_BUILD_TYPE` (lowercase mode), and `CWHIP_BUILD_TYPE` (CMake's cached type);
- puts the checkout's `bin/` (`cwhip` and `cwhip-pkg`)
  and `scripts/` first on `PATH`
  (`bin/cwhip-format` formats one `.cw` file);
- unsets `CWHIP_HOME`, `CWHIP_RUNTIME_DIR`, `CWHIP_INCLUDE_DIR`,
  `CWHIP_BUILTIN_DIR`, and `CWHIP_STDLIB_MODULE_DIR`, so the staged compiler
  finds its own staged resources instead of an installed or stale tree
  (`CWHIP_MODULE_DIR` and `CC` are left alone; check with `cwhip --print-paths`);
- prefixes the prompt with `<checkout>(debug):`, and changes to `build/`.

Inside the shell, `build [TARGET...]` and `rebuild [TARGET...]` are Bash functions,
not scripts. They run `cmake --build "$_PROJECT_LOC/build" --parallel 12`
(with `--clean-first` for `rebuild`), preserve CMake's exit status, and keep
the shell alive; for example `build` or `build cwhip`. They work even after
changing directory. They are not available outside the project shell.
`clean` remains a script and removes the checkout's default generated
directories; exit the shell and run setup again afterwards.
Until the first `build`, `cwhip` on `PATH` may be an installed compiler, so build
before using it. The Git shortcuts `status`, `add [PATH...]`, `commit`, `push`,
and `all` (add all, commit, push) run at the checkout root only when typed.
`dbg SOURCE.cw|EXECUTABLE [-- ARGS...]` passes arguments directly to standalone
[cdbg](https://github.com/cwhip-lang/cdbg) on `PATH`; it has no KDbg fallback.
Neither debugger is needed to run setup.

To use the checkout's tools on a separate project, start the shell and change
directory there; the staged tools stay first on `PATH`:

```sh
~/Src/cwhip/scripts/setup
build
cd ~/Src/cwhip_scratch
cwhip hello.cw
```

Type `exit` to return to the original shell. Starting setup again inside a
project shell is refused; exit first, then run it with another mode.

## Optional GTK packages

The SDK retains the GTK and SourceView packages used by external GUI applications.
For building and installing the standalone editor and debugger, see
[the application walkthrough](GETTING_STARTED.md#build-and-start-cedit-and-cdbg).

On a fresh configuration, CMake detects `pkg-config`, GTK 4.10+ and GtkSourceView 5
development files and defaults `CWHIP_GTK` and `CWHIP_GTK_SOURCEVIEW` to the
available support. On Debian/Ubuntu the GUI development packages are
`pkg-config libgtk-4-dev libgtksourceview-5-dev`. No packages are installed
automatically. An ordinary compiler build (including `--target cwhip`) builds
the enabled native package archives and stages their sources, manifests and
language resources. GTK and GtkSourceView link only into importing applications,
never into `cwhip` or non-GUI programs.

With those development dependencies installed, build a GUI-capable SDK:

```sh
scripts/setup debug
cmake -S "$_PROJECT_LOC" -B . -DCWHIP_GTK=ON -DCWHIP_GTK_SOURCEVIEW=ON
build
cmake --install .
exit
```

For a deliberate compiler-only configuration, including on machines without
GUI development files:

```sh
cmake -S . -B build-compiler -DCWHIP_GTK=OFF -DCWHIP_GTK_SOURCEVIEW=OFF
cmake --build build-compiler --target cwhip -j4
```

Explicit `ON` options require their
development dependencies and fail configuration if missing;
`CWHIP_GTK_SOURCEVIEW=ON` requires `CWHIP_GTK=ON`. Defaults are cached: after
installing GUI dependencies into an existing compiler-only configuration,
reconfigure with both options `ON`.

With GTK enabled and `BUILD_TESTING=ON` (the root-build default), headless GUI
tests default to enabled when Xvfb and `dbus-daemon` are found
(`xvfb dbus-daemon` on Debian/Ubuntu). Otherwise configuration explicitly
reports that GUI tests are disabled; this does not block building the SDK.
Set `-DCWHIP_GTK_TESTS=ON` to require these tools and fail if missing, or use
`-DBUILD_TESTING=OFF` to omit all tests. Enabled tests never silently skip
missing fixtures. Xvfb can be selected with
`-DCWHIP_XVFB_EXECUTABLE=/absolute/path/to/Xvfb`. Each GUI test uses a private
display and session bus.

Disabled packages are absent from staging and installation. Use separate
`CWHIP_STAGE_PREFIX` directories for simultaneous different configurations.
The enabled `gtk/0.1.0` manifest carries GtkSourceView link metadata when
appropriate. See [GTK.md](GTK.md) for linkage, activation and ownership.

## Install layout and relocation

Without an install-prefix override, a fresh compiler/SDK configuration uses
`$HOME/opt/cwhip`. Configure, build, and install:

The following direct CMake commands support SDK users/packagers without a
project shell. Developers can instead use `scripts/setup`, `build`, and
`cmake --install .` from the child shell.

```sh
cmake -S . -B build
cmake --build build
cmake --install build
```

Use `-DCMAKE_INSTALL_PREFIX=/absolute/path` to select another prefix, including
`/usr/local`. For a new build directory, CMake 3.29 and newer also accepts the
`CMAKE_INSTALL_PREFIX` environment variable. Existing build directories retain
their cached prefix on reconfigure. An install-time override,
`cmake --install build --prefix /absolute/path`, applies only to that install.
When the default is selected, `HOME` must be set to an absolute path;
configuration fails explicitly otherwise.

For a staged package or image, use `DESTDIR`:

```sh
DESTDIR=/tmp/stage cmake --install build
```

 CMake's `GNUInstallDirs` control the destinations. The installed tree contains
the `cwhip` executable in
`${CMAKE_INSTALL_BINDIR}`, the runtime archive in
`${CMAKE_INSTALL_LIBDIR}/cwhip/`, runtime headers in
`${CMAKE_INSTALL_INCLUDEDIR}/cwhip/`, the String builtin in
`${CMAKE_INSTALL_DATADIR}/cwhip/builtin/`, standard modules in
`${CMAKE_INSTALL_DATADIR}/cwhip/modules/`, and documentation in
`${CMAKE_INSTALL_DOCDIR}` plus `${CMAKE_INSTALL_MANDIR}/man1/cwhip.1`.
The documentation install also preserves the repository-relative
`doc/`, `tests/`, and `stdlib/` indexes and references.
The root `CWHIP-LANGUAGE-NOTES.md` entry links to the complete notes under
`doc/`, where their relative language-reference and library links resolve.
Installation directories must remain inside `CMAKE_INSTALL_PREFIX`.

The compiler derives resources relative to its executable and the installation
prefix; an installed tree can be moved as a unit. Runtime, header, builtin,
standard-module and user-module paths use the `cwhip/` directory. Resource lookup can be
overridden with `CWHIP_RUNTIME_DIR`, `CWHIP_INCLUDE_DIR`, `CWHIP_BUILTIN_DIR`, or
`CWHIP_STDLIB_MODULE_DIR` individually, or with `CWHIP_HOME` for the prefix.
`CC` selects the compiler-driver executable in place of the configured Clang
driver. The editor writes preferences to `$XDG_CONFIG_HOME/cwhip/settings.toml`
(or `~/.config/cwhip/settings.toml`) and project metadata to `.cwhip/`.
`cwhip-shortcuts.conf` in the working directory remains an optional shortcut
import source. Older product-named settings, shortcut, and project metadata
paths are ignored; they are left untouched and are not migrated. Copy any
settings you want to retain into the new paths yourself.
User preferences previously read by `cwhip-pkg env` from
`$XDG_CONFIG_HOME/cwhip/preferences.toml` or `~/.config/cwhip/preferences.toml`
remain at those locations. Use `cwhip --print-paths` to inspect the resolved executable, resources,
every package root and its precedence, project lock location, and Clang executable.

The former `prelude/` source directory, `share/cwhip/prelude/` resource path,
and `CWHIP_PRELUDE_DIR` override have been replaced by `builtin/`,
`share/cwhip/builtin/`, and `CWHIP_BUILTIN_DIR`. No legacy path fallback or
environment alias is supported: rebuild and reinstall the compiler and its
resources together, and update any resource overrides. `CWHIP_BUILTIN_DIR`
names the directory containing `String.cw`, not a project package root.

### Leftover packages from other projects

Other projects (for example a separately installed CVM) may install their own
packages into `${CMAKE_INSTALL_DATADIR}/cwhip/modules/`. Reinstalling the SDK
replaces only the packages the SDK provides; it never removes or relabels
anyone else's packages. `cwhip-pkg` scans every installed package version,
including unused ones, so one left over from an older SDK ABI (a missing or
different `[package] sdk-abi`) makes commands such as `cwhip-pkg init` fail
with `PKG2004`.

After copying its files, `cmake --install` checks the installed module
directory (below `DESTDIR` when set, and for the `--prefix` being installed).
By default it changes nothing: it lists each incompatible package version as a
`cwhip-install: warning` and the install still succeeds. Fix them by
reinstalling each package from a source version built for the current SDK ABI,
by removing package directories you no longer need, or by explicitly opting in
to a repair for that one install:

```sh
CWHIP_QUARANTINE_INCOMPATIBLE_PACKAGES=1 cmake --install build
```

The repair moves each complete incompatible package version directory,
unchanged, to a new
`${CMAKE_INSTALL_DATADIR}/cwhip/package-backups/<UTC timestamp>/modules/<name>/<version>`
directory that package discovery never reads. Each backup has a `RESTORE.txt`
listing the original and backup locations and how to move a package back;
existing backups are never overwritten. SDK-installed and compatible packages
stay in place. Directories are moved with a rename only, so nothing is copied
or deleted; a failed move stops the install and reports what was already moved.
Repeating the install has nothing left to move and creates no new backup.
The variable accepts `1` (repair) or `0`/unset (report only); any other value
fails the install. Before creating or moving anything, the repair refuses (and
fails the install) when an incompatible package or version directory is a
symlink, when the backup directory resolves inside the module directory, or
when a package is on a different filesystem from the backup; fix those packages
manually. Report-only mode still lists symlinked packages. Compatible symlinked
packages are never touched. Unreadable or malformed manifests (invalid TOML, no
`[package]` table, or a non-string `sdk-abi`) cannot be classified safely, so
they fail the install in either mode without moving anything.

### SDK location setting

A real (non-`DESTDIR`) `cmake --install` records the install prefix as a
top-level string in `$XDG_CONFIG_HOME/cwhip/sdk.toml` (or
`$HOME/.config/cwhip/sdk.toml` when `XDG_CONFIG_HOME` is unset/empty):

```toml
sdk_prefix = "/usr/local"
```

The value is the complete install prefix containing `bin/`,
`lib/cmake/Cwhip`, and the runtime resources, honoring `CMAKE_INSTALL_PREFIX`
and `cmake --install --prefix`. Parent directories are created, the key is
replaced in place or added above the first table, and other SDK configuration
and comments are preserved. App preferences in `cwhip/settings.toml` are never
changed by registration. Failures (relative prefix, no config home, unwritable
directory, a multi-line `sdk_prefix` value) fail the install. A `DESTDIR`
install never writes the setting because the staged path is not a runtime
prefix. Disable the step with `-DCWHIP_REGISTER_SDK=OFF`.

The same registration also updates `[applications].install_prefix` to the
actual installed prefix and `[applications].build_type` to the selected Cwhip
build configuration. External CMake projects can inherit these defaults with
`find_package(Cwhip ...)` followed by `cwhip_apply_application_defaults()`
before `project()`; explicit command-line values, CMake environment settings,
and existing cache choices take precedence. The helper applies registered
defaults only when the selected `Cwhip_PREFIX` matches the registered
`sdk_prefix`.

The non-empty `CWHIP_SDK` environment variable overrides the `sdk_prefix` setting
and bypasses configuration parsing. Consumers read legacy `settings.toml` only
when `sdk.toml` is absent. An existing `sdk.toml` is authoritative: malformed or
unreadable files and invalid explicit values fail, while a missing key permits
ordinary discovery without reading legacy preferences. To migrate, reinstall
or copy just the top-level key to `sdk.toml`; lookups never migrate or rewrite
either file. Leave `sdk.toml` empty to disable a legacy registration without
changing preferences. See [SDK selection](GETTING_STARTED.md#sdk-selection-and-configuration).

## Breaking path changes

Use the `cwhip-pkg` command with a `cwhip-pkg.toml` manifest and
`cwhip-pkg.lock`; published package directories use `cwhip-package.toml`.
Source inputs use `.cw`, public runtime headers are under `include/cwhip/`,
and resource overrides use `CWHIP_*` variables. Editor preferences are under
`cwhip/settings.toml`, and editor project metadata is under `.cwhip/`.
These names do not alias earlier product paths. Existing manifests, settings,
shortcuts, projects, installed resources, and native libraries are neither
deleted nor rewritten by the compiler or editor; they are not discovered or
migrated automatically.

## Project module search

The compiler discovers project configuration separately from package storage.
The project root is the nearest ancestor of the first Cwhip source input
containing `cwhip-pkg.toml` or a `modules` directory; without a marker it is the
source parent. With no source input, discovery starts at the current directory.
This source-based discovery is the same for relative and absolute source paths.
The manifest and adjacent `cwhip-pkg.lock` remain at that root regardless of
package-root overrides.

Package imports use ordered first-match lookup through these roots:

1. `-M DIR`/`--module-dir DIR`, when provided.
2. `<project-root>/modules`.
3. `CWHIP_MODULE_DIR`, when set.
4. The user package root `<config-home>/cwhip/modules`, normally
   `~/.config/cwhip/modules`. If `XDG_CONFIG_HOME` is set, it is used as
   `<XDG_CONFIG_HOME>/cwhip/modules` and must be absolute.
5. Standard modules shipped with the compiler, normally
   `<prefix>/share/cwhip/modules`, configurable with `CWHIP_STDLIB_MODULE_DIR`.

The first root containing a package shadows lower-priority roots, and version
selection occurs only among versions in that root. Project and home roots are
optional fallbacks when missing; explicit `-M` and `CWHIP_MODULE_DIR` roots must
exist for compilation. `-M` and `CWHIP_MODULE_DIR` add storage roots; they never
move or replace the discovered project's manifest or lock. `-p`/`--path` sets
the separate textual `include` search path. Package layout and APIs are
described in the [standard library docs](STDLIB.md) and
[`stdlib/README.md`](../stdlib/README.md); exact CLI behavior is in
[cwhip(1)](cwhip.1).

### Locked project dependencies

New projects use `cwhip-pkg.toml` for direct dependencies and generated
`cwhip-pkg.lock` for the complete exact graph. The compiler checks the lock schema,
manifest fingerprint, dependency pins, and hashes of packages used by the
compilation. It never accesses the network. Missing, stale, or invalid locks
are errors, not invitations to fall back to another version or root. A storage
override can satisfy a lock only when the locked package name, exact version,
dependency edges, and content hash match; a conflicting or invalid higher
root is reported rather than bypassed. Imports not listed in the lock are
rejected. `-M` and `CWHIP_MODULE_DIR` do not select another project's policy.
See [the package schema](PACKAGES.md).

The previous `--package-path`, `CWHIP_PACKAGE_PATH`, `CWHIP_MODULE_REGISTRY`,
`./cwhip-modules.tsv`, and `modules/modules.toml` lookup/policy mechanisms have
been removed. They have no compatibility aliases or fallback behavior. Legacy
policy files are not imported, changed, or automatically migrated. To adopt the
new package workflow, create a separate project with `cwhip-pkg init`, then
declare and install dependencies with `cwhip-pkg add`/`cwhip-pkg install`.
`cwhip --print-paths` reports the project lock and every applicable package
root with its origin and order.

## Project package manager (`cwhip-pkg`)

### Check the SDK and host

`cwhip-pkg doctor` performs read-only checks without network access. It prints
`PASS`/`FAIL` for required checks and `PASS`/`WARN` for optional checks, with
remedies for failures. Exit status is 0 only if all required checks pass.
It never creates or changes settings, package locks, or project files.

SDK selection is a non-empty `CWHIP_SDK` override, then the top-level
`sdk_prefix` in `$XDG_CONFIG_HOME/cwhip/sdk.toml`, or
`$HOME/.config/cwhip/sdk.toml` when XDG is unset/empty. Only if that file is
absent is legacy `settings.toml` in the same directory read. A non-empty XDG
must be absolute and selects the only configuration root, with no fallback to
HOME. Invalid configuration fails explicitly; an override bypasses parsing.
Selected prefixes must be non-empty absolute existing directories without
NUL or line breaks. Without any selection, doctor visibly
checks the prefix containing its own executable; it does not emulate CMake's
package search or silently select another installation.

Required checks cover Python >=3.11, the compiler and its startup, runtime,
public runtime/GC headers, String builtin, bundled standard packages, installed
CMake config/version/helpers, Clang/`CC`, Git, and CMake >=3.24 (the template's
minimum). `CC` must name a Clang driver executable, not a shell command;
otherwise the build-configured Clang is selected, with visible PATH fallback
if missing. GTK4 >=4.10 and GtkSourceView5 via `pkg-config` are optional GUI
application-development checks. A staged compiler development tree without
installed CMake SDK files fails those checks: install the complete prefix for
external projects. Existing compiler resource overrides are not treated as a
replacement for a complete SDK.

### Create a project

```sh
cwhip-pkg new MyApp
MyApp/scripts/setup debug
build
../bin/MyApp
exit
```

`new NAME [DIRECTORY]` downloads a tar archive of
[`cwhip-lang/app-template`](https://github.com/cwhip-lang/app-template),
not a Git clone. `--ref BRANCH_OR_TAG_OR_COMMIT` selects a ref (default `main`;
the template currently has no release tags). Invoking `new` explicitly requests
this download; it does not require the package installer's `--yes`. The template
and GitHub service are trusted sources, not a sandbox for arbitrary build code.

For offline creation, use `--source /path/to/template.tar.gz`,
`--source /path/to/template.zip`, or `--source /path/to/template-directory`.
This bypasses downloading entirely (`--ref` has no effect on a local source).
The destination must be outside a local source directory to avoid copying the
output into itself. Project names are ASCII identifiers starting with a letter,
at most 128 characters; language keywords and CMake's reserved targets are
rejected. The CMake project, executable target/references, and template Markdown
names become NAME; the example source remains intact.

The destination defaults to `./NAME`. Its parent must exist; an existing empty
directory is allowed, but non-empty directories, files and symlink destinations
are refused. Extraction rejects traversal, links (including internal links),
special files and duplicate file entries. Archives are limited to 32 MiB,
expanded content to 128 MiB, and entries to 10,000. Git metadata is omitted;
no repository is initialized. Output is staged beside the destination and
published only after validation/renaming, with partial staging removed on
failure. The project uses your installed SDK; creation does not build or
install the SDK or change user settings.

### Manage dependencies

Compiler and package CLI error headers follow the
[diagnostic contract and code registry](DIAGNOSTICS.md). Diagnostics go to
stderr, normal results to stdout; usage normally exits 2 and operation failure
exits 1 (including the documented legacy exceptions in that contract).
Compiler source-location lines and detailed backend failures remain available.

`cwhip-pkg` is a small project manager and GitHub package installer. The
compiler remains responsible for compiling and building programs; `cwhip-pkg`
does not run programs or implement compiler build logic. It is installed beside
`cwhip` and uses the standard modules shipped with that same installation.

Start a project from its root:

```sh
mkdir hello-cwhip
cd hello-cwhip
cwhip-pkg init
cwhip-pkg add OWNER/REPO --yes
cwhip path/to/app.cw
```

`cwhip-pkg init [PROJECT_DIR]` creates `cwhip-pkg.toml`, `cwhip-pkg.lock`, and the
`modules` directory, locking the installed standard modules locally without
network access. It refuses to overwrite existing configuration. The compiler's
`String` builtin/runtime is available by default; it is not an ordinary
imported module and is not listed in the lockfile's module allowlist or packages.

`cwhip-pkg add OWNER/REPO [VERSION] --yes` obtains a package from that GitHub
repository, using Git's configured authentication for private repositories
that the user can access. With no version it picks the highest stable SemVer
tag; with a version it checks out that exact SemVer tag (including a
prerelease, if requested). It validates
`cwhip-package.toml` and the package source, resolves all exact transitive
dependencies, and installs into `modules/<package-name>/<version>/`. It saves
the direct dependency in `cwhip-pkg.toml` and generates the complete graph in
`cwhip-pkg.lock`, including repository, tag, commit, content digest, and edges.
Existing versions are never overwritten: different contents at an existing
destination are an integrity error. Run `cwhip-pkg list` to inspect selections.

GitHub `OWNER/REPO` is a direct repository shortcut, not a package catalog:
there is no central index or guessed repository lookup. A dependency's
repository must be declared in its package's `[sources]` table or explicitly
mapped in the project's `[sources]` table. Bundled packages are resolved
locally. Missing mappings and conflicting exact pins fail explicitly. Ranges,
branches, arbitrary URLs, install scripts, and automatic builds are not
supported.

Before network access, `cwhip-pkg` prints the requested plan and requires explicit
confirmation, or `--yes` for noninteractive use. Each declared repository is
shown before it is contacted; `--yes` authorizes the declared transitive
repositories too. Without consent, redirected/noninteractive input fails
without fetching. `--dry-run` shows the known plan without network access;
`--dry-run --yes` may fetch metadata and resolve the full graph, but does not
install or modify project files. A full resolved graph is printed before
installation. Review untrusted repositories before granting consent: fetched
source can contain native bindings used during later compilation.

`cwhip-pkg install --yes` restores a committed lockfile's exact commits and
verifies hashes, rather than trusting potentially moved tags. With no lock it
resolves the direct manifest. Commit both manifest and lock; do not hand-edit
the lock or maintain transitive version arrays. `add`, `install`, and `list`
locate the project from nested working directories. After `add` or `install`,
ordinary `cwhip src/nested/app.cw` is compile-ready with no environment eval.
Legacy projects without `cwhip-pkg.toml` retain their old policy and explicit
dependency installation contract.

`cwhip-pkg env` prints POSIX shell exports; it does not modify the parent shell.
It reads optional user preferences from
`$XDG_CONFIG_HOME/cwhip/preferences.toml`, or
`~/.config/cwhip/preferences.toml` when `XDG_CONFIG_HOME` is unset. Create the
file yourself if desired; only `[environment]` string values are supported:

```toml
[environment]
CC = "clang"
MY_BUILD_SETTING = "debug"
```

Then `eval "$(cwhip-pkg env)"` applies those values in the current shell. An
alternate existing file can be selected with `cwhip-pkg env --preferences FILE`;
`cwhip-pkg` never creates or edits preference files. Environment names must be
valid shell variable names. Package lookup needs no activation: source-based
project discovery works from nested directories and for absolute source paths.
User packages installed at `<config-home>/cwhip/modules` are searched after
project packages and before installation defaults.
