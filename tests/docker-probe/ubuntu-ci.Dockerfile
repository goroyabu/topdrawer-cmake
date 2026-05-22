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
  && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/goroyabu/f2c.git /tmp/f2c \
  && cmake -S /tmp/f2c -B /tmp/f2c-build \
    -G Ninja \
    -DNET_FETCH=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_INSTALL_PREFIX="${CI_PREFIX}" \
  && cmake --build /tmp/f2c-build --parallel \
  && cmake --install /tmp/f2c-build \
  && rm -rf /tmp/f2c /tmp/f2c-build

RUN git clone --depth=1 https://github.com/goroyabu/ugs.git /tmp/ugs \
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
