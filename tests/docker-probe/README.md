# Docker Probe

This directory contains a local Docker probe for maintainers and contributors
who need to reproduce the Ubuntu CI configure, build, and CTest path.

The probe is not the primary user build path for `td`. The standard CMake
workflow remains the supported user-facing build and install workflow.

## What It Checks

The default probe:

- builds an Ubuntu 24.04 image;
- installs system build dependencies;
- clones, builds, and installs `f2c`;
- clones, builds, and installs `ugs`;
- configures this repository with `BUILD_TESTING=ON`;
- builds `td`;
- runs `ctest --test-dir /tmp/td-build --output-on-failure`.

It does not run `cmake --install` by default. Run an install check separately
when changing install rules, install layout, runtime assets, or packaging
behavior.

## Prerequisites

- Docker with Compose support.
- Network access while building the image, because the image clones `f2c` and
  `ugs`.
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

For install-related changes, run the default probe first. Then use the debug
shell or an explicit command override to run an install check with a temporary
prefix, for example:

```sh
docker compose -f tests/docker-probe/compose.yml run --rm ci /bin/bash -lc \
  'cmake -S /work -B /tmp/td-build -G Ninja -DNET_FETCH=ON -DBUILD_TESTING=ON -DCMAKE_PREFIX_PATH="${CI_PREFIX}" && cmake --build /tmp/td-build --parallel && cmake --install /tmp/td-build --prefix /tmp/td-install'
```

Install verification is intentionally separate so the default probe stays
focused on the CI-equivalent configure, build, and CTest path.

## Limitations

- The probe does not replace GitHub Actions.
- Docker is not required for normal user builds.
- The image build depends on network access unless Docker layers are already
  cached.
- The probe does not test interactive X11 behavior.
- The default command does not verify install layout or installed runtime assets.
