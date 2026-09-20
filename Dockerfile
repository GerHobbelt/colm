# syntax=docker/dockerfile:1
#
# Development environment for the mainline colm suite (colm + ragel): the
# C/C++ toolchain, autotools and cmake, enough to build the tree either
# way, plus the host language toolchains the ragel test suite drives.
# Unlike the ragel-6 image there is no kelbt and no bootstrap ragel: colm
# builds first and then generates ragel's parsers, which are written in
# colm.
#
#   docker build -t colm-suite-dev .
#
# Then, from a checkout mounted into the container:
#
#   docker run --rm -it -v "$PWD":/devel/colm -w /devel/colm colm-suite-dev
#   ./autogen.sh && ./configure && make && make check
#
# or, for the cmake build, which needs no autotools step:
#
#   cmake -S . -B build && cmake --build build
#
# Build args:
#   UBUNTU_TAG     base image (default 26.04, i.e. the current Ubuntu LTS);
#                  pin with e.g. --build-arg UBUNTU_TAG=24.04
#   ZIG_VERSION    zig release to install from ziglang.org/download (default
#                  0.16.0); pin with e.g. --build-arg ZIG_VERSION=0.15.1
#   JULIA_VERSION  julia release to install from julialang.org/downloads
#                  (default 1.12.7)
#
# Host languages covered, as the test suite exercises them: C, C++, Objective-C
# (gnustep), D, Java, Ruby, C#, Go, OCaml, Rust, Julia and Zig. Not covered:
# crack, which is unpackaged and whose upstream is dormant (configure and the
# test suite skip it silently when it is absent), and asm, which needs no
# toolchain beyond $CC but is x86-64 only, so it never runs on arm64. Note the
# configure probe for asm links its conftest without -no-pie while the tests
# themselves pass it, so on a PIE-default gcc the asm tests are skipped even on
# x86-64; that is a configure.ac matter, not an image one. The manual
# toolchain (asciidoc, pygmentize) is not installed either.

ARG UBUNTU_TAG=26.04
ARG ZIG_VERSION=0.16.0
ARG JULIA_VERSION=1.12.7

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
        build-essential autoconf automake libtool cmake git ca-certificates \
        curl xz-utils; \
    rm -rf /var/lib/apt/lists/*

# Test suite host languages available from the ubuntu archive.
#
#   gobjc, gnustep-make, libgnustep-base-dev
#       objective-c: the cc1obj front end, gnustep-config (which configure
#       probes for) and the gnustep-base headers and library the tests link.
#   golang-go       go
#   default-jdk     java: javac to compile, the java launcher to run
#   ruby            ruby
#   ocaml           the ocaml toplevel; the tests are interpreted, not compiled
#   rustc           rust
#   gdc             d. The archive ships gdc-11 through gdc-16 plus this
#                   unversioned front, which is what configure's fallback probe
#                   picks up.
#   mono-devel      c#: mcs to compile; pulls in mono-runtime to run. Ubuntu
#                   26.04 repackaged mono (6.14, from the winehq-maintained
#                   source) under these names; the old mono-mcs is gone.
#                   Do not add the mono-project.com repository: it is frozen at
#                   6.12 and its packages conflict with the archive's.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        gobjc gnustep-make libgnustep-base-dev \
        golang-go default-jdk ruby ocaml rustc gdc mono-devel; \
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

# Julia, from the upstream generic linux tarballs; ubuntu dropped its julia
# package in 26.04. Shasums are those published in
# julialang-s3.julialang.org/bin/checksums/julia-JULIA_VERSION.sha256, so
# bumping the version means bumping these too.
ARG JULIA_VERSION
ARG JULIA_SHA256_X86_64=4e7e9e776634d24835250de67cde39b0d4af15bc432eb20697e6be6c28ea69e8
ARG JULIA_SHA256_AARCH64=9243c0b524c7f300883240a1ee5ea3916a30e070bff718acf8ccaee31a731ef2
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
        x86_64)  sha="$JULIA_SHA256_X86_64";  dir=x64 ;; \
        aarch64) sha="$JULIA_SHA256_AARCH64"; dir=aarch64 ;; \
        *) echo "no julia binary release for $arch" >&2; exit 1 ;; \
    esac; \
    tarball="julia-$JULIA_VERSION-linux-$arch.tar.gz"; \
    series="$(echo "$JULIA_VERSION" | sed 's/\.[0-9]*$//')"; \
    curl -fsSL -o "/tmp/$tarball" \
        "https://julialang-s3.julialang.org/bin/linux/$dir/$series/$tarball"; \
    echo "$sha  /tmp/$tarball" | sha256sum -c -; \
    mkdir -p /opt/julia; \
    tar -xzf "/tmp/$tarball" -C /opt/julia --strip-components=1; \
    rm -f "/tmp/$tarball"; \
    ln -s /opt/julia/bin/julia /usr/local/bin/julia; \
    julia --version
