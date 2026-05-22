# Superpowers Process Design

## Summary

This repository will use shared contributor documentation and superpowers
documentation together to preserve repository policy, design decisions,
implementation plans, verification records, and review context for maintenance
work that needs traceability.

The initial process document is `docs/superpowers/process.md`. The shared
contributor policy document is `CONTRIBUTING.md`. This design record explains
why those documents exist, how they relate to GitHub issues and pull requests,
and which superpowers documents should be committed to the repository.

## Background

Historically, GitHub issues have been the primary source of truth for both work
tracking and design discussion. That works for small tasks, but it becomes weak
when a change affects CMake build logic, dependency discovery, archive handling,
patching, CI, packaging, rendering tests, or user-facing documentation.

This repository maintains a reproducible build and install workflow for the
legacy Topdrawer tool. Many changes are maintenance-oriented rather than feature
oriented, so the important question is often why a workflow, patching rule, or
verification path changed. That rationale should be reviewable in Git history,
not only scattered through issue comments or chat history.

## Goals

- Preserve important design rationale in versioned repository files.
- Preserve shared repository maintenance policy in a contributor-facing document.
- Keep GitHub issues useful for status tracking and project-facing discussion.
- Make implementation plans explicit enough for another maintainer or agent to
  execute and verify.
- Keep the process lightweight for small mechanical changes.
- Avoid turning temporary notes, experiments, or chat transcripts into permanent
  repository artifacts.

## Non-Goals

- Require a spec and plan for every small change.
- Replace GitHub issues, labels, pull requests, or release metadata.
- Move all issue discussion into repository files.
- Add automation before the manual process is proven useful.
- Change the repository scope beyond maintaining the Topdrawer build workflow.
- Move detailed agent guidance out of the root entry point.

## Source of Truth Model

The process separates records by responsibility:

- `docs/superpowers/specs/` is the source of truth for design decisions.
- `docs/superpowers/plans/` is the source of truth for accepted implementation
  sequences.
- GitHub issues are the source of truth for work status, labels, and public work
  tracking.
- Pull requests are the source of truth for integration results and final
  verification records.
- `CONTRIBUTING.md` is the source of truth for shared repository maintenance
  policy, development workflow, verification expectations, documentation rules,
  commit messages, and change discipline.
- Root `AGENTS.md` is the tracked agent entry point. It should remain
  discoverable at session start and should point to the tracked policy and
  process documents rather than duplicating them.

This separation avoids overloading GitHub issues with detailed rationale while
keeping issues useful as the project-facing work ledger.

## Tracked Document Policy

Superpowers specs and plans are repository artifacts when they preserve
meaningful project knowledge. They should be committed when they explain
decisions or execution paths that future maintainers may need to audit.

Track specs and plans for changes that affect:

- CMake build logic or install behavior.
- Archive, cache, download, or cleanup workflow.
- Dependency discovery for `f2c`, `ugs`, X11, or related external libraries.
- Source patching policy or patch implementation.
- CI, packaging, release metadata, or repository policy.
- Test strategy, rendering checks, or fixture policy.
- User-facing README guidance or supported usage workflows.

Do not create tracked specs or plans for changes where the rationale is obvious
from the diff, such as:

- Typo fixes.
- Small formatting corrections.
- Single fixture additions that follow an established pattern.
- Mechanical updates with no policy or workflow impact.
- Temporary investigations or failed experiments.

If a small change starts to reveal a broader policy or workflow question, promote
it to the full spec and plan workflow.

## Issue and Pull Request Linking

When an issue exists, it should link to the relevant spec and plan once those
documents exist. The issue remains the work-tracking hub.

When a pull request exists, it should link back to:

- The issue it closes or advances.
- The relevant spec, if one exists.
- The relevant plan, if one exists.

The pull request should also summarize the verification commands that were run
and identify any checks that could not be run locally.

## Process Shape

For substantial work, the preferred flow is:

1. Open or identify a GitHub issue for the work item.
2. Write a design spec under `docs/superpowers/specs/`.
3. Review and accept the design.
4. Write an implementation plan under `docs/superpowers/plans/`.
5. Execute the plan on a topic branch.
6. Verify the result with the relevant CMake, CTest, install, or focused checks.
7. Open or update the pull request with links and verification results.
8. Use review feedback to update code, docs, the spec, or the plan when needed.

For small mechanical work, an issue and pull request may be enough.

## Verification Expectations

The process document names the repository baseline:

- `cmake -S . -B build`
- `cmake --build build`
- `ctest --test-dir build --output-on-failure`
- `cmake --install build --prefix <prefix>` when install behavior changes

Individual plans may use narrower checks when the change is small, but the pull
request should state which checks were run and why they are sufficient.

## Documentation Placement

The shared contributor guide lives at:

- `CONTRIBUTING.md`

The process guide lives at:

- `docs/superpowers/process.md`

Design specs live at:

- `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

Implementation plans live at:

- `docs/superpowers/plans/YYYY-MM-DD-<topic>.md`

This repository should not add a general `docs/superpowers/notes/` directory at
this stage. Temporary notes should stay in issues, pull request comments, or the
working session unless they mature into a spec or plan.

The agent guidance entry point lives at:

- `AGENTS.md`

## Adoption Plan

Initial adoption should stay narrow:

1. Keep `docs/superpowers/process.md` as the process entry point.
2. Use this spec as the first tracked design record.
3. Add `CONTRIBUTING.md` as the shared contributor-facing repository policy.
4. Add a plan only after the process design is accepted.
5. Track root `AGENTS.md` as a short session-start entry point.
6. Consider pull request template updates only after the process is used on at
   least one real maintenance change.

This staged adoption keeps the repository from accumulating process overhead
before the workflow proves useful.

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
