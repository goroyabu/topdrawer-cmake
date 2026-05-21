# Rendering and PostScript Test Design

## Summary

This repository uses a layered test strategy for Topdrawer execution,
PostScript file output, and future rendering checks.

The existing smoke tests remain the fast "does it run" layer. The committed
PostScript/I/O tests add deterministic file-output checks, basic PostScript
structure checks, and small command-sensitive output comparisons. Future raster
and golden-image tests should be added only after renderer dependency handling,
baseline policy, and known glyph-rendering risks are understood.

GitHub issue #25 remains the work-tracking hub for expanded PostScript and
rendering coverage. This spec is the versioned design record for the test
strategy, fixture policy, current implemented scope, and future expansion
boundaries.

## Background

This repository maintains a reproducible CMake-based build and install workflow
for the legacy Topdrawer tool. The test suite should therefore emphasize
representative behavior, portability, and diagnosable maintenance failures
rather than exhaustive Topdrawer language conformance.

The original smoke tests run small Topdrawer inputs and check that `td` exits
successfully without reporting Topdrawer or UGS errors. That is useful, but it
does not directly prove that rendered output files are produced or that command
changes affect the generated output.

The PostScript/I/O layer fills that gap without requiring an image renderer. It
uses non-interactive PostScript output because it is the most practical automated
rendering target currently available in this repository.

## Source of Truth Model

- GitHub issue #25 tracks open work, follow-up checklists, related issues, and
  status for expanded PostScript and rendering coverage.
- This spec records the accepted test strategy and fixture policy.
- Future implementation plans under `docs/superpowers/plans/` should describe
  concrete file changes and verification commands for individual test additions.
- Pull requests should link to the relevant issue, spec, and plan, then record
  the checks that were run.

This split keeps issue #25 useful as the public work ledger while preserving the
design rationale in Git history.

## Goals

- Preserve the existing smoke tests as a fast process-success layer.
- Verify deterministic PostScript file output for representative non-interactive
  Topdrawer inputs.
- Keep fixtures small, independently authored, and easy to diagnose.
- Reuse fixtures across multiple test levels when that improves coverage.
- Separate file-output, PostScript-structure, command-difference, raster, and
  golden-image concerns.
- Keep future raster and visual regression checks optional until dependency and
  stability tradeoffs are documented.
- Avoid copying web-sourced manual examples directly into committed test
  fixtures.

## Non-Goals

- Do not create an exhaustive Topdrawer command conformance suite.
- Do not replace the existing smoke tests.
- Do not make exact image comparison the default correctness criterion.
- Do not require Ghostscript or another image renderer for the current
  PostScript/I/O layer.
- Do not test interactive X11 behavior in this layer.
- Do not treat every harmless PostScript text change as a regression.
- Do not fold notebook integration, image conversion pipeline work, or
  devcontainer/bootstrap design into this spec.

## Current Implemented Scope

The tracked test suite currently contains:

| Group | Count | Notes |
|---|---:|---|
| Smoke tests | 6 | Process success and expected text checks for existing minimal inputs. |
| Level 1: I/O contract | 7 | Basic plot, join, histogram, explicit device output, external input, coordinate titles, and error-bar/data-order fixtures. |
| Level 2: PostScript structural | 6 | Structure checks for basic plot, join, histogram, external input, coordinate titles, and error-bar/data-order fixtures. |
| Level 3: Command-sensitive output | 3 | Plot vs join, histogram vs plot, and error-bar vs no-error-bar comparisons. |
| Level 4: Raster render probe | 0 | Deferred until renderer dependency handling is decided. |
| Level 5: Golden image | 0 | Deferred until baseline and tolerance policy is decided. |

The current total is 22 CTest cases: 6 smoke tests and 16 PostScript/I/O-oriented
tests.

## Test Levels

| Level | Name | Current status | Purpose |
|---|---|---|---|
| 1 | I/O contract | Implemented | Check process success and generated output files. |
| 2 | PostScript structural | Implemented | Check that generated `.ps` files have basic PostScript structure. |
| 3 | Command-sensitive output | Partially implemented | Check that comparable fixtures produce distinguishable output. |
| 4 | Raster render probe | Deferred | Render `.ps` to an image and check that it is valid and nonblank. |
| 5 | Golden image | Deferred | Compare selected rendered images against baselines with tolerances. |

Level 1 checks should require exit code 0, an expected output file, and nonempty
output.

Level 2 checks should use broad structural markers such as a PostScript header,
`%%BoundingBox`, and `showpage`. They should not freeze complete PostScript file
contents.

Level 3 checks should stay lightweight and diagnostic. They verify that distinct
commands or data paths affect generated output, not that the output is visually
perfect.

Levels 4 and 5 should remain separate from the baseline CTest path until the
renderer dependency, failure mode, and update policy are documented.

## Fixture Policy

Committed fixtures should be independently authored. They may be informed by
manual examples, issue reproductions, or historical smoke tests, but they should
not copy web-sourced sample files directly into the committed test suite.

Fixtures should:

- use independently authored numeric data, titles, and labels;
- focus on one primary behavior where practical;
- stay small enough for failures to be inspected quickly;
- be reusable across multiple test levels when useful;
- avoid known unstable or unrelated behavior unless that behavior is the test
  target.

Manual samples under `tests/manual-samples/` are reference material for
exploration and visual comparison. They are not wired into CTest or CI, and they
should not become committed fixtures without an explicit review of origin,
license, and test intent.

## Current Fixture Areas

The current PostScript fixture set covers:

- basic point plotting;
- joined line plotting;
- basic histogram output;
- explicit PostScript output file naming through script device commands;
- external input with `SET ORDER` and `DUMMY` columns;
- title placement with data and text coordinates;
- error-bar and reordered data behavior;
- command-sensitive output differences for selected comparable fixtures.

The existing smoke fixtures continue to cover broader process-success paths,
including multi-plot, mesh/random, contour/histogram, and font/text examples.

## Issue Inventory and Handling

### Issue #25: Expanded PostScript and Rendering Coverage

Issue #25 is the primary planning hub. It should stay open while follow-up
coverage remains active. Its role is to track status, related issues, and next
work items. Detailed design rationale should live in this spec.

The next implementation candidate from issue #25 is axis-related PostScript
coverage, starting with small fixtures such as:

- `axis_titles.top`;
- `axis_ticks_grid.top`.

Those should receive a separate implementation plan before file changes are
made.

### Issue #24: Font and Symbol Glyph Rendering Bug

Issue #24 is a bug report for glyphs rendering as horizontal bars in PostScript
output. It should remain a bug issue, not a test-planning document.

This spec treats font, symbol, `CASE`, and glyph-heavy visual checks as
constrained by that bug. Future fixtures may exercise those paths as smoke or
I/O checks, but visual correctness assertions should wait until the underlying
UGS or glyph-rendering behavior is understood.

### Issue #27: Linux PostScript Filename Override Investigation

Issue #27 records the completed investigation into Linux PostScript output
filename overrides. Its findings explain why deterministic file-output behavior
and UGS driver state handling matter for this test layer.

The issue can remain closed as historical context. Future plans should reference
it only when changing output-file naming, UGS dependency versions, or Linux
PostScript enablement assumptions.

### Issues #6, #7, #8, #10, and #11: Notebook and Rendering Pipeline Work

These issues cover notebook integration, batch rendering, image conversion,
unsupported interactive behavior, and devcontainer/bootstrap evaluation.

They are related to future Level 4 and Level 5 checks, especially renderer
dependency handling and notebook-friendly image output. They should not be
merged into this test spec. This spec only records that raster and golden-image
tests should wait for those decisions or for an intentionally narrow test-only
renderer policy.

### Issue #20: Curated Smoke Coverage

Issue #20 is historical context for the current smoke layer. It should stay
closed. This spec builds on that smoke layer rather than reopening its scope.

## Future Coverage Direction

Future coverage should expand incrementally by failure mode, not by copying all
manual examples into the repository.

Recommended near-term additions:

- axis titles and labels;
- ticks and grid behavior;
- window or panel layout;
- additional command-sensitive comparisons where they remain diagnostic.

Recommended deferred additions:

- symbol, font, and glyph visual assertions until issue #24 is understood;
- raster nonblank probes until renderer dependency handling is documented;
- golden-image checks until baseline generation, tolerance, and update policy
  are stable;
- test layout cleanup such as renaming `tests/cases/` to `tests/smoke/`.

## Full Coverage Planning Bands

Long-term coverage should remain representative rather than exhaustive.

Useful planning bands are:

| Coverage scope | Fixture count | Test count estimate | Intended use |
|---|---:|---:|---|
| Minimal practical coverage | 10-15 | 35-55 | Major drawing and I/O paths with low CI cost. |
| Standard coverage | 25-35 | 95-125 | Broad coverage across major feature categories. |
| High coverage | 45-60 | 180-250 | More option variations, glyph cases, coordinate modes, and 3D/mesh cases. |
| Regression-heavy coverage | 30-40 plus baselines | 120-170 | Standard coverage with raster probes and selected golden-image checks. |

For this repository, the preferred long-term target is standard coverage in
practice, with only a small number of golden-image tests. The repository's
purpose remains build, install, portability, and verification of legacy
Topdrawer, not full language-level conformance.

## Risks and Tradeoffs

- Full PostScript golden files would detect more regressions, but they may be
  brittle when harmless backend details change.
- Raster probes detect blank or unrasterizable output, but they require an image
  renderer and add CI setup cost.
- Golden images catch visual regressions, but they need sparse selection,
  tolerance policy, and a clear baseline update process.
- Large fixtures cover more behavior at once, but they make failures harder to
  diagnose.
- Very small fixtures are easier to debug, but too many can make the suite
  harder to maintain.

The preferred balance is to keep fixtures small, reuse them across test levels,
and reserve expensive or brittle checks for representative cases.

## Accepted Decisions

- Keep issue #25 as the planning hub and work ledger for expanded PostScript and
  rendering coverage.
- Preserve this spec as the source of truth for rendering test strategy and
  fixture policy.
- Keep current smoke tests as a separate fast layer.
- Keep the committed PostScript/I/O layer non-raster by default.
- Treat `tests/manual-samples/` as exploratory reference material, not committed
  fixture source material.
- Defer raster and golden-image checks until renderer dependency, baseline, and
  tolerance decisions are documented.
- Treat font, symbol, `CASE`, and glyph-heavy visual checks as constrained by
  issue #24 until the rendering bug is understood.
