ARG KIND_VERSION=1.29.2
ARG CRUN_VERSION
ARG WASMEDGE_VERSION

FROM debian:bullseye AS builder
WORKDIR /data
ENV CRUN_VERSION=${CRUN_VERSION:-1.12}
ENV WASMEDGE_VERSION=${WASMEDGE_VERSION:-0.13.5}

RUN DEBIAN_FRONTEND=noninteractive apt update --fix-missing \
    && DEBIAN_FRONTEND=noninteractive apt install  -y curl make git gcc build-essential pkgconf libtool libsystemd-dev libprotobuf-c-dev libcap-dev libseccomp-dev libyajl-dev go-md2man libtool autoconf python3 automake \
    && curl https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- -p /usr/local --version=${WASMEDGE_VERSION} \
    && git clone --depth 1 --branch ${CRUN_VERSION} https://github.com/containers/crun.git \
    && cd crun \
    && ./autogen.sh \
    && ./configure --with-wasmedge --enable-embedded-yajl \
    && make 

FROM kindest/node:v$KIND_VERSION
COPY --from=builder /data/crun/crun /usr/local/sbin/crun
COPY --from=builder /usr/local/lib/libwasmedge.so /usr/local/lib/libwasmedge.so
RUN echo "Installing Packages ..." \
    && bash -c 'cat <<< $(jq "del(.hooks.createContainer)" /etc/containerd/cri-base.json) > /etc/containerd/cri-base.json' \
    && ldconfig