# Contributing

This repository maintains a reproducible CMake-based build and install workflow
for the legacy Topdrawer tool (`td`). Contributions should focus on maintenance,
portability, packaging, verification, and documentation.

Do not add new Topdrawer features unless the repository is explicitly
repurposed.

## Repository Shape

- This repository builds `td` from an upstream source archive rather than storing
  the unpacked upstream source tree in Git.
- Upstream archives may be supplied locally or fetched on demand. Keep that
  workflow reproducible, hash-pinned, and documented.
- Generated content belongs under the build tree, especially paths such as
  `build/vendor` and `build/generated`.
- If local archive and cache directories such as `archives/` and
  `.cache/downloads/` are used, keep cleanup behavior and documentation aligned
  with those paths.
- If helper targets exist for broader cleanup, such as `clean_downloads`,
  preserve their meaning unless there is an intentional workflow change.

## External Dependencies

- Treat `ugs`, `f2c`, and X11 as external dependencies unless the repository is
  intentionally expanded to vendor or build them.
- Prefer stable `find_package(...)`-based integration over ad hoc path handling.
- When dependency discovery changes, update both the build logic and user-facing
  documentation.
- Do not silently replace external dependencies with bundled copies.

## Patch Policy

- Treat the upstream archive contents as the source of truth. Do not commit
  unpacked or patched upstream trees to the repository.
- Keep compatibility fixes in reproducible patch logic, typically
  `cmake/TdPatchSources.cmake` or another clearly named patch script.
- Do not edit `build/vendor` directly. If a generated or unpacked file needs a
  fix, move that fix into the patching step.
- Keep patches minimal, mechanical, and idempotent so they can be re-applied
  across clean reconfigures and future upstream archive refreshes.
- Prefer patches that address compiler, linker, packaging, or portability issues
  over behavioral rewrites.
- Document the reason for non-obvious patches in code comments, Issues, PRs,
  or commit messages, especially when they correspond to a specific toolchain
  breakage.

## Versioning

- Keep `project(VERSION ...)` in the root `CMakeLists.txt` aligned with the
  intended release tag.
- Use full semantic versions in CMake, for example `0.1.0`.
- Use Git tags in the form `vX.Y.Z`.
- Use patch releases for small maintenance fixes, documentation corrections,
  packaging fixes, and compatibility updates.
- Use minor releases for meaningful user-facing milestones such as workflow
  changes, new automation, install/export improvements, or larger maintenance
  batches.

## Development Workflow

- Do not commit or push directly to `main` for normal development work.
- Start work from a topic branch created from `main`.
- Name topic branches as `<type>/<short-kebab-summary>`.
- Use stable branch types that match the repository's maintenance categories,
  such as `build`, `docs`, `tests`, `ci`, `release`, or `meta`.
- When an issue number is useful context, include it after the type rather than
  replacing the type, for example `tests/issue-25-axis-postscript-fixture`.
- Merge changes into `main` through a pull request.
- Confirm the relevant CI checks pass before merging. Use a merge commit to
  preserve PR boundaries and individual commits; do not squash or rebase PRs
  into `main`.
- The repository protects `main` so normal changes must go through pull
  requests.
- GitHub is configured to delete merged head branches automatically.
- Keep pull requests focused on one coherent maintenance change.
- Use PR titles and labels that will remain useful in release notes.
- When `.github/` metadata exists, keep workflow names, labels, and release-note
  categories aligned with actual repository practice.
- If build or test automation depends on external dependencies, add a
  reproducible bootstrap path before making those checks required.

Use English for shared documentation, code comments, commits, Issues, and PRs.
After a remote merge, verify the resulting state, synchronize local `main`,
and remove the merged topic branch when no longer needed.

## Testing and Verification

Preserve the standard CMake workflow:

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

Run `cmake --install build --prefix <prefix>` when install behavior changes.

Use CMake and CTest 3.21 or newer throughout the workflow. CI retains the
default Ubuntu build and adds a minimum-version entry on Ubuntu 24.04 with
CMake/CTest 3.21.7. The minimum entry verifies the official tool archive's
SHA256, prints and checks both tool versions, runs configure/build/all CTest
cases, and installs into a temporary prefix.

External dependencies are built with the runner's CMake before selecting the
minimum version for `td`; their own source-build requirements are separate from
the requirements for consuming their installed packages. The minimum entry
checks installation execution, not installed runtime behavior or uninstall.
When changing CMake commands or options, preserve compatibility with 3.21 and
verify the affected paths with the minimum tool as well as the normal build.

### Docker Probe

Use the Docker probe for local CI-equivalent validation when changes affect CI
bootstrap, external dependency discovery, CMake build logic, test registration
or execution, packaging-sensitive behavior, or related documentation.

The default probe configures, builds, and runs CTest inside an Ubuntu container:

```sh
docker compose -f tests/docker-probe/compose.yml run --rm ci
```

See `tests/docker-probe/README.md` for prerequisites, config validation, image
build, debug shell usage, install-sensitive checks, and limitations.

Prefer lightweight verification that can run non-interactively. When adding
tests, prefer `CTest`-registered smoke coverage around the built `td` executable
and avoid relying on interactive X11 behavior.

If packaging behavior changes, verify both installation results and any
documented runtime assets such as help files.

Follow [tests/README.md](tests/README.md) for fixture selection, test guarantees,
and limitations. Record commands actually run, results, and any missing checks
in the PR; do not infer visual correctness from process or file-output checks.

## Documentation

Keep the current project contract in canonical, self-contained documentation:
user workflows in README, development procedures here, and test policy in
`tests/README.md`. AGENTS provides stable boundaries and pointers, not duplicate
procedures. Issues and PRs hold decisions, implementation plans, and progress;
readers should not need their history to understand current behavior.

Do not commit agent- or tool-generated specifications, implementation plans,
or temporary planning records, including superpowers documents. Keep local
notes untracked; `docs/superpowers/` is ignored in full. This policy takes
precedence over skill instructions to create or commit planning artifacts.
Record relevant decisions and verification in the Issue or PR after approval
for that external write, as required by AGENTS. A skill or maintenance policy
does not itself authorize external writes. Historical records remain in Git
history rather than being copied into new planning documents.

A separate Issue or plan is not needed for every small correction. Reuse an
existing Issue for substantial work when it covers the scope. PRs should
explain the problem, resulting behavior, related Issue, verification, and
remaining limitations without depending on ignored local notes.

- Keep README content focused on user-facing build, install, usage, and
  troubleshooting guidance.
- Update README files when user-facing workflows, dependency setup, archive
  handling, install layout, or supported usage patterns change.
- Keep path references accurate for the current implementation, especially
  archive locations, cache locations, generated directories, and installed
  runtime assets.

## Commit Messages

Use a short imperative subject in the form `<area>: <summary>`.

Prefer stable areas such as `build`, `docs`, `tests`, `ci`, `release`, or
`meta`. For changes spanning multiple areas, choose the area that best represents
the main outcome for users or maintainers.

Mention version bumps explicitly when they are part of the change.

Recommended template:

```text
<area>: <summary>

- Reason or outcome 1
- Reason or outcome 2
```

## Change Discipline

- Do not revert unrelated user changes.
- Prefer narrow consistency fixes over broad rewrites.
- If archive handling, cache paths, cleanup targets, or build layout change,
  update the implementation, documentation, and automation together.
