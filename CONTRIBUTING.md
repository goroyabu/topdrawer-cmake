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
- Document the reason for non-obvious patches in code comments, design records,
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

- Do not commit directly to `main` for normal development work.
- Start work from a topic branch created from `main`.
- Merge changes into `main` through a pull request.
- Prefer deleting merged topic branches once they are no longer needed.
- Keep pull requests focused on one coherent maintenance change.
- Use PR titles and labels that will remain useful in release notes.
- When `.github/` metadata exists, keep workflow names, labels, and release-note
  categories aligned with actual repository practice.
- If build or test automation depends on external dependencies, add a
  reproducible bootstrap path before making those checks required.

## Superpowers Process

Use `docs/superpowers/process.md` when a change needs traceability across design,
implementation planning, verification, and review.

The full superpowers workflow is not required for every change. Use it for work
with lasting design or execution value, such as changes to build logic,
dependency discovery, archive handling, source patching, CI, packaging, test
strategy, fixture policy, or user-facing workflows.

## Testing and Verification

Preserve the standard CMake workflow:

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

Run `cmake --install build --prefix <prefix>` when install behavior changes.

Prefer lightweight verification that can run non-interactively. When adding
tests, prefer `CTest`-registered smoke coverage around the built `td` executable
and avoid relying on interactive X11 behavior.

If packaging behavior changes, verify both installation results and any
documented runtime assets such as help files.

## Documentation

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
