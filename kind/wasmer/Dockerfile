ARG RUST_VERSION=1.74
ARG KIND_VERSION=1.29.2
ARG CRUN_VERSION
ARG WASMER_VERSION

# Build wasmer libs
FROM rust:${RUST_VERSION} as wasmer
ENV WASMER_VERSION=${WASMER_VERSION:-4.3.0}
WORKDIR /src/
RUN git clone --depth 1 --branch v${WASMER_VERSION} https://github.com/wasmerio/wasmer.git \
    && cd wasmer \
    && export ENABLE_SINGLEPASS=1 \
    && export ENABLE_CRANELIFT=0 \
    && export ENABLE_LLVM=0 \
    && make build-wasmer \
    && make build-capi \
    && make package-capi

# compile crun with wasmer
FROM debian:bullseye AS builder
WORKDIR /data
ENV CRUN_VERSION=${CRUN_VERSION:-1.15}
RUN DEBIAN_FRONTEND=noninteractive apt update --fix-missing \
    && DEBIAN_FRONTEND=noninteractive apt install -y curl make git gcc build-essential pkgconf libtool libsystemd-dev libprotobuf-c-dev libcap-dev libseccomp-dev libyajl-dev go-md2man libtool autoconf python3 automake
RUN git clone --depth 1 --branch ${CRUN_VERSION} https://github.com/containers/crun.git
RUN mkdir -p /usr/local/lib && mkdir -p /usr/local/include
COPY --from=wasmer /src/wasmer/package/lib/libwasmer.so /usr/local/lib/libwasmer.so 
COPY --from=wasmer /src/wasmer/package/include/*.h /usr/local/include/
RUN cd crun \
    && ./autogen.sh \
    && ./configure --with-wasmer --enable-embedded-yajl \
    && make 

# create kindest node with crun-wasmer
FROM kindest/node:v$KIND_VERSION
ARG BUILD_DATE
ARG BUILD_REVISION
LABEL org.opencontainers.image.title="kindest minion crun-wasmer "
LABEL org.opencontainers.image.vendor="bee42 solutions gmbh"
LABEL org.opencontainers.image.authors="peter.rossbach@bee42.com"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/bee42/crun-wasm"
COPY --from=builder /data/crun/crun /usr/local/sbin/crun
COPY --from=wasmer /src/wasmer/package/lib/libwasmer.so /usr/local/lib/libwasmer.so
RUN echo "Installing Packages ..." \
    && bash -c 'cat <<< $(jq "del(.hooks.createContainer)" /etc/containerd/cri-base.json) > /etc/containerd/cri-base.json' \
    && ldconfig
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${BUILD_REVISION}"