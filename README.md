# td: Modern CMake wrapper for Topdrawer

This repository provides a CMake-based build for the legacy Topdrawer plotting tool.  
It downloads or reuses a Topdrawer source archive, applies small compatibility fixes for
modern C/Fortran toolchains, and builds a `td` executable and help data using an
out-of-source layout.

The aim is to make Topdrawer easy to build and install on current systems without
modifying the upstream sources in place.

---

## Requirements

- CMake and CTest **3.21** or newer for configuring, building, testing, and
  installing this project.
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

- `archives/` (optional): place a local copy of the Topdrawer source archive here
  for offline or pre-fetched builds.
- `build/` (generated): default out-of-source build tree created by CMake.
- `cmake/`: helper modules used by the build and install workflow.

---

## How source acquisition works

This project builds Topdrawer from an upstream tarball:

- Archive name: `topdrawer_20071207.tar.gz`
- Upstream URL:  
  `http://ftp.riken.go.jp/iris/OLD/topdrawer/topdrawer_20071207.tar.gz`

The resolver first selects an existing explicit local hint (the archive path below
in the normal build), then `ARCHIVE_DIR/<archive name>`. With `NET_FETCH=ON`
(the default), it next reuses `DOWNLOAD_CACHE_DIR/<archive name>` or downloads
there if absent. The defaults are `archives/` and `.cache/downloads/` under the
repository root; both directories can be overridden with CMake options.

For an offline build, place the archive in `archives/` (or your `ARCHIVE_DIR`)
and configure with `-DNET_FETCH=OFF`. **OFF does not read the download cache**:
a missing local archive is an error even when a cached download exists.

Every selected archive is checked against the SHA256 pinned in `CMakeLists.txt`
before extraction, including local files and existing cached downloads. A
mismatch stops configuration and reports the file, expected hash, and actual
hash. Selection never silently falls back to a different copy after a mismatch.
Replace the selected file with the expected archive before retrying.

To deliberately use a modified archive, opt in explicitly:

```sh
cmake -S . -B build -DTD_ALLOW_UNVERIFIED_ARCHIVES=ON
```

This option defaults to OFF. When ON, CMake still computes the hash but warns
and continues with the selected mismatched file. It also warns at each
configuration even if the hash matches. This mode is outside standard support
and is not suitable for CI or release builds. The setting persists in the build
cache; pass `-DTD_ALLOW_UNVERIFIED_ARCHIVES=OFF` to restore strict verification.

The option does not bypass missing files, download errors, or extraction errors.
Failed downloads stop configuration with their URL, destination, and reason;
the newly failed download is removed so a retry does not reuse it. Existing
local/cache files and completed downloads with mismatched hashes are retained
for inspection.

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

This repository includes a `CTest`-based test suite for the built `td`
executable.

To configure with tests enabled:

```sh
cmake -S . -B build \
  -DBUILD_TESTING=ON
```

To run the full test suite:

```sh
ctest --test-dir build --output-on-failure
```

For PostScript-oriented checks only:

```sh
ctest --test-dir build -L postscript --output-on-failure
```

Maintainer-focused verification guidance, including when to use broader checks
such as the Docker probe, lives in `CONTRIBUTING.md`.
See [tests/README.md](tests/README.md) for test selection, coverage limitations,
and fixture policy.

---

## Cleaning and uninstalling

Standard CMake clean:

```sh
cmake --build build --target clean
```

If `cmake/Uninstall.cmake.in` is present (it is in this repository), an
`uninstall` target is also available:

```sh
cmake --build build --target uninstall
```

This attempts to remove files previously installed by `cmake --install`.

Repository-specific cleanup details beyond the standard CMake targets are
documented in `CONTRIBUTING.md`.

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

If needed, build and install `f2c` and `ugs` into the same prefix, then point
this repository at that prefix via `CMAKE_PREFIX_PATH`.

### X11 headers or libraries missing

If CMake cannot find X11 components (`Xt`, `Xmu`, `Xaw`, …), install the X11
development packages for your platform (for example, via your system package
manager or Homebrew on macOS) and reconfigure.

---

## Contributing

See `CONTRIBUTING.md` for repository maintenance policy, verification guidance,
and change discipline.

---

## License

This repository is distributed under the MIT License. See `LICENSE` for details.
