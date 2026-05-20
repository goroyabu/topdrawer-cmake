# td: Modern CMake wrapper for Topdrawer

This repository provides a CMake-based build for the legacy Topdrawer plotting tool.  
It downloads or reuses a Topdrawer source archive, applies small compatibility fixes for
modern C/Fortran toolchains, and builds a `td` executable and help data using an
out-of-source layout.

The aim is to make Topdrawer easy to build and install on current systems without
modifying the upstream sources in place.

---

## Requirements

- CMake **3.15** or newer.
- A C compiler (Clang, GCC, …).
- A Fortran compiler (e.g. `gfortran`).
- An installed **f2c** package that provides a CMake config file and the runtime
  library target:
  - `f2cConfig.cmake` on CMake's module path.
  - An imported target `f2c::f2c_runtime` (static `libf2c.a`).
- An installed **UGS** library with a CMake config file:
  - `ugsConfig.cmake` on CMake's module path.
  - An imported target `ugs::ugs`.
- X11 development libraries:
  - `Xt`, `Xmu`, `Xaw`, `X11`, `Xext`, `SM`, `ICE` (names may vary by platform).

If CMake cannot find `f2c` or `ugs`, you may need to add their installation prefixes
to `CMAKE_PREFIX_PATH`, for example:

```sh
cmake -S . -B build -DCMAKE_PREFIX_PATH="$HOME/.local"
```

---

## Repository layout

Top-level files and directories:

- `CMakeLists.txt`  
  Main build configuration: archive handling, patching, targets, install rules.
- `cmake/`  
  Helper modules used by the build:
  - `FetchAndUnpack.cmake` – utilities to locate or download the Topdrawer source
    archive and manage download caches.
  - `TdPatchSources.cmake` – applies small source adjustments after unpacking
    the upstream tarball.
  - `Uninstall.cmake.in` – template used to generate an `uninstall` target.
- `archives/` (optional, user-created)  
  If present, this is where you can place a Topdrawer source archive manually.
- `build/` (generated)  
  Default out-of-source build tree created by CMake:
  - `build/vendor/topdrawer/` – unpacked upstream sources.
  - `build/generated/` – reserved for generated files.
  - `build/td` – built executable.

The upstream Topdrawer sources are always unpacked under `build/vendor/topdrawer`
and are regenerated on each configure when needed. Do not edit files under
`build/vendor` directly; use `cmake/TdPatchSources.cmake` instead.

---

## How source acquisition works

This project builds Topdrawer from an upstream tarball:

- Archive name: `topdrawer_20071207.tar.gz`
- Upstream URL:  
  `http://ftp.riken.go.jp/iris/OLD/topdrawer/topdrawer_20071207.tar.gz`

At CMake **configure** time, the following logic is used:

1. `FetchAndUnpack.cmake` initialises two directories (creating them if needed):
   - `ARCHIVE_DIR` (default: `<source>/archives`) – for user-provided archives.
   - `DOWNLOAD_CACHE_DIR` (default: `<source>/.cache/downloads`) – for downloaded
     copies of the archive.
2. CMake looks for the Topdrawer archive at:
   - First: `<source>/archives/topdrawer_20071207.tar.gz`
   - If not found and downloads are allowed: it is fetched from the upstream URL
     into `<source>/.cache/downloads/…`, with a pinned SHA256 check during download.
3. If neither a local archive nor a download is available, configuration fails with
   a message indicating the path where you should place the tarball.

In short:

- To work **offline**, download `topdrawer_20071207.tar.gz` in advance and place it in:

  ```text
  <repository-root>/archives/topdrawer_20071207.tar.gz
  ```

- Otherwise, the configure step will automatically download the archive to the
  cache directory when needed.

The archive is unpacked into `build/vendor/topdrawer` at configure time using
`cmake -E tar`, and all subsequent build steps operate on that unpacked tree.

---

## Building and installing

The project uses the standard three-step CMake workflow. From the repository root:

```sh
# 1. Configure
cmake -S . -B build

# 2. Build
cmake --build build --parallel

# 3. Install (example: user-local prefix)
cmake --install build --prefix "$HOME/.local"
```

After installation:

- The `td` executable is installed to:

  ```text
  <prefix>/bin/td
  ```

- The Topdrawer help file is installed to:

  ```text
  <prefix>/share/td/topdrawer.gih
  ```

Make sure `<prefix>/bin` is on your `PATH`. For example:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

To enable Topdrawer’s online help, set the `TD_HELP` environment variable to
the installed `.gih` file, for example:

```sh
export TD_HELP="$HOME/.local/share/td/topdrawer.gih"
```

Then you can invoke Topdrawer as:

```sh
td
```

from a shell, or with a `.top` / `.tdr` script as input.

---

## Testing

This repository includes a small `CTest`-based smoke test suite for the built
`td` executable.

To configure with tests enabled:

```sh
cmake -S . -B build \
  -DBUILD_TESTING=ON
```

To run the smoke tests:

```sh
ctest --test-dir build --output-on-failure
```

The smoke test suite runs `td` non-interactively across a small set of
repository-managed minimal inputs and checks that each case completes without
reporting a Topdrawer or UGS error. The suite currently covers basic 2D
plotting, error-bar and spline input, multi-plot input, mesh/scatter paths,
3D plotting paths, and font-oriented rendering paths.

The test suite also includes lightweight PostScript rendering and file I/O checks. These
tests generate PostScript with the `postscr` device, check that expected output
files are created and nonempty, inspect basic PostScript structure, and verify
that selected drawing commands produce distinguishable output:

```sh
ctest --test-dir build -L postscript --output-on-failure
```

---

## CI

GitHub Actions runs a Linux CI workflow for pull requests and pushes to `main`.
The workflow:

- Installs system build dependencies and X11 development packages.
- Clones and installs `f2c` and `ugs` into a temporary prefix.
- Configures this repository with `-DNET_FETCH=ON` and `-DBUILD_TESTING=ON`.
- Builds `td` with Ninja.
- Runs the `CTest` smoke test suite.

The CI workflow is defined in:

- `.github/workflows/ci.yml`

This is primarily a maintainer-facing verification path, but it also serves as a
reference for a clean bootstrap on Ubuntu.

---

## Source patching policy

The upstream Topdrawer sources contain a number of constructs that are problematic
for modern C and Fortran compilers (e.g. K&R-style function definitions without
prototypes, implicit `int`, and some Fortran intrinsics usage).

This repository does **not** modify the upstream archive in place. Instead:

- `cmake/TdPatchSources.cmake` is executed after the archive is unpacked into
  `build/vendor/topdrawer`.
- It performs mechanical edits such as:
  - Inserting missing `#include` directives where required.
  - Adjusting C functions to have explicit return types and prototypes.
  - Small Fortran fixes (for example, ensuring arguments to `ICHAR` have length 1).

If you need to adjust how Topdrawer builds on a new platform or with a new compiler,
add or refine transformations in `cmake/TdPatchSources.cmake`. Do not edit files
under `build/vendor/topdrawer` directly; those are regenerated on the next configure.

---

## Cleaning and uninstalling

Standard CMake clean:

```sh
cmake --build build --target clean
```

This removes object files and binaries from the build tree, but retains:

- Archives under `archives/` (your local copies).
- Downloaded tarballs under `.cache/downloads/`.

To remove downloaded archives and vendor/generated build artefacts, use the
extra cleanup target provided by `FetchAndUnpack.cmake`:

```sh
cmake --build build --target clean_downloads
```

This is a broader cleanup and may require a full reconfigure and rebuild.

If `cmake/Uninstall.cmake.in` is present (it is in this repository), an
`uninstall` target is also available:

```sh
cmake --build build --target uninstall
```

This attempts to remove files previously installed by `cmake --install`.

---

## Troubleshooting

### Archive not found

If configuration fails with a message like:

```text
Required file not found and NET_FETCH=OFF. Please place it at:
  /path/to/repo/archives/topdrawer_20071207.tar.gz
```

then download `topdrawer_20071207.tar.gz` manually and place it at the indicated
path under `archives/`, then re-run `cmake -S . -B build`.

### `ugs` or `f2c` not found

If `find_package(ugs)` or `find_package(f2c)` fails:

- Verify that those packages are installed and provide CMake config files:
  - `.../lib/cmake/ugs/ugsConfig.cmake`
  - `.../lib/cmake/f2c/f2cConfig.cmake`
- Add their root prefix to `CMAKE_PREFIX_PATH` when configuring:

  ```sh
  cmake -S . -B build -DCMAKE_PREFIX_PATH="/opt/ugs;$HOME/.local"
  ```

If you want a clean local bootstrap similar to CI, build and install `f2c` and
`ugs` first into the same prefix, then point this repository at that prefix via
`CMAKE_PREFIX_PATH`.

### X11 headers or libraries missing

If CMake cannot find X11 components (`Xt`, `Xmu`, `Xaw`, …), install the X11
development packages for your platform (for example, via your system package
manager or Homebrew on macOS) and reconfigure.

---

## Contributing

When changing how Topdrawer is built or patched, please:

- Keep all upstream adjustments in `cmake/TdPatchSources.cmake`.
- Avoid writing any generated or patched files back into the source tree.
- Keep the CMake interface and target names (`td`, `misc`, `ugs::ugs`,
  `f2c::f2c_runtime`) stable where possible, to make the project easy to
use from tooling and downstream scripts.

---

## License

This repository is distributed under the MIT License. See `LICENSE` for details.
