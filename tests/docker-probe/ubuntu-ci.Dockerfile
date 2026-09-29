FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CI_PREFIX=/opt/td-ci-prefix

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    git \
    gfortran \
    libice-dev \
    libsm-dev \
    libx11-dev \
    libxaw7-dev \
    libxmu-dev \
    libxt-dev \
    ninja-build \
    python3 \
  && rm -rf /var/lib/apt/lists/*

# f2c v0.5.0; keep aligned with CI and the README baseline.
RUN git init /tmp/f2c \
  && git -C /tmp/f2c remote add origin https://github.com/goroyabu/f2c.git \
  && git -C /tmp/f2c fetch --depth=1 origin ac0e647082d720a3da5e4442578f3a2c7a98d47c \
  && git -C /tmp/f2c checkout --detach ac0e647082d720a3da5e4442578f3a2c7a98d47c \
  && test "$(git -C /tmp/f2c rev-parse HEAD)" = ac0e647082d720a3da5e4442578f3a2c7a98d47c \
  && cmake -S /tmp/f2c -B /tmp/f2c-build \
    -G Ninja \
    -DNET_FETCH=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_INSTALL_PREFIX="${CI_PREFIX}" \
  && cmake --build /tmp/f2c-build --parallel \
  && cmake --install /tmp/f2c-build \
  && rm -rf /tmp/f2c /tmp/f2c-build

# ugs v0.3.0; keep aligned with CI and the README baseline.
RUN git init /tmp/ugs \
  && git -C /tmp/ugs remote add origin https://github.com/goroyabu/ugs.git \
  && git -C /tmp/ugs fetch --depth=1 origin d392fef5487dae6c08a058380d23dd427bcdfd35 \
  && git -C /tmp/ugs checkout --detach d392fef5487dae6c08a058380d23dd427bcdfd35 \
  && test "$(git -C /tmp/ugs rev-parse HEAD)" = d392fef5487dae6c08a058380d23dd427bcdfd35 \
  && cmake -S /tmp/ugs -B /tmp/ugs-build \
    -G Ninja \
    -DNET_FETCH=ON \
    -DBUILD_TESTING=OFF \
    -DUGS_ENABLE_GUI_SMOKE=OFF \
    -DCMAKE_INSTALL_PREFIX="${CI_PREFIX}" \
  && cmake --build /tmp/ugs-build --parallel \
  && cmake --install /tmp/ugs-build \
  && rm -rf /tmp/ugs /tmp/ugs-build

WORKDIR /work

CMD ["/bin/bash", "-lc", "cmake -S /work -B /tmp/td-build -G Ninja -DNET_FETCH=ON -DBUILD_TESTING=ON -DCMAKE_PREFIX_PATH=\"${CI_PREFIX}\" && cmake --build /tmp/td-build --parallel && ctest --test-dir /tmp/td-build --output-on-failure"]
