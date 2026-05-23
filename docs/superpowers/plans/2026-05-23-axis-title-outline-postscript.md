# Axis Title Outline PostScript Fixture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the first sample-derived axis coverage slice for explicit axis drawing and side-specific axis titles on the non-interactive PostScript path.

**Architecture:** Add one independently authored PostScript fixture under `tests/postscript/fixtures/` and register it with the existing CTest helpers. Keep this first slice to Level 1 I/O and Level 2 PostScript structure checks; defer axis decoration, raster checks, and visual assertions.

**Tech Stack:** CMake, CTest, Topdrawer `.top` fixtures, existing `run_td_postscript_case.cmake` helper.

---

## Context

The rendering test design derives coverage from local manual sample references
under ignored `refs/manual-samples/`. The first axis group is:

- `PLOT AXIS`
- `TITLE BOTTOM`
- `TITLE LEFT`
- `TITLE RIGHT`
- simple `SET WINDOW` and `SET LIMITS` setup

Primary references:

- `refs/manual-samples/topdrawer-sample/08-sample.top`
- `refs/manual-samples/topdrawer-sample/13-sample.top`
- `refs/manual-samples/topdrawer-sample/17-sample.top`
- `refs/manual-samples/topdrawer-sample/18-sample.top`

Do not copy those samples. Author a small fixture with original data and plain
ASCII title strings.

## File Structure

- Create `tests/postscript/fixtures/axis_titles_outline.top`
  - Small independently authored input covering explicit axis drawing and
    side-specific axis titles.
- Modify `tests/CMakeLists.txt`
  - Add Level 1 and Level 2 CTest registrations using `add_td_postscript_case`.
- Modify `docs/superpowers/specs/2026-05-22-rendering-test-design.md`
  - Update implemented counts after the tests are added.
- Update GitHub issue #25 after implementation
  - Mark the axis title/outline slice or note it as completed.
  - Leave axis decoration as the next axis follow-up.

## Test Naming

Use these CTest names:

- `io_axis_titles_outline`
- `ps_structure_axis_titles_outline`

Do not add a Level 3 comparison in this plan. This slice verifies command
acceptance, output creation, and basic PostScript structure. Command-sensitive
comparison can be added later if a concrete diagnostic value is identified.

### Task 1: Add the Axis Title/Outline Fixture

**Files:**
- Create: `tests/postscript/fixtures/axis_titles_outline.top`

- [x] **Step 1: Create the fixture**

Create `tests/postscript/fixtures/axis_titles_outline.top` with exactly this
content:

```topdrawer
SET WINDOW X 2 12 Y 2 9
SET LIMITS X 0 4 Y 0 4
PLOT AXIS
TITLE TOP 'axis title outline'
TITLE BOTTOM 'x axis title'
TITLE LEFT 'y left axis title'
TITLE RIGHT 'y right axis title'
PLOT TITLE
SET ORDER X Y
0.5 1.0
1.5 2.2
2.5 1.6
3.5 3.0
JOIN
```

- [x] **Step 2: Run a focused manual render check**

Run:

```sh
repo_root=$(pwd)
cmake -E make_directory /tmp/td-axis-title-outline
cmake -E chdir /tmp/td-axis-title-outline cmake -E env TOPDRAWER_OUTPUT=axis.ps "$repo_root/build/td" -d postscr "$repo_root/tests/postscript/fixtures/axis_titles_outline.top"
test -s /tmp/td-axis-title-outline/axis.ps
```

Expected:

- command exits with status 0;
- no `*** ERROR ***` text appears;
- `/tmp/td-axis-title-outline/axis.ps` exists and is nonempty.

- [x] **Step 3: Remove manual render output if created in the repository**

Run:

```sh
find . -maxdepth 2 -name axis.ps -print
```

Expected:

- if output appears inside the repository, remove only that generated `axis.ps`
  file;
- do not remove fixture files or build outputs.

### Task 2: Register Level 1 and Level 2 CTest Cases

**Files:**
- Modify: `tests/CMakeLists.txt`

- [x] **Step 1: Add Level 1 CTest registration**

In `tests/CMakeLists.txt`, add this block after the existing
`io_window_mixed_panels` registration:

```cmake
add_td_postscript_case(
  io_axis_titles_outline
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/axis_titles_outline.top"
)
```

- [x] **Step 2: Add Level 2 CTest registration**

In `tests/CMakeLists.txt`, add this block after the existing
`ps_structure_window_mixed_panels` registration:

```cmake
add_td_postscript_case(
  ps_structure_axis_titles_outline
  INPUT_FILE "${TD_POSTSCRIPT_FIXTURES_DIR}/axis_titles_outline.top"
  CHECK_STRUCTURE
)
```

- [x] **Step 3: Reconfigure**

Run:

```sh
cmake -S . -B build
```

Expected:

- command exits with status 0;
- CMake generation completes without new errors.

- [x] **Step 4: Run focused CTest checks**

Run:

```sh
ctest --test-dir build -R 'axis_titles_outline' --output-on-failure
```

Expected:

- `io_axis_titles_outline` passes;
- `ps_structure_axis_titles_outline` passes;
- 2 tests pass, 0 fail.

### Task 3: Update the Rendering Test Design Record

**Files:**
- Modify: `docs/superpowers/specs/2026-05-22-rendering-test-design.md`

- [x] **Step 1: Update current implemented counts**

Update the `Current Implemented Scope` table:

```markdown
| Level 1: I/O contract | 9 | Basic plot, join, histogram, explicit device output, external input, coordinate titles, error-bar/data-order, window/panel, and axis title/outline fixtures. |
| Level 2: PostScript structural | 8 | Structure checks for basic plot, join, histogram, external input, coordinate titles, error-bar/data-order, window/panel, and axis title/outline fixtures. |
```

Update the total sentence:

```markdown
The current total is 27 CTest cases: 6 smoke tests and 21 PostScript/I/O-oriented
tests.
```

- [x] **Step 2: Update current fixture areas**

In `Current Fixture Areas`, add:

```markdown
- axis title and explicit axis outline command acceptance;
```

- [x] **Step 3: Update axis requirements status**

In `Axis Sample Coverage Requirements`, add a short sentence after the group
table:

```markdown
The axis title / outline group is covered by `axis_titles_outline.top`.
The axis decoration group remains the next axis-related follow-up.
```

### Task 4: Verify the Full Local Test Suite

**Files:**
- No source file changes.

- [x] **Step 1: Build**

Run:

```sh
cmake --build build
```

Expected:

- command exits with status 0;
- existing legacy compiler warnings may appear.

- [x] **Step 2: Run all CTest cases**

Run:

```sh
ctest --test-dir build --output-on-failure
```

Expected:

- 27 tests pass;
- 0 tests fail.

- [x] **Step 3: Run documentation hygiene checks**

Run:

```sh
LC_ALL=C grep -R -n '[^ -~]' docs/superpowers tests/postscript tests/CMakeLists.txt
```

Expected:

- no output;
- exit status 1.

Run:

```sh
rg -n "TB[D]|TO[D]O|FIX[M]E|placeholde[r]" docs/superpowers tests/postscript tests/CMakeLists.txt
```

Expected:

- no output;
- exit status 1.

### Task 5: Update Issue #25

**Files:**
- No repository file changes.

- [x] **Step 1: Add an issue progress comment**

Run:

```sh
gh issue comment 25 --body 'Axis title / outline coverage has been added with `axis_titles_outline.top`.

The test suite now has 6 smoke tests and 21 PostScript/I/O-oriented tests, for 27 total CTest cases.

The axis decoration group remains open and should cover `SET LABELS`, `SET TICKS`, `SET SCALE ... TICKS/LABELS`, `SET GRID`, `SET GRID SYMBOL`, `SET GRID OFF`, and `PLOT AXIS` in a later slice.'
```

Expected:

- the comment is added to issue #25;
- the comment links the completed axis title/outline slice to the remaining
  axis decoration follow-up.

### Task 6: Commit

**Files:**
- Add: `docs/superpowers/plans/2026-05-23-axis-title-outline-postscript.md`
- Add: `tests/postscript/fixtures/axis_titles_outline.top`
- Modify: `tests/CMakeLists.txt`
- Modify: `docs/superpowers/specs/2026-05-22-rendering-test-design.md`

- [x] **Step 1: Check status**

Run:

```sh
git status --short
```

Expected:

```text
 M docs/superpowers/specs/2026-05-22-rendering-test-design.md
 M tests/CMakeLists.txt
?? docs/superpowers/plans/2026-05-23-axis-title-outline-postscript.md
?? tests/postscript/fixtures/axis_titles_outline.top
```

- [x] **Step 2: Stage files**

Run:

```sh
git add docs/superpowers/specs/2026-05-22-rendering-test-design.md docs/superpowers/plans/2026-05-23-axis-title-outline-postscript.md tests/CMakeLists.txt tests/postscript/fixtures/axis_titles_outline.top
```

- [x] **Step 3: Commit**

Run:

```sh
git commit -m "tests: add axis title PostScript fixture"
```

Expected:

- commit succeeds;
- the working tree is clean except ignored local reference material.

## Plan Self-Review

- Spec coverage: This plan implements the first `Axis Sample Coverage
  Requirements` group only. Axis decoration remains a documented follow-up.
- Incomplete-marker scan: No incomplete tasks are present.
- Scope check: The plan avoids raster, golden-image, glyph-heavy, polar, and
  log-scale behavior.
- Verification: Focused CTest, full CTest, build, and documentation hygiene
  checks are included.
