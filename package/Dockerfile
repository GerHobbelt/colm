# syntax=docker/dockerfile:1
#
# Development environment for the mainline colm suite (colm + ragel): the
# C/C++ toolchain and autotools, enough to build the tree. Unlike the
# ragel-6 image there is no kelbt and no bootstrap ragel: colm builds first
# and then generates ragel's parsers, which are written in colm.
#
#   docker build -t colm-suite-dev package/
#
# Then, from a checkout mounted into the container:
#
#   docker run --rm -it -v "$PWD":/devel/colm -w /devel/colm colm-suite-dev
#   ./autogen.sh && ./configure && make
#
# Build args:
#   UBUNTU_TAG   base image (default 26.04, i.e. the current Ubuntu LTS);
#                pin with e.g. --build-arg UBUNTU_TAG=24.04
#   ZIG_VERSION  zig release to install from ziglang.org/download (default
#                0.16.0); pin with e.g. --build-arg ZIG_VERSION=0.15.1
#
# For now the image targets a successful build only. The test-suite host
# languages (go, java, ruby, ...) and the manual toolchain (asciidoc,
# pygmentize) can be layered on later.

ARG UBUNTU_TAG=26.04
ARG ZIG_VERSION=0.16.0

# No platform pin: unlike ragel 6.x, mainline builds natively on both amd64
# and arm64.
FROM ubuntu:${UBUNTU_TAG} AS dev
ENV DEBIAN_FRONTEND=noninteractive

# By default the container will run in the C locale. Some ragel contributions
# are in other charsets so ensure those display correctly when working in
# containers built with this dockerfile. C.UTF-8 is built into glibc, so no
# locales package is needed. LANG only: leave LC_ALL unset so the user can
# still override individual categories.
ENV LANG=C.UTF-8

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential autoconf automake libtool git ca-certificates \
        curl xz-utils; \
    rm -rf /var/lib/apt/lists/*

# Zig, from the upstream binary tarballs. Not needed to build the tree; it is
# here as a host language toolchain (and as a drop-in C/C++ cross compiler via
# "zig cc"). Shasums are those published in ziglang.org/download/index.json for
# ZIG_VERSION, so bumping the version means bumping these too.
ARG ZIG_VERSION
ARG ZIG_SHA256_X86_64=70e49664a74374b48b51e6f3fdfbf437f6395d42509050588bd49abe52ba3d00
ARG ZIG_SHA256_AARCH64=ea4b09bfb22ec6f6c6ceac57ab63efb6b46e17ab08d21f69f3a48b38e1534f17
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
        x86_64)  sha="$ZIG_SHA256_X86_64" ;; \
        aarch64) sha="$ZIG_SHA256_AARCH64" ;; \
        *) echo "no zig binary release for $arch" >&2; exit 1 ;; \
    esac; \
    tarball="zig-$arch-linux-$ZIG_VERSION.tar.xz"; \
    curl -fsSL -o "/tmp/$tarball" \
        "https://ziglang.org/download/$ZIG_VERSION/$tarball"; \
    echo "$sha  /tmp/$tarball" | sha256sum -c -; \
    mkdir -p /opt/zig; \
    tar -xJf "/tmp/$tarball" -C /opt/zig --strip-components=1; \
    rm -f "/tmp/$tarball"; \
    ln -s /opt/zig/zig /usr/local/bin/zig; \
    zig version
