# Repository Agent Guidance

This file is the repository-level entry point for agent sessions. Keep it short
and delegate durable policy to tracked project documentation.

## Required Reading

- Use `CONTRIBUTING.md` for shared repository maintenance policy, development
  workflow, verification expectations, documentation rules, commit messages, and
  change discipline.
- Use `docs/superpowers/process.md` for the superpowers-specific workflow for
  design records, implementation plans, verification notes, and review context.

## Operating Rules

- Follow `CONTRIBUTING.md` before changing build logic, dependency discovery,
  archive handling, patching, tests, CI, packaging, documentation, or release
  metadata.
- Use the superpowers workflow when work needs traceability across design,
  implementation planning, verification, and review.
- Do not commit unpacked or patched upstream source trees.
- Do not edit generated or unpacked files under `build/vendor`; move required
  fixes into the reproducible patching step.
- Do not revert unrelated user changes.
