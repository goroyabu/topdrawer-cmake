# Docker Probe

This directory contains a local Docker probe for maintainers and contributors
who need to reproduce the Ubuntu CI configure, build, and CTest path.

The probe is not the primary user build path for `td`. The standard CMake
workflow remains the supported user-facing build and install workflow.

## What It Checks

The default probe:

- builds an Ubuntu 24.04 image;
- installs system build dependencies;
- fetches the pinned f2c and UGS commits, verifies their checkout IDs, and
  builds and installs them (see the [baseline table](../../README.md#dependency-baseline));
- configures this repository with `BUILD_TESTING=ON`;
- builds `td`;
- runs `ctest --test-dir /tmp/td-build --output-on-failure`, including the
  installed-behavior checks in isolated temporary prefixes.

The installed-behavior checks use Python 3 and cover the executable, help
asset, and uninstall without changing the probe's dependency installation.

## Prerequisites

- Docker with Compose support.
- Network access while building the image, to fetch dependency commits and
  their upstream archives.
- Enough time for a full dependency bootstrap. The probe is slower than a local
  incremental CMake build.

The Compose file targets `linux/amd64` to stay close to the GitHub Actions
environment. On non-amd64 hosts, Docker may use emulation and run more slowly.

## Commands

Validate the Compose configuration:

```sh
docker compose -f tests/docker-probe/compose.yml config
```

Build the probe image:

```sh
docker compose -f tests/docker-probe/compose.yml build ci
```

Run the default CI-equivalent probe:

```sh
docker compose -f tests/docker-probe/compose.yml run --rm ci
```

Open a debug shell in the probe image:

```sh
docker compose -f tests/docker-probe/compose.yml run --rm shell
```

If the debug shell image is missing, build it first with:

```sh
docker compose -f tests/docker-probe/compose.yml build ci
```

## When To Run It

Run the Docker probe when validating changes that affect:

- CI bootstrap;
- external dependency discovery;
- CMake build logic;
- test registration or execution;
- packaging-sensitive behavior;
- documentation that describes bootstrap or verification workflows.

It is also useful as a pre-PR confidence check for broader maintenance changes.

## Install-Sensitive Changes

The default probe includes the three installation checks. To run only those
checks after building td in the debug shell, use:

```sh
ctest --test-dir /tmp/td-build -L install --output-on-failure
```

## Limitations

- The probe does not replace GitHub Actions.
- Docker is not required for normal user builds.
- The image build depends on network access unless Docker layers are already
  cached.
- The installed-behavior checks do not establish visual correctness or
  interactive X11 behavior.
