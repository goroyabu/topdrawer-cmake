# Superpowers Process Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt a lightweight shared contributor policy and superpowers documentation process for this repository.

**Architecture:** Keep root `AGENTS.md` as the tracked session-start entry point, keep `CONTRIBUTING.md` as the shared policy document for humans and agents, keep `docs/superpowers/process.md` as the superpowers workflow entry point, and keep the design rationale in `docs/superpowers/specs/2026-05-21-superpowers-process-design.md`. Defer pull request template changes until the workflow has been evaluated.

**Tech Stack:** Markdown documentation, Git, repository-local agent guidance.

---

## Accepted Requirements

- The repository should treat important superpowers specs and plans as tracked
  repository artifacts.
- The repository should keep shared maintenance policy in `CONTRIBUTING.md`.
- Tracked docs should be limited to work with lasting design or execution value.
- GitHub issues should remain the work-tracking ledger, not the detailed design
  source of truth.
- `docs/superpowers/process.md` should be the process entry point.
- Root `AGENTS.md` should be tracked as the session-start entry point.
- `.github/pull_request_template.md` should not be changed yet.
- Temporary notes and experiments should not become tracked docs by default.

## File Structure

- Modify: `docs/superpowers/specs/2026-05-21-superpowers-process-design.md`
  - Resolve the open questions with the decisions made during review.
- Modify: `docs/superpowers/process.md`
  - Keep the process entry point aligned with `CONTRIBUTING.md` and the tracked
    document policy.
- Create: `CONTRIBUTING.md`
  - Move shared repository maintenance policy out of local-only agent guidance.
- Modify: `AGENTS.md`
  - Keep it short and delegate durable policy to tracked docs.
- Modify: `.gitignore`
  - Stop ignoring root `AGENTS.md`.
- Do not modify: `.github/pull_request_template.md`
  - PR template changes are intentionally deferred.

## Task 1: Resolve Process Design Decisions

**Files:**
- Modify: `docs/superpowers/specs/2026-05-21-superpowers-process-design.md`

- [x] **Step 1: Replace the open questions with accepted decisions**

Change the final section from:

```markdown
## Open Questions

- Whether `AGENTS.md` should link to `docs/superpowers/process.md` immediately or
  only after one real maintenance task uses the process.
- Whether the pull request template should include explicit spec and plan links,
  or whether those links should remain optional until the workflow stabilizes.
```

to:

```markdown
## Accepted Decisions

- Add a short `AGENTS.md` pointer to `docs/superpowers/process.md` immediately so
  agents can discover the repository process from the normal guidance entry
  point.
- Add `CONTRIBUTING.md` as the shared policy document for humans and agents, and
  keep `docs/superpowers/process.md` focused on the superpowers-specific workflow.
- Do not update `.github/pull_request_template.md` yet. Revisit the template
  after the process has been used on at least one real maintenance change.
- Track root `AGENTS.md` and keep it short. It should delegate durable policy to
  `CONTRIBUTING.md` and superpowers workflow details to
  `docs/superpowers/process.md`.
```

- [x] **Step 2: Verify the design record has no unresolved questions**

Run:

```sh
rg -n "Open Questions|TB[D]|TO[D]O|FIX[M]E" docs/superpowers/specs/2026-05-21-superpowers-process-design.md
```

Expected: no output and exit status `1`.

## Task 2: Align the Process Entry Point

**Files:**
- Modify: `docs/superpowers/process.md`

- [x] **Step 1: Make the tracked document policy explicit in the process guide**

In section `### 6. Use the lightest process that preserves traceability`, replace:

```markdown
Not every change needs a full spec and plan.

Use the full design-to-plan workflow for changes with architectural, workflow,
dependency, packaging, CI, testing, or documentation impact. Use a lighter
issue-and-PR flow for small mechanical fixes, typo corrections, or single fixture
additions where the rationale is obvious from the change itself.
```

with:

```markdown
Not every change needs a full spec and plan, and not every temporary note should
be committed.

Track specs and plans when they preserve meaningful project knowledge, such as
decisions about build logic, archive handling, dependency discovery, patching,
CI, packaging, test strategy, fixture policy, or user-facing workflows.

Use a lighter issue-and-PR flow for small mechanical fixes, typo corrections,
single fixture additions, or other changes where the rationale is obvious from
the diff.
```

- [x] **Step 2: Confirm the process guide still describes PR template links as optional**

Run:

```sh
rg -n "Pull requests should link back|spec, and plan|pull_request_template" docs/superpowers/process.md
```

Expected: output includes the existing pull request linking guidance and does not
mention `.github/pull_request_template.md`.

## Task 3: Add Shared Contributor Policy

**Files:**
- Create: `CONTRIBUTING.md`

- [x] **Step 1: Create CONTRIBUTING.md from shared repository policy**

Create `CONTRIBUTING.md` with these sections:

```markdown
# Contributing

## Repository Shape

## External Dependencies

## Patch Policy

## Versioning

## Development Workflow

## Superpowers Process

## Testing and Verification

## Documentation

## Commit Messages

## Change Discipline
```

- [x] **Step 2: Verify the shared policy document exists**

Run:

```sh
rg -n "^# Contributing|^## Superpowers Process|docs/superpowers/process.md" CONTRIBUTING.md
```

Expected: output shows the contributor guide heading, the superpowers process
section, and the link to `docs/superpowers/process.md`.

## Task 4: Track Root AGENTS.md

**Files:**
- Modify: `AGENTS.md`
- Modify: `.gitignore`

- [x] **Step 1: Convert AGENTS.md to a short tracked entry point**

Keep `AGENTS.md` at the repository root. Replace duplicated policy text with a
short entry point that links to `CONTRIBUTING.md` and
`docs/superpowers/process.md`.

- [x] **Step 2: Stop ignoring AGENTS.md**

Remove the `AGENTS.md` entry from `.gitignore`.

- [x] **Step 3: Verify AGENTS.md is no longer ignored**

Run:

```sh
git check-ignore -v AGENTS.md
```

Expected: no output and exit status `1`.

## Task 5: Documentation Verification

**Files:**
- Verify: `CONTRIBUTING.md`
- Verify: `AGENTS.md`
- Verify: `.gitignore`
- Verify: `docs/superpowers/process.md`
- Verify: `docs/superpowers/specs/2026-05-21-superpowers-process-design.md`
- Verify: `docs/superpowers/plans/2026-05-21-superpowers-process.md`

- [x] **Step 1: Check for non-ASCII characters in new superpowers docs**

Run:

```sh
LC_ALL=C grep -R -n '[^ -~]' AGENTS.md CONTRIBUTING.md .gitignore docs/superpowers
```

Expected: no output and exit status `1`.

- [x] **Step 2: Check for unresolved draft markers in superpowers docs**

Run:

```sh
rg -n "TB[D]|TO[D]O|FIX[M]E|placeholde[r]" AGENTS.md CONTRIBUTING.md .gitignore docs/superpowers
```

Expected: no output and exit status `1`.

- [x] **Step 3: Review the documentation diff**

Run:

```sh
git diff -- AGENTS.md CONTRIBUTING.md .gitignore docs/superpowers
git ls-files --others --exclude-standard AGENTS.md CONTRIBUTING.md docs/superpowers
```

Expected: diff contains only the agent entry point, contributor guide,
`.gitignore` update, and superpowers process docs. New process documents may be
listed as untracked before they are staged.

- [x] **Step 4: Check repository status**

Run:

```sh
git status --short
```

Expected: output includes `.gitignore`, `AGENTS.md`, `CONTRIBUTING.md`,
`docs/superpowers/process.md`,
`docs/superpowers/specs/2026-05-21-superpowers-process-design.md`,
and `docs/superpowers/plans/2026-05-21-superpowers-process.md`.
Pre-existing untracked test exploration files may still appear and should not be
modified by this plan.

## Task 6: Commit

**Files:**
- Commit: `CONTRIBUTING.md`
- Commit: `AGENTS.md`
- Commit: `.gitignore`
- Commit: `docs/superpowers/process.md`
- Commit: `docs/superpowers/specs/2026-05-21-superpowers-process-design.md`
- Commit: `docs/superpowers/plans/2026-05-21-superpowers-process.md`

- [ ] **Step 1: Stage only the process adoption files**

Run:

```sh
git add AGENTS.md CONTRIBUTING.md .gitignore docs/superpowers/process.md docs/superpowers/specs/2026-05-21-superpowers-process-design.md docs/superpowers/plans/2026-05-21-superpowers-process.md
```

Expected: the unrelated untracked test exploration files remain unstaged.

- [ ] **Step 2: Commit the process adoption**

Run:

```sh
git commit -m "docs: add superpowers process guidance"
```

Expected: commit succeeds with only the process adoption files.
