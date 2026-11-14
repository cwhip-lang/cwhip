# Getting started with Cwhip

This guide takes you from source installation to a running Cwhip program, then
introduces editing, debugging, and packages. Start with the **compiler-only**
route; add the optional GTK SDK and standalone applications when you need them.
Cwhip and its applications are active prototypes, not a production toolchain
with a stable cross-version ABI.

For a shorter editor-led walkthrough without a project generator or package
downloads, follow [Your first program](FIRST-PROGRAM.md): install the SDK,
build standalone cedit with its own `scripts/setup`, and write/run hello world.

## Contents

- [What you will install](#what-you-will-install)
- [Host prerequisites](#host-prerequisites)
- [Build and install the SDK](#build-and-install-the-sdk)
- [SDK selection and configuration](#sdk-selection-and-configuration)
- [Create and run your first project](#create-and-run-your-first-project)
- [Learn the source basics](#learn-the-source-basics)
- [Edit, compile, and debug](#edit-compile-and-debug)
- [Use packages](#use-packages)
- [Add the optional GUI SDK](#add-the-optional-gui-sdk)
- [Build and start cedit and cdbg](#build-and-start-cedit-and-cdbg)
- [Troubleshooting](#troubleshooting)
- [Where to go next](#where-to-go-next)

## What you will install

| Component | Current role |
| --- | --- |
| `cwhip` | Compiles `.cw` source to LLVM IR, then invokes Clang to produce native executables or objects. |
| Cwhip SDK | The complete installation prefix: compiler, runtime archive, public headers, String builtin, standard packages, package tool, and CMake integration. |
| `cwhip-pkg` | Checks the SDK/host, creates projects, and manages project dependencies and locks. It does not build or run applications. |
| [app-template](https://github.com/cwhip-lang/app-template) | A small installed-SDK consumer, used by `cwhip-pkg new`. |
| [cedit](https://github.com/cwhip-lang/cedit) | Optional standalone GTK source editor; not a compiler/debugger integration or semantic language service. |
| [cdbg](https://github.com/cwhip-lang/cdbg) | Optional standalone local GDB/MI debugger; can compile a `.cw` target with debug information or load a built executable. |
| [cmacros](https://github.com/cwhip-lang/cmacros) | Optional standalone command-line macro processor implemented in Cwhip. It processes UTF-8 input independently of the compiler and does not invoke a shell or subprocess. |

Install and retain the **whole SDK prefix**, not just `bin/cwhip`. Host Clang,
Python, Git, and shared system libraries are not bundled. This guide uses source
builds; it does not assume binary installers or packaged application releases.
`cmacros` has its own build and installation instructions in
[its build guide](https://github.com/cwhip-lang/cmacros/blob/main/doc/BUILD.md);
the [macro language reference](https://github.com/cwhip-lang/cmacros/blob/main/doc/LANGUAGE.md)
and [examples guide](https://github.com/cwhip-lang/cmacros/blob/main/examples/README.md)
describe its input syntax and runnable examples. It is an optional standalone
tool, not part of the compiler command or package workflow. `cparsegen` is a
separately built, bounded parser-generator prototype that emits parsers for
Cwhip or standalone ISO C99. See its
[input/output reference](https://github.com/cwhip-lang/cparsegen/blob/main/doc/INPUT-OUTPUT.md)
for supported grammar features, commands, and limits.

## Host prerequisites

Use a Linux/POSIX development environment. The runtime requires POSIX headers
(including `unistd.h`) and pthreads; native Windows is not supported. These
instructions target Linux, not a verified macOS installation procedure.

For the complete workflow below, install:

| Requirement | Why |
| --- | --- |
| CMake **3.24+** and a build tool such as Make or Ninja | The compiler root accepts 3.16+, but external template/app projects and `doctor` require 3.24+. |
| C11 and C++17 compilers and platform development headers | Build the C runtime and C++ compiler frontend. GCC or Clang can build these native components. |
| **Clang** available as `clang` on `PATH` | Required even when GCC builds the frontend: it compiles generated LLVM IR and native bindings and links programs. |
| Python **3.11+**, available as `python3` | SDK/package tooling and TOML settings parsing. |
| SQLite 3 development files and pthreads | Required by the SDK build, including the bundled SQLite package. |
| Git and network access | Clone sources and explicitly install GitHub dependencies; project creation downloads a template archive. Offline creation is also supported. |

There is no separately declared minimum Clang version in the build. Use a
current host Clang and verify it by building/running the example below; do not
substitute GCC for the LLVM IR backend. A separate LLVM development SDK is not
required by these build commands.

For example, on **Ubuntu 24.04 or Debian 13**, the compiler-only prerequisites
can be installed with the distribution's package manager:

```sh
sudo apt update
sudo apt install build-essential cmake clang python3 git libsqlite3-dev
cmake --version
python3 --version
clang --version
```

On another release/distribution, use its equivalent development packages and
check the actual versions. Ubuntu 22.04's default Python/CMake and Debian 12's
default GTK do not satisfy the entire workflow. Do not assume identical package
names imply adequate versions. No Cwhip command installs system packages for you.
GTK, GtkSourceView, a desktop display, and GDB are **not** prerequisites for the
compiler-only hello-world route.

## Build and install the SDK

The following commands run in a POSIX shell. A fresh configuration without an
explicit install prefix uses `$HOME/opt/cwhip`, separate from system software
and requiring no `sudo` for build/install. If it already contains another SDK,
choose a new prefix instead of mixing installations.

For compiler development, prefer `scripts/setup [--clean] [debug|release|profile]`,
then `build`/`rebuild [TARGET...]` in the child Bash shell (initially in `build/`).
`clean` removes generated build/staging directories; exit and rerun setup
afterwards. With no type, setup preserves the cached type or CMake's default.
The SDK installation below deliberately uses direct CMake for compiler-only
flags, private staging and a non-interactive installation; setup does not accept
`-D` arguments or custom build directories.

```sh
mkdir -p "$HOME/Src"
cd "$HOME/Src"
git clone https://github.com/cwhip-lang/cwhip.git
cd cwhip

cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug \
  -DCWHIP_STAGE_PREFIX="$PWD/build/stage" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_TESTING=OFF \
  -DCWHIP_GTK=OFF -DCWHIP_GTK_SOURCEVIEW=OFF
cmake --build build --target cwhip --parallel 4
cmake --install build
```

`BUILD_TESTING=OFF` keeps this first install focused on the SDK. For compiler
development/testing, enable testing, build the default targets, and follow
[Testing infrastructure](TESTING.md). The explicit stage prefix keeps generated
compiler resources inside `build/stage`, separate from both source files and
the installed prefix. Building target `cwhip` also builds/stages its required
runtime and enabled package archives. The editor and debugger are standalone
projects; this compiler install does not build or install them.

Put the installed tools first on `PATH` for this shell:

```sh
export PATH="$HOME/opt/cwhip/bin:$PATH"
command -v cwhip
command -v cwhip-pkg
cwhip --version
cwhip --print-paths
cwhip-pkg doctor
```

To keep that PATH choice across logins, add only the `export PATH=...` line
to your shell's appropriate startup file, preserving its existing contents.
An installed `sdk_prefix` setting does not itself modify shell `PATH`.

Pass `-DCMAKE_INSTALL_PREFIX=/absolute/path` to choose another location,
including `/usr/local`. For a new build directory, CMake 3.29 and newer also
accepts the `CMAKE_INSTALL_PREFIX` environment variable. Existing build
directories retain their cached prefix on reconfigure. A per-install
`cmake --install build --prefix /absolute/path` takes precedence over the
configured value. Without an explicit prefix or absolute `HOME`, configuration
fails rather than constructing an invalid default path.

`doctor` is read-only and uses no network. Required checks should all say
`PASS`; missing optional GTK checks can say `WARN` without failing a
compiler-only installation. Optional GUI checks describe the **host development
libraries**, not proof that this SDK was built with GTK. An SDK built with both
GTK options off still needs the GUI rebuild below before it can be used to build
the standalone cedit/cdbg projects.

### Install side effects, staging, and relocation

A normal `cmake --install` records the real install prefix as the top-level
`sdk_prefix` setting in `cwhip/sdk.toml`, separately from app preferences in
`cwhip/settings.toml`. The installer creates parent configuration directories
and updates/adds that key while preserving unrelated SDK configuration/comments.
It never writes the preferences file. Registration failures fail the install,
even if some SDK files have already been copied.

| Installation choice | Effect on SDK registration |
| --- | --- |
| `cmake --install build` | Records the configured `CMAKE_INSTALL_PREFIX` for the user running the command. |
| `cmake --install build --prefix /absolute/other-prefix` | Installs there and records that real prefix. |
| Configure with `-DCWHIP_REGISTER_SDK=OFF` | Installs the SDK without writing SDK configuration; select it explicitly afterwards. |
| `DESTDIR=/absolute/staging-root cmake --install build` | Creates a staged filesystem tree; deliberately does **not** register it as a usable SDK. |

`DESTDIR` is for packaging/image staging, not a way to select the SDK used by
your projects. Running installation under `sudo` can target root's configuration or
unintended inherited configuration; use the user-local install here instead.
For CI or a trial installation, use registration opt-out, or set **both** `HOME`
and absolute `XDG_CONFIG_HOME` to private directories before installation.

The installed SDK can move as a whole. After moving it, update your PATH and
select the new prefix with `CWHIP_SDK` or update only the `sdk_prefix` key.
An old setting is not automatically rewritten by moving files. See the
[installed layout and relocation contract](CMAKE-SDK.md).

## SDK selection and configuration

The template and standalone cedit/cdbg CMake projects select their SDK in this
order:

1. A non-empty `CWHIP_SDK` environment override.
2. The top-level string `sdk_prefix` in the selected `cwhip/sdk.toml`.
3. Only if `sdk.toml` is absent, the legacy top-level `sdk_prefix` in
   `cwhip/settings.toml` in the same configuration directory.
4. Normal CMake discovery (`CMAKE_PREFIX_PATH` or `Cwhip_DIR`) when no
   selection is present.

For example, temporarily select the complete SDK prefix:

```sh
export CWHIP_SDK="$HOME/opt/cwhip"
```

The SDK configuration is `$XDG_CONFIG_HOME/cwhip/sdk.toml` when
`XDG_CONFIG_HOME` is non-empty, otherwise `$HOME/.config/cwhip/sdk.toml`.
A non-empty XDG path must be absolute and selects the **only** configuration root:
there is no fallback to HOME's file. A normal installation needs an absolute
config home from XDG or HOME. A consumer without either can still use explicit
SDK selection or normal CMake discovery.

The relevant setting looks like this; this is a key example, **not a replacement
SDK configuration file**:

```toml
sdk_prefix = "/absolute/path/to/the/complete/sdk"
```

Keep it above any `[table]` headings. The value must be a non-empty absolute
existing directory without NUL or line breaks. Explicit `CWHIP_SDK` bypasses
configuration parsing, including a malformed file. Otherwise malformed/unreadable
configuration or an invalid selected prefix stops configuration rather than
silently choosing another SDK. An existing `sdk.toml` is authoritative: even
without `sdk_prefix` it prevents legacy fallback and permits normal discovery.
An explicit selection wins over `CMAKE_PREFIX_PATH`.

To migrate, reinstall the SDK or copy just the top-level `sdk_prefix` to
`sdk.toml`; lookup never writes either file or removes the legacy key. New
registration leaves existing app preferences untouched, and later preference
rewrites cannot erase it. To return to normal discovery, unset `CWHIP_SDK`,
leave an empty `sdk.toml` (or remove the key from it), and clear a stale
`Cwhip_DIR` cache or use a fresh build directory. Deleting `sdk.toml` can
reactivate a legacy registration.

`cwhip-pkg doctor` follows the same override/configuration choices, but without
either it checks the prefix containing its own executable, **not** CMake's
search path. Check `command -v cwhip-pkg` when diagnosing a mismatch.

**Do not confuse consumer selection with compiler resource overrides.**
`CWHIP_SDK` selects the SDK for those consumers and doctor; the `cwhip`
executable normally finds resources relative to its own real executable.
`CWHIP_HOME` changes the compiler's resource prefix, and
`CWHIP_RUNTIME_DIR`, `CWHIP_INCLUDE_DIR`, `CWHIP_BUILTIN_DIR`, and
`CWHIP_STDLIB_MODULE_DIR` override individual resource directories.
`CWHIP_MODULE_DIR` adds a package storage root. None of those is a substitute
for selecting a complete installed CMake SDK. Avoid stale overrides during
first setup; inspect `cwhip --print-paths`. `CC`, when set, must name a Clang
driver executable, not a command plus flags.

## Create and run your first project

From a directory in which you want a new project:

```sh
cd "$HOME/Src"
cwhip-pkg new Hello
Hello/scripts/setup debug
build Hello
../bin/Hello
exit
```

Expected output:

```text
Hello, world!
```

`new NAME [DIRECTORY]` downloads the public template as an archive, without Git
history. It renames the CMake project and executable target to NAME. Thus this
project's target/output is **`Hello`**, not the raw template's `hello`.
`build` without a target also builds it as a default target. Project
creation does not install/build the compiler or initialize a Git repository.

The important files/directories are:

| Path | Purpose |
| --- | --- |
| `Hello/src/main.cw` | Your source. |
| `Hello/CMakeLists.txt` | Installed SDK discovery and the `Hello` program target. |
| `Hello/build/` | CMake intermediates and a private source project/package lock created by the SDK helper. |
| `Hello/bin/Hello` | Built executable, created during the build, not configuration. |
| `Hello/lib/` | Convention for application-owned native libraries; this small program need not create it. |
| `Hello/scripts/setup` | Optional Bash project shell, not an installer. |

The template's source is a complete program:

```cwhip
// test: {"stdout": "Hello, world!\n"}
start {
    print("Hello, world!\n")
}
```

The `// test:` comments in this guide are executable-documentation expectations;
they are ordinary comments to the compiler, not required program syntax.

### Choose a template ref, destination, or offline source

These are **alternative** project creation examples, not steps required for Hello:

```sh
cwhip-pkg new MyApp "$HOME/Src/my-app"
cwhip-pkg new PinnedApp --ref 7c14dbd0bca5c336700bc32f6fc8fba941eef889
cwhip-pkg new OfflineApp --source /absolute/path/to/app-template
cwhip-pkg new ArchivedApp --source /absolute/path/to/app-template.tar.gz
```

`--ref` accepts a branch, tag, or commit; the default is `main`, and the template
currently has no release tags. The pinned commit above is the template revision
used to verify this guide. A local directory, tar archive, or ZIP bypasses the
download entirely; `--ref` has no effect with `--source`. Keep the destination
outside a source directory. The parent directory must exist; the destination
must be absent or an empty real directory, not a symlink. Names must be ASCII
identifiers starting with a letter, at most 128 characters; reserved
language/CMake names are rejected.

Unlike dependency installation, `new` needs no `--yes`: asking for `new`
explicitly requests the template download. It is not a sandbox for untrusted
template build code. See [project creation details](INSTALLATION.md#create-a-project).

Setup configures then starts Bash in `Hello/build`; run `build` or
`rebuild [TARGET...]` and `../bin/Hello`, then `exit` to leave.
Use `Hello/scripts/setup --clean debug` for a fresh build, or `clean` in the
project shell to remove generated output (exit and rerun setup afterwards).
`release` selects Release and `profile`
selects RelWithDebInfo. With no argument, the generated helper inherits the
selected SDK's registered build type when available; existing CMake cache
choices, explicit options, and environment overrides take precedence. If no
build type is inherited or selected, CMake's default applies. Execute the setup
script; do not source it. Output paths can be overridden with `CWHIP_BIN_DIR`
and `CWHIP_LIB_DIR`; see the generated project's `doc/BUILDING.md`.

## Learn the source basics

Cwhip uses `.cw` files, newline-terminated statements, and brace-delimited
blocks. `#` and `//` start single-line comments; `/* ... */` is a block
comment. A semicolon is an unknown character, not a comment or separator.
Keywords are case-insensitive; identifiers are case-sensitive. Exactly one
`start` block is the executable entry point. Methods live in classes; there
are no free-standing functions.

Replace Hello's `src/main.cw` with this small example to try typed locals,
a method, a loop, and formatted output:

```cwhip
// test: {"stdout": "total=6\n"}
class Counter {
    public:
    int64 value

    Counter() {
        value = 0
    }

    int64 add(int64 amount) {
        value += amount
        return(value)
    }
}

start {
    Counter counter = Counter()
    int64 next = 1
    int64 total = 0
    while (next <= 3) {
        total = counter.add(next)
        next += 1
    }
    if (total == 6) {
        print("total={}\n", total)
    }
}
```

Construct an object with `ClassName(...)`, not a `new` keyword. Signed integer
types are `int8`, `int16`, `int32`, and `int64`; unsigned integer types are
`uint8`, `uint16`, `uint32`, and `uint64`; floating types are `fp32` and
`fp64`. Native `int`, `uint`, and `float` are checked aliases for the 32-bit
`int32`, `uint32`, and `fp32` types. Conditions require `bool`. `strg` and
`String` name the managed string type.
`list`, `dict`, `buffer`, and native `handle` types are also available.
Initialize fields in a constructor; field declarations have no in-class
initializer syntax.
Managed objects are garbage-collected; native resources still need appropriate
API-specific release/close handling.

`print` adds **no implicit newline**. Literal templates such as `"total={}\n"`
format arguments; `format("total={}", total)` returns a string. Do not call
a string literal as if it were a function.

Imports name packages, optionally with aliases. The following example needs
only the SDK's bundled `math` package:

```cwhip
// test: {"stdout": "sqrt(9)=3\n"}
import math as M

start {
    fp64 root = M.Math().sqrt(9.0)
    print("sqrt(9)={}\n", root)
}
```

Use the [language reference](LANGUAGE-REFERENCE.md) for collections, exceptions,
inheritance, callbacks, scope, and checked conversions; the
[grammar](GRAMMAR.md) specifies syntax. [Standard library APIs](STDLIB.md),
[package manifests](PACKAGES.md), and the
[native binding interface](LANGUAGE-REFERENCE.md#native-bindings-for-library-authors)
cover modules and external C interfaces without duplicating the manual here.

## Edit, compile, and debug

Use any text editor, or install cedit using the later section. From Hello's
root after saving `src/main.cw` (start setup outside any active project shell):

```sh
cd "$HOME/Src/Hello"
scripts/setup debug
cwhip --check-only ../src/main.cw
build Hello
../bin/Hello
exit
```

`--check-only` parses and checks without code generation. CMake tracks source
changes and rebuilds. To explicitly make a separate debug executable and retain
the generated IR:

```sh
mkdir -p bin build
cwhip -g src/main.cw --emit-llvm build/hello.ll -o bin/HelloDebug
./bin/HelloDebug
```

Use `-g` explicitly when compiling a debug target directly; a CMake build type
is not a flag on a standalone compiler invocation. For detailed backend
commands and resolved paths, add `-vv` to that compiler command. The
[compiler manual](cwhip.1) lists compile-only, include/library path, and trace
options.

If GDB is installed, a minimal terminal debugging session is:

```sh
gdb -q ./bin/HelloDebug
```

At the GDB prompt, use `break main`, `run`, `next`, `info locals`, and `quit`.
The generated `main` represents `start`. Debug visibility varies with source
scope and generated code; raw Step Into can enter runtime helpers, while
**cdbg** finishes those frames until a `.cw` stop. See
[debug information and stepping](DEBUGGING.md) for the boundaries.
The optional cdbg workflow below adds a GUI; **cedit does not compile or debug
source**, and its syntax highlighting is not a compiler parser.

## Use packages

The template's CMake helper creates a **private** project/lock under `build/`
for bundled standard packages. It does not automatically fetch external
dependencies, and that private lock is not a user-maintained project manifest.
For an explicit package workflow, initialize the source project itself once:

```sh
cd "$HOME/Src/Hello"
cwhip-pkg init
cwhip-pkg list
cwhip src/main.cw -o bin/HelloPackages
./bin/HelloPackages
```

`init` creates root `cwhip-pkg.toml`, `cwhip-pkg.lock`, and `modules/`, locking
bundled standard packages without network access. It refuses to overwrite
existing configuration; do not run it again on an initialized checkout.
`String` is implicit, not an ordinary package import.

For a **real package you have reviewed**, substitute its GitHub OWNER/REPO and,
optionally, its published SemVer VERSION in these command patterns:

```text
cwhip-pkg add OWNER/REPO VERSION --yes
cwhip-pkg add OWNER/REPO --yes
cwhip-pkg install --yes
cwhip-pkg list
```

`add` without VERSION chooses the highest stable SemVer tag; an explicit version
can name a prerelease. It validates `cwhip-package.toml`, resolves exact
transitive dependencies, installs into `modules/<name>/<version>/`, records
the direct manifest dependency, and updates the complete lock graph.
There is no central package catalog or guessed repository lookup: transitive
repositories need `[sources]` mappings in the package/project. Version ranges,
branch dependencies, arbitrary URLs, install scripts, and automatic native
builds are not supported.

Network access requires consent: omit `--yes` for interactive confirmation.
`--yes` also authorizes declared transitive repositories. Review the plan and
source first, especially native bindings that later compilation can execute.
`--dry-run` alone shows the known plan without network; `--dry-run --yes` can
fetch metadata to resolve the graph but does not install or change project files.

Commit both the manifest and lock. On another checkout, `install --yes`
restores exact locked commits and verifies hashes; do not hand-edit the lock.
Compile the project's source normally with `cwhip` afterwards: compilation
never fetches packages and needs no environment activation. `cwhip-pkg env`
only prints optional shell preferences; evaluating it is not a package step.

For now, use the direct `cwhip src/main.cw ...` route above with your external
graph. Do not assume the starter's unchanged `cwhip_add_program` helper will
consume the new root manifest/lock: it supports bundled packages in its private
project, not arbitrary package-fetching builds. Integrating an external graph
into your own CMake rules is an explicit application responsibility; see
[the helper's scope](CMAKE-SDK.md#cmake-discovery-and-a-native-binding).

Package lookup starts with `-M`, then project `modules/`, `CWHIP_MODULE_DIR`,
user `<config-home>/cwhip/modules`, and the SDK's bundled modules. The first
root containing a package wins, even if its contents conflict with your lock.
Project discovery starts at the first source's parent and walks to the nearest
manifest or `modules` marker. `-M` changes storage precedence, **not** which
project lock applies. See [package search and lock validation](INSTALLATION.md#project-module-search).

## Add the optional GUI SDK

cedit and cdbg require **both** an SDK built with GTK/SourceView support and
matching host development/runtime libraries. First install `pkg-config`,
**GTK 4.10+**, and **GtkSourceView 5** development files. On Ubuntu 24.04 or
Debian 13, for example:

```sh
sudo apt install pkg-config libgtk-4-dev libgtksourceview-5-dev gdb
pkg-config --modversion gtk4
pkg-config --atleast-version=4.10 gtk4
pkg-config --modversion gtksourceview-5
```

Check the exit status of `--atleast-version`; success is silent. Debian 12's
GTK 4.8 and Ubuntu 22.04's GTK 4.6 do **not** satisfy GTK 4.10. If your repositories
are too old, use a newer distribution/development environment, or build the
upstream libraries and their dependencies in a separate prefix following the
[GTK Linux installation guidance](https://www.gtk.org/docs/installations/linux/)
and [GtkSourceView documentation](https://gnome.pages.gitlab.gnome.org/gtksourceview/gtksourceview5/).
Make that prefix visible to `pkg-config` and the runtime loader as described by
those projects, then rerun the checks. Merely installing old packages or changing
CMake flags cannot add missing GTK APIs. This guide does not prescribe replacing
your system GTK in place.

From your compiler source checkout, use a **separate** build, stage, and install
prefix so a compiler-only cache or stale installed files cannot mask the choice:

Direct CMake is used here because these build/staging/install directories and
required GUI options are intentionally separate from the default developer shell.

```sh
cd "$HOME/Src/cwhip"
cmake -S . -B build-gui -DCMAKE_BUILD_TYPE=Debug \
  -DCWHIP_STAGE_PREFIX="$PWD/build-gui/stage" \
  -DCMAKE_INSTALL_PREFIX="$HOME/.local/cwhip-gui" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_TESTING=OFF \
  -DCWHIP_GTK=ON -DCWHIP_GTK_SOURCEVIEW=ON
cmake --build build-gui --target cwhip --parallel 4
cmake --install build-gui
export CWHIP_SDK="$HOME/.local/cwhip-gui"
export PATH="$CWHIP_SDK/bin:$PATH"
cwhip-pkg doctor
```

The real install updates `sdk_prefix`; an existing non-empty `CWHIP_SDK` still
wins, hence the explicit export. Fresh compiler builds auto-detect GUI
dependencies when options are omitted, but cached defaults do not change when
libraries are installed later. Explicit `ON` requires the libraries and fails
if missing. GTK links into applications that import it, not the compiler or
ordinary non-GUI programs.

## Build and start cedit and cdbg

These are independent repositories consuming the installed **0.0.2** SDK,
including its `Cwhip_APPLICATION_OUTPUT_DIRECTORIES` capability. They do not
need a compiler source checkout or an umbrella workspace. Older 0.0.1
installations must be rebuilt/reinstalled for the numeric-v2 ABI.

With the GUI SDK selected as above:

```sh
cd "$HOME/Src"
git clone https://github.com/cwhip-lang/cedit.git
cedit/scripts/setup debug
build
cmake --install . --prefix "$HOME/.local/cedit"
exit
"$HOME/.local/cedit/bin/cedit" "$HOME/Src/Hello/src/main.cw"
```

cedit opens/edit/saves source, provides syntax highlighting, tabs, search,
and project navigation. Keep terminal build commands separate. It has no
compiler action/parser or debug workflow. Move the whole installed application
prefix, including `share/` language resources. The `cedit` executable stays
attached to the terminal that started it. Use it in a graphical session; an SSH/headless shell
alone is not a desktop. See the standalone
[cedit build guide](https://github.com/cwhip-lang/cedit/blob/main/doc/BUILD.md)
and [editor guide](https://github.com/cwhip-lang/cedit/blob/main/CEDIT.md).

Build the debugger independently:

```sh
cd "$HOME/Src"
git clone https://github.com/cwhip-lang/cdbg.git
cdbg/scripts/setup debug
build cdbg
cmake --install . --prefix "$HOME/.local/cdbg"
exit
export PATH="$HOME/.local/cedit/bin:$HOME/.local/cdbg/bin:$PATH"
cd "$HOME/Src/Hello"
cdbg src/main.cw
```

`cdbg SOURCE.cw` asynchronously runs `cwhip -g` into an owned temporary
executable; it does not overwrite your source/output and removes its temporary
output on exit. Alternatively, load the explicitly compiled debug binary:

```sh
cdbg ./bin/HelloDebug
# For an executable that accepts arguments:
cdbg ./bin/HelloDebug -- first-argument "one argument with spaces"
```

Arguments are passed individually, not executed as a shell command.
`CDBG_COMPILER` selects a specific compiler; otherwise cdbg tries a sibling
`cwhip`, then PATH. `CWHIP_SDK` is build-time SDK selection, not cdbg's runtime
compiler override. `CDBG_GDB` selects GDB instead of `gdb` on PATH.
Programs run in cdbg's current working directory; source package discovery
still follows the compiler's normal rules.

In cdbg, use **Run / Continue** (F5). With default **Break at start**, the first
stop is the generated `main`/`start` line. Click an executable source line
(gutter or text) and press F9 (**Breakpoint > Set/Clear Breakpoint**). Use
F10/F11/Shift+F11 for Step Over/Into/Out and inspect Locals / Arguments, Stack,
and Watches (including class fields from `-g` DWARF). **File > Open Source
Code** only opens a read-only source tab; it does not compile or change the
target. **Restart** of a `.cw` session recompiles with `cwhip -g` then
relaunches; prebuilt executables restart without rebuilding.

GDB must be available at runtime. Friendly Cwhip value inspection additionally
requires Python-enabled GDB with `gdb.MICommand` (validated upstream with GDB
16.3); without it, cdbg reports the limitation and raw native locals remain
usable. Debug metadata does not expose full Cwhip class-member layouts, and
stepping can enter runtime helpers. This prototype supports local launch, not
attach, remote debugging, DAP/LLDB, or an interactive stdin terminal. Programs
waiting for input cannot receive it through cdbg's output-only PTY. See the
[standalone debugger guide](https://github.com/cwhip-lang/cdbg/blob/main/CDBG.md)
and [build/test guidance](https://github.com/cwhip-lang/cdbg/blob/main/doc/BUILD.md)
for further limits.

Both apps use their own `./scripts/setup [--clean] [debug|release|profile]`
project shells, starting in `build/` and putting their root `bin/` on PATH.
Inside, `build`/`rebuild [TARGET...]` are Bash functions; `clean` remains a script.
Their normal build outputs are root `bin/` and sibling `share/`, with native
libraries conventionally in `lib/`; installation places app resources under
the requested prefix. Keep resources with the application.
Optional headless GUI tests require Xvfb and `dbus-daemon`; debugger session
tests also need GDB. Follow each repository's test instructions rather than
using compiler-integrated legacy application targets.

## Troubleshooting

Start with `command -v cwhip`, `command -v cwhip-pkg`, `cwhip-pkg doctor`, and
`cwhip --print-paths src/main.cw` from your source project. Keep the full
diagnostic and underlying CMake/Clang/Git/GDB output, not just the last line.

| Symptom | Check and remedy |
| --- | --- |
| `cwhip`/`cwhip-pkg` not found, or the wrong version runs | Put the intended SDK's `bin/` first on PATH. If your shell caches executable locations, refresh its command cache (for Bash, `hash -r`). A settings key does not update PATH. |
| CMake cannot find Cwhip, doctor fails SDK checks | Select the complete installed prefix, not `bin/`, the source checkout, or a `DESTDIR` image. Verify `lib/cmake/Cwhip` and runtime resources; install the SDK, not just copy an executable. |
| Selected SDK ignored or stale prefix used | Inspect non-empty `CWHIP_SDK`, the active XDG/HOME `cwhip/sdk.toml` (legacy `settings.toml` only if absent), and `Cwhip_DIR` in the build cache. An explicit selection wins over `CMAKE_PREFIX_PATH`. Reconfigure in a new build directory after SDK changes. |
| Invalid TOML, relative XDG/prefix, `PKG2003`, install registration failure | Use absolute paths. Correct the relevant top-level key in the selected SDK configuration; do not overwrite app preferences. An explicit valid `CWHIP_SDK` bypasses configuration parsing for consumers/doctor; install opt-out is a separate CMake option. |
| Python error or `tomllib` unavailable | Check `python3 --version` is at least 3.11, plus CMake's selected `Python3_EXECUTABLE`. Python must parse the package script before it can issue a coded version diagnostic. |
| CMake version too old | Use 3.24+ for template/apps/doctor, even if the compiler root configured with 3.16. |
| Missing Clang, IR compile/link failure (`CWHIP3001`) | Check Clang on PATH, the configured Clang path, and `CC`. `CC` must be a Clang executable, not `gcc` or a command containing flags. Run compilation with `-vv` and retain backend detail. |
| Runtime, headers, builtin, or modules missing (`CWHIP2001` or a source-located resource error) | Keep the whole matching SDK prefix; inspect stale `CWHIP_HOME`/individual overrides with `--print-paths`. Rebuild/reinstall compiler and resources together. |
| GUI configure fails or no `sourceview` package | Check GTK >=4.10 and GtkSourceView 5 with `pkg-config`, then build/install a GUI-enabled SDK with both options ON. Host GUI checks passing does not turn a compiler-only SDK into a GUI SDK. |
| App rejects SDK output-directory support | An older SDK can still say 0.0.1. Rebuild/install current SDK source; version alone does not advertise the required capability. |
| New-project failure (`PKG1003`/`1004`/`1005`/`3002`) | Check identifier/reserved names, destination parent/emptiness, archive safety/size, and network access. Use `--source` for a trusted local template; do not delete unrelated destination content to force success. |
| `init` refuses existing configuration | You are already initialized; inspect `list`, use `install` for restoration or `add` for new dependencies. Do not remove your manifest/lock just to rerun init. |
| Missing/stale lock, unresolved import, content mismatch | From the intended project, inspect `cwhip-pkg list` and `--print-paths`. Restore with `install --yes` or declare changes with `add`; check `[sources]` mappings and higher-priority package roots. Never bypass an integrity error by editing lock hashes. |
| External import works directly but not through template CMake | The helper uses its private bundled-package project. Use the documented direct compiler/package workflow or explicitly integrate your graph into application build rules. |
| cedit/cdbg cannot open a display | Run inside a working GTK graphical session. Xvfb/private session-bus setup is for the repositories' headless tests, not an installed desktop. |
| cdbg cannot compile/launch or inspect friendly values | Check runtime `cwhip`/`CDBG_COMPILER`, GDB/`CDBG_GDB`, `-g` on prebuilt targets, and Python-enabled GDB's `gdb.MICommand`. Read the Debugger Console and stderr. |

Compiler/package CLI headers use `tool: severity[CODE]: explanation`.
Diagnostics are on stderr; normal results are on stdout. Most operation
failures exit 1 and usage failures exit 2; the
[canonical diagnostic contract and code registry](DIAGNOSTICS.md) records
exceptions and application codes. Doctor's required failures produce nonzero
status (`PKG2002`) and per-check remedies; optional warnings alone do not.
Do not treat a printed package plan or an open GUI window as proof that an
operation succeeded.

## Where to go next

Use the [documentation index](README.md) to find the language, standard library,
GTK, callback, and package references. Start with
[runnable examples](EXAMPLES.md) and the [language reference](LANGUAGE-REFERENCE.md)
for more source-level practice; use [installation](INSTALLATION.md) and
[the CMake SDK contract](CMAKE-SDK.md) for advanced layouts, resource overrides,
and native application integration.

This guide's canonical source is
[`cwhip/doc/GETTING_STARTED.md`](https://github.com/cwhip-lang/cwhip/blob/master/doc/GETTING_STARTED.md);
the project website is [cwhip.org](https://cwhip.org). Standalone application
behavior and tests are owned by the linked app repositories, not this compiler
repository.
