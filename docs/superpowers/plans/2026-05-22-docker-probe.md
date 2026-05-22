# Docker Probe Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add and document a local Docker probe for Ubuntu CI-equivalent configure, build, and CTest validation.

**Architecture:** Keep the probe under `tests/docker-probe/`, preserve the existing `ci` and `shell` Compose service names, preserve the `td-ubuntu-ci-probe-amd64` image name, and document Docker as a maintainer verification path rather than a user build requirement.

**Tech Stack:** Docker Compose, Ubuntu 24.04, CMake, Ninja, CTest, Markdown documentation.

---

## Accepted Requirements

- Keep the Docker probe under `tests/docker-probe/`.
- Keep the image name `td-ubuntu-ci-probe-amd64`.
- Keep the Compose service names `ci` and `shell`.
- Keep `platform: linux/amd64`.
- Keep the default probe limited to configure, build, and CTest.
- Keep install verification separate for install-sensitive changes.
- Document brief maintainer guidance in `CONTRIBUTING.md`.
- Document detailed usage in `tests/docker-probe/README.md`.
- Do not change `.github/pull_request_template.md`.
- Do not add detailed Docker probe usage to `README.md`.

## File Structure

- Modify: `docs/superpowers/specs/2026-05-22-docker-probe-design.md`
  - Resolve open questions with accepted decisions.
- Create: `tests/docker-probe/README.md`
  - Document purpose, commands, prerequisites, limitations, and install guidance.
- Modify: `CONTRIBUTING.md`
  - Add short Docker probe guidance under testing and verification.
- Review: `tests/docker-probe/compose.yml`
  - Keep existing service and image names unless a concrete correctness issue is found.
- Review: `tests/docker-probe/ubuntu-ci.Dockerfile`
  - Keep the default configure/build/CTest command unless a concrete correctness issue is found.

## Task 1: Resolve Design Decisions

**Files:**
- Modify: `docs/superpowers/specs/2026-05-22-docker-probe-design.md`

- [x] **Step 1: Replace open questions with accepted decisions**

Replace the final `## Open Questions` section with:

```markdown
## Accepted Decisions

- Keep the image name `td-ubuntu-ci-probe-amd64` because it clearly identifies
  the repository, Ubuntu CI probe purpose, and amd64 platform.
- Keep the Compose service names `ci` and `shell`. The names are short command
  targets; details such as Ubuntu and amd64 remain in the image name,
  Dockerfile, and README.
- Keep the `shell` service as a separate debug service.
- Keep install verification separate from the default probe. The default probe
  remains configure, build, and CTest only.
```

- [x] **Step 2: Verify the design record has no unresolved questions**

Run:

```sh
rg -n "Open Questions|TB[D]|TO[D]O|FIX[M]E" docs/superpowers/specs/2026-05-22-docker-probe-design.md
```

Expected: no output and exit status `1`.

## Task 2: Add Docker Probe README

**Files:**
- Create: `tests/docker-probe/README.md`

- [x] **Step 1: Write the Docker probe README**

Create `tests/docker-probe/README.md` with purpose, non-goals, prerequisites,
commands, install guidance, and limitations.

- [x] **Step 2: Verify required commands are documented**

Run:

```sh
rg -n "docker compose -f tests/docker-probe/compose.yml (config|build ci|run --rm ci|run --rm shell)" tests/docker-probe/README.md
```

Expected: output includes all four commands.

## Task 3: Update Contributor Guidance

**Files:**
- Modify: `CONTRIBUTING.md`

- [x] **Step 1: Add a Docker probe subsection under Testing and Verification**

Add concise maintainer-facing guidance after the standard CMake and install
verification commands.

- [x] **Step 2: Verify contributor guidance links to the Docker probe README**

Run:

```sh
rg -n "Docker probe|tests/docker-probe/README.md|docker compose -f tests/docker-probe/compose.yml run --rm ci" CONTRIBUTING.md
```

Expected: output includes the subsection heading, README link, and default
command.

## Task 4: Review Compose and Dockerfile

**Files:**
- Review: `tests/docker-probe/compose.yml`
- Review: `tests/docker-probe/ubuntu-ci.Dockerfile`

- [x] **Step 1: Confirm service names, image name, platform, and default command**

Run:

```sh
rg -n "^(  ci:|  shell:)|td-ubuntu-ci-probe-amd64|platform: linux/amd64|ctest --test-dir" tests/docker-probe/compose.yml tests/docker-probe/ubuntu-ci.Dockerfile
```

Expected: output confirms both services, the image name, amd64 platform, and
CTest command.

## Task 5: Verification

**Files:**
- Verify: `CONTRIBUTING.md`
- Verify: `docs/superpowers/specs/2026-05-22-docker-probe-design.md`
- Verify: `docs/superpowers/plans/2026-05-22-docker-probe.md`
- Verify: `tests/docker-probe/README.md`
- Verify: `tests/docker-probe/compose.yml`
- Verify: `tests/docker-probe/ubuntu-ci.Dockerfile`

- [x] **Step 1: Validate Compose config**

Run:

```sh
docker compose -f tests/docker-probe/compose.yml config
```

Expected: Compose config validates successfully.

- [x] **Step 2: Build the Docker probe image**

Run:

```sh
docker compose -f tests/docker-probe/compose.yml build ci
```

Expected: image builds and bootstraps `f2c` and `ugs`.

- [x] **Step 3: Run the Docker probe**

Run:

```sh
docker compose -f tests/docker-probe/compose.yml run --rm ci
```

Expected: `td` configures with `BUILD_TESTING=ON`, builds, and CTest passes
inside the container.

- [x] **Step 4: Check for non-ASCII characters**

Run:

```sh
LC_ALL=C grep -R -n '[^ -~]' CONTRIBUTING.md docs/superpowers tests/docker-probe
```

Expected: no output and exit status `1`.

- [x] **Step 5: Check for unresolved draft markers**

Run:

```sh
rg -n "TB[D]|TO[D]O|FIX[M]E|placeholde[r]" CONTRIBUTING.md docs/superpowers tests/docker-probe
```

Expected: no output and exit status `1`.

- [x] **Step 6: Review status**

Run:

```sh
git status --short
```

Expected: output includes the Docker probe docs and `tests/docker-probe/`
changes. Pre-existing unrelated untracked files remain unstaged.
