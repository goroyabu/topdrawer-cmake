# Superpowers Development Process

This repository uses superpowers to make maintenance work traceable from
discussion through design, implementation, verification, review, and pull request
completion.

`CONTRIBUTING.md` defines the shared development rules for humans and agents.
This document defines the superpowers-specific workflow for preserving design
records, implementation plans, verification notes, and review context.

## Principles

### 1. Design records are the source of truth for decisions

For work that involves non-trivial judgment, `docs/superpowers/specs/` is the
source of truth for design intent and trade-offs.

GitHub issues remain useful for work tracking, status, labels, and links to
related pull requests. Detailed rationale should live in a versioned design
document when the decision affects build logic, dependency discovery, archive
handling, patching, testing, CI, packaging, or user-facing documentation.

Small mechanical changes may use an issue and pull request without a separate
design document when there is no meaningful design decision to preserve.

### 2. Plans are the source of truth for execution

After a design is accepted, `docs/superpowers/plans/` records the implementation
sequence.

A plan should identify the files to touch, the expected tests or checks,
documentation updates, and intended commit boundaries. The plan exists so another
maintainer or agent can understand how the accepted design becomes a verifiable
change.

### 3. Issues track work; specs and plans explain it

GitHub issues are the project-facing work ledger. They track scope, status,
labels, related pull requests, and high-level discussion.

Specs and plans provide the detailed traceability that issue comments are not
well suited to preserve. Issues should link to the relevant spec and plan when
they exist. Pull requests should link back to the issue, spec, and plan.

### 4. Verification is part of the record

Every non-trivial change should state what was verified and what was not.

For this repository, the expected baseline remains the standard CMake workflow:

- `cmake -S . -B build`
- `cmake --build build`
- `ctest --test-dir build --output-on-failure`
- `cmake --install build --prefix <prefix>` when install behavior changes

If a check cannot be run locally, the reason and remaining risk should be
recorded in the pull request or review notes.

### 5. Repository constraints remain authoritative

Superpowers guides the workflow, but repository rules still apply.

Use `CONTRIBUTING.md` as the shared source for repository maintenance policy,
development workflow, verification expectations, documentation rules, commit
messages, and change discipline.

In particular:

- Do not commit unpacked or patched upstream source trees.
- Keep source fixes in reproducible patch logic.
- Treat `f2c`, `ugs`, and X11 as external dependencies.
- Keep README and automation aligned with build, install, archive, cache, and
  test workflow changes.
- Keep changes focused and avoid unrelated refactors.

### 6. Use the lightest process that preserves traceability

Not every change needs a full spec and plan, and not every temporary note should
be committed.

Track specs and plans when they preserve meaningful project knowledge, such as
decisions about build logic, archive handling, dependency discovery, patching,
CI, packaging, test strategy, fixture policy, or user-facing workflows.

Use a lighter issue-and-PR flow for small mechanical fixes, typo corrections,
single fixture additions, or other changes where the rationale is obvious from
the diff.

### 7. Pull requests close the loop

A pull request should summarize the implemented change, link the relevant issue,
spec, and plan, list the verification commands that were run, and call out any
residual risk.

The PR is the final integration record. It should be understandable without
requiring a reader to reconstruct the development process from chat history.
