ARG KIND_VERSION=1.29.2
ARG CRUN_VERSION
ARG WASMEDGE_VERSION

# get wasmedge and compile crun
FROM debian:bullseye AS builder
WORKDIR /data
ENV CRUN_VERSION=${CRUN_VERSION:-1.15}
ENV WASMEDGE_VERSION=${WASMEDGE_VERSION:-0.13.5}

RUN DEBIAN_FRONTEND=noninteractive apt update --fix-missing \
    && DEBIAN_FRONTEND=noninteractive apt install  -y curl make git gcc build-essential pkgconf libtool libsystemd-dev libprotobuf-c-dev libcap-dev libseccomp-dev libyajl-dev go-md2man libtool autoconf python3 automake \
    && curl https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- -p /usr/local --version=${WASMEDGE_VERSION} \
    && git clone --depth 1 --branch ${CRUN_VERSION} https://github.com/containers/crun.git

RUN cd crun \
    && ./autogen.sh \
    && ./configure --with-wasmedge --enable-embedded-yajl \
    && make 

# compile crun with wasmedge
FROM kindest/node:v$KIND_VERSION
ARG BUILD_DATE
ARG BUILD_REVISION
LABEL org.opencontainers.image.title="kindest crun wasmedge node"
LABEL org.opencontainers.image.vendor="bee42 solutions gmbh"
LABEL org.opencontainers.image.authors="peter.rossbach@bee42.com"
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.source="https://github.com/bee42/crun-wasm"
COPY --from=builder /data/crun/crun /usr/local/sbin/crun
COPY --from=builder /usr/local/lib/libwasmedge.so /usr/local/lib/libwasmedge.so
RUN echo "Installing Packages ..." \
    && bash -c 'cat <<< $(jq "del(.hooks.createContainer)" /etc/containerd/cri-base.json) > /etc/containerd/cri-base.json' \
    && ldconfig
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${BUILD_REVISION}"