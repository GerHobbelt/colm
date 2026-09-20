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
#   UBUNTU_TAG   base image (default latest, i.e. the current Ubuntu LTS);
#                pin with e.g. --build-arg UBUNTU_TAG=24.04
#
# For now the image targets a successful build only. The test-suite host
# languages (go, java, ruby, ...) and the manual toolchain (asciidoc,
# pygmentize) can be layered on later.

ARG UBUNTU_TAG=latest

# No platform pin: unlike ragel 6.x, mainline builds natively on both amd64
# and arm64.
FROM ubuntu:${UBUNTU_TAG} AS dev
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential autoconf automake libtool git ca-certificates; \
    rm -rf /var/lib/apt/lists/*
