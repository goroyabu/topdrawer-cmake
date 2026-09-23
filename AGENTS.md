# Repository Agent Guidance

## Scope

This repository maintains the reproducible build, install, and test workflow
for legacy Topdrawer. Focus on maintenance, portability, packaging, verification,
and documentation, not new upstream plotting features.

## Canonical Guidance

- Read `README.md` for user-facing build, install, usage, and limitations.
- Follow `CONTRIBUTING.md` for development, verification, documentation,
  commits, and integration policy.
- Follow `tests/README.md` for test coverage, fixture policy, and limitations.
- Use `tests/docker-probe/README.md` for the local Ubuntu verification probe.
- Use the repository pull request template.

Keep detailed procedures in their canonical documents. Personal and
machine-specific instructions belong outside tracked repository guidance.

## Operating Rules

- Follow `CONTRIBUTING.md` before changing build logic, dependency discovery,
  archive handling, patching, tests, CI, packaging, documentation, or release
  metadata.
- Keep shared documentation, code comments, commits, Issues, and PRs in English.
- Keep long-lived documentation self-contained. Use Issues and PRs for working
  decisions and history, and keep temporary planning artifacts untracked.
- Treat f2c, UGS, and X11 as external dependencies; preserve td's documented
  executable and help-file interfaces.
- Before creating commits, pushing branches or tags, creating or updating pull
  requests, or creating/updating/commenting on GitHub issues, stop and explain
  the target, proposed content or command, reason, expected effect, and notable
  risks. Proceed only after explicit user approval for that specific action.
- Do not commit unpacked or patched upstream source trees.
- Do not edit generated or unpacked files under `build/vendor`; move required
  fixes into the reproducible patching step.
- Do not revert unrelated user changes.
- Run verification proportional to the change and state actual results and
  limitations. Passing PostScript tests does not prove visual correctness or
  interactive X11 behavior. Do not claim unverified environments are supported.
