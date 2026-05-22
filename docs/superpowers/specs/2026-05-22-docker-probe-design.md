# Docker Probe Design

## Summary

Add a local Docker probe that lets maintainers and contributors run an
Ubuntu-based validation path close to the GitHub Actions CI workflow.

The probe lives under `tests/docker-probe/` and validates the core configure,
build, and CTest flow for `td` after bootstrapping the external `f2c` and `ugs`
dependencies.

## Background

GitHub Actions already validates this repository on Ubuntu by installing system
build dependencies, cloning and installing `f2c` and `ugs`, configuring `td`,
building it, and running CTest.

Maintainers need a local way to reproduce that path before pushing changes or
opening pull requests, especially when work affects CI bootstrap, dependency
discovery, build logic, test execution, packaging-sensitive behavior, or related
documentation.

The existing repository workflow remains CMake-first. Docker is a local
verification aid, not the primary user-facing build path.

## Goals

- Provide a local Docker-based probe for Ubuntu CI-equivalent configure, build,
  and CTest validation.
- Keep Docker optional for normal user build and install workflows.
- Keep the probe under `tests/docker-probe/`.
- Bootstrap `f2c` and `ugs` inside the Docker image, matching the CI dependency
  shape closely enough to catch bootstrap and discovery regressions.
- Document short usage guidance in `CONTRIBUTING.md`.
- Document detailed usage, prerequisites, expected behavior, limitations, and
  troubleshooting in `tests/docker-probe/README.md`.

## Non-Goals

- Do not replace GitHub Actions.
- Do not require Docker for normal user builds.
- Do not make Docker the primary supported runtime environment for `td`.
- Do not add a required CI job for the Docker probe in this step.
- Do not require install verification as part of the default Docker probe.
- Do not change Topdrawer behavior or upstream source patching as part of this
  work.

## Directory Name

Use `tests/docker-probe/` rather than `tests/docker/`.

The directory contains a maintainer probe for CI-equivalent validation. It is not
a general Docker test framework, a supported runtime container, or a packaging
target. Keeping `probe` in the name makes that limited role visible and reduces
the chance that future changes treat Docker as the primary test or runtime
interface.

## Success Criteria

The initial Docker probe succeeds when:

- `docker compose config` validates the compose file.
- The Docker image can bootstrap `f2c` and `ugs`.
- The probe can configure this repository with `BUILD_TESTING=ON`.
- The probe can build `td`.
- The probe can run `ctest --test-dir <build-dir> --output-on-failure`.

Install verification remains a separate check for changes that affect install
rules, install layout, runtime assets, or packaging behavior.

## Verification Policy

The Docker probe is optional for normal development and normal user builds.

Maintainers should run it when validating changes that affect:

- CI bootstrap.
- External dependency discovery.
- CMake build logic.
- Test registration or execution.
- Packaging-sensitive behavior.
- Documentation that describes the bootstrap or verification workflow.

Maintainers may also run it as a pre-PR confidence check for broader maintenance
changes.

## Expected User Flow

From the repository root, the intended default command should be:

```sh
docker compose -f tests/docker-probe/compose.yml run --rm ci
```

Useful supporting commands may include:

```sh
docker compose -f tests/docker-probe/compose.yml config
docker compose -f tests/docker-probe/compose.yml build ci
docker compose -f tests/docker-probe/compose.yml run --rm --profile debug shell
```

Exact command names may be refined in the implementation plan if the current
Compose file needs adjustment.

## Documentation Plan

`CONTRIBUTING.md` should include a short maintainer-facing note that the Docker
probe can be used for local CI-equivalent validation and should show the primary
command.

`tests/docker-probe/README.md` should include:

- Purpose and non-goals.
- Prerequisites.
- Default command.
- Optional debug shell command.
- What the probe validates.
- When maintainers should run it.
- Install verification guidance for install-sensitive changes.
- Known limitations, including Docker runtime availability, architecture
  assumptions, network access for dependency bootstrap, and expected runtime
  cost.

README.md should remain focused on user-facing build, install, usage, and
troubleshooting. It should not grow detailed Docker probe instructions unless
the user-facing build workflow changes.

## Risks and Tradeoffs

- The probe will be slower than local incremental CMake builds because it
  bootstraps `f2c` and `ugs`.
- Network access is needed when building the Docker image unless dependencies are
  already cached by Docker layers.
- Docker availability differs across maintainer machines.
- The current Compose file targets `linux/amd64`; this improves consistency with
  GitHub Actions but may be slower on non-amd64 hosts.
- Keeping the probe outside required CI avoids adding a second required
  validation path before the workflow proves useful.

## Accepted Decisions

- Keep the image name `td-ubuntu-ci-probe-amd64` because it clearly identifies
  the repository, Ubuntu CI probe purpose, and amd64 platform.
- Keep the Compose service names `ci` and `shell`. The names are short command
  targets; details such as Ubuntu and amd64 remain in the image name,
  Dockerfile, and README.
- Keep the `shell` service as a separate debug service.
- Keep install verification separate from the default probe. The default probe
  remains configure, build, and CTest only.
