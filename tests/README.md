# Tests

The suite checks representative maintenance behavior of the built `td`
executable using non-interactive PostScript output. It is not an exhaustive
Topdrawer language or graphics conformance suite. CMake/CTest 3.21 or newer
and the normal build dependencies are required; no running X server or image
renderer is required for these tests.

## Running and Selecting Tests

From the repository root:

```sh
cmake -S . -B build -DBUILD_TESTING=ON
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

Select tests by label:

```sh
ctest --test-dir build -L archive-integrity --output-on-failure
ctest --test-dir build -L smoke --output-on-failure
ctest --test-dir build -L postscript --output-on-failure
ctest --test-dir build -L ps_structure --output-on-failure
ctest --test-dir build -L command_output --output-on-failure
```

See [CONTRIBUTING.md](../CONTRIBUTING.md) for change-specific verification and
[the Docker probe](docker-probe/README.md) for local Ubuntu validation.

## Directory Layout

Organize maintenance and build tests by purpose directly under `tests/`, as in
f2c and UGS. Keep test registration in `tests/CMakeLists.txt` for now.

- `archive_hash/`: archive selection and integrity tests, including their
  dedicated CMake runners. Inputs are generated in the build tree.
- `cases/`: executable smoke inputs and expected text.
- `postscript/fixtures/`: PostScript behavior inputs and companion data.
- `cmake/`: shared runners for executable and PostScript cases.
- `docker-probe/`: the Ubuntu verification environment.

Add purpose-specific directories such as `source_preparation/` or `install/`
when those tests are introduced; do not create empty placeholders. Group growing
functional fixtures within `cases/` or `postscript/` by behavior rather than
Issue number or implementation language. Keep dedicated scripts with their
suite, and extract shared runners only when multiple suites need them. Existing
cases do not need to move when a new suite is added.

## Current Guarantees and Limits

The suite has 47 tests: 28 executable tests and 19 archive acquisition tests.
PostScript tests also check execution status and known
Topdrawer/UGS error messages; a successful process alone is insufficient.

| Group | Count | Checks | Does not establish |
|---|---:|---|---|
| Archive integrity | 19 | Selection, hash enforcement, override warnings, and failure handling | Archive-format validity or upstream availability |
| Smoke | 6 | Process success, expected text, and absence of known error messages | Correct rendered output |
| PostScript I/O | 9 | Expected file exists and is nonempty | Valid or correct drawing |
| PostScript structure | 8 | Nonempty output plus PS header, BoundingBox, and showpage markers | Correct coordinates, labels, or glyphs |
| Command-output comparison | 5 | Two outputs exist, are nonempty, and differ by SHA256 | That either drawing is visually correct |

Fixtures cover basic plot/join/histogram, explicit output naming, external
input and column order, coordinate titles, error bars, mixed windows/panels,
axis titles/outlines, and DUPLEX glyph differentiation. The comparison runner
compares raw output bytes, not normalized PostScript or rendered images.

Raster nonblank probes and golden-image comparisons are not implemented.
Do not introduce them as baseline requirements until renderer dependencies,
baseline generation, tolerances, and update policy have been decided. Exact
visual placement and interactive X11 behavior are not verified by this suite.

## Archive Integrity

The `archive-integrity` cases in `archive_hash/` exercise the production resolver
in separate CMake processes with small synthetic files and local `file://` URLs.
They require no external network. They check local, cache, and download hashes;
strict failures and explicit mismatch overrides; diagnostics and the always-on
mode warning; local-hint precedence and archive-directory fallback; no fallback
after a mismatch; offline cache exclusion; and failed-download cleanup.
Mismatched files must remain unchanged, and failed resolution must not return a
path for extraction. These tests verify acquisition, not archive-format validity
or upstream server availability. Normal configure/build checks exercise actual
source extraction separately.

## Fixture and Assertion Policy

- Author committed fixtures independently, including data, titles, and labels.
  Manual examples and issue reproductions may inform a case, but do not copy
  web-sourced sample files directly into the suite.
- Local `refs/manual-samples/` material is exploratory reference only. It is
  ignored and is not an input to CTest or CI. Review origin, applicable terms,
  and test intent before incorporating external material.
- Prefer one primary behavior or failure mode per fixture. Keep cases small
  enough to diagnose failures and avoid unrelated unstable behavior.
- Reuse fixtures across layers when useful. Add variants only for distinct
  parser, data, device, layout, or rendering paths rather than coverage counts.
- Use broad structural checks instead of freezing complete PS files. Add
  command comparisons only when they isolate a useful output difference;
  byte inequality is a limited regression signal, not a visual oracle.
- Keep generated outputs in isolated build-tree test directories. Do not write
  generated output into the source fixture directories.

## Adding a Case

Smoke inputs and expected text patterns live in `cases/`. PostScript inputs
and companion data live in `postscript/fixtures/`. Register cases in
`CMakeLists.txt` using the existing smoke, PostScript, or comparison helpers;
the shared runners live in `cmake/`. Register maintenance tests in the same
`CMakeLists.txt`, with dedicated runners in their purpose-specific directory.

Run the focused case first and then the full suite. Follow CONTRIBUTING for
broader checks when test registration or execution changes. Report the tested
environment and limits, and update this document when the coverage contract
changes.

Future rendering coverage is tracked in
[issue #25](https://github.com/goroyabu/topdrawer-cmake/issues/25), with axis
decoration in [#45](https://github.com/goroyabu/topdrawer-cmake/issues/45).
These track future work; the guarantees above describe the implemented suite.
