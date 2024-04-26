ARG WASM_VERSION
ARG CRUN_VERSION
ARG K3S_VERSION

FROM alpine:3.19 AS builder
WORKDIR /data
RUN apk add curl gcc automake autoconf libtool gettext pkgconf git make musl-dev \
    python3 libcap-dev libseccomp-dev yajl-dev argp-standalone go-md2man coreutils bash gcompat
RUN curl -L https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- -p /usr/local --version=0.13.5 \
    && git clone --depth 1 --branch 1.12 https://github.com/containers/crun.git \
    && cd crun \
    && ./autogen.sh \
    && ./configure --with-wasmedge --enable-embedded-yajl --disable-systemd  --without-shared --disable-shared \
    && make 

FROM rancher/k3s:v1.29.3-k3s1
RUN mkdir -p /usr/local/bin /usr/local/lib && mkdir -p /opt/bin
COPY --from=builder /data/crun/crun /opt/bin/crun
COPY --from=builder /usr/local/lib/libwasmedge.so.0.0.3 /usr/local/lib/libwasmedge.so.0.0.3 
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=builder /usr/lib/libseccomp.so.2.5.5 /usr/lib/libseccomp.so.2.5.5
COPY --from=builder /usr/lib/libcap.so.2.69 /usr/lib/libcap.so.2.69
COPY --from=builder /lib/libz.so.1 /lib/libz.so.1
COPY --from=builder /lib/libz.so.1 /lib/libz.so.1
COPY --from=builder /usr/lib/libstdc++.so.6.0.32 /usr/lib/libstdc++.so.6.0.32
COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1
COPY --from=builder /usr/lib/libgcc_s.so /usr/lib/libgcc_s.so
COPY --from=builder /lib/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2

RUN ln -s /usr/local/lib/libwasmedge.so.0.0.3  /usr/local/lib/libwasmedge.so.0 && \
    ln -s /usr/local/lib/libwasmedge.so.0 /usr/local/lib/libwasmedge.so && \
    ln -s /usr/lib/libseccomp.so.2.5.5 /usr/lib/libseccomp.so.2 && \
    ln -s /usr/lib/libseccomp.so.2 /usr/lib/libseccomp.so && \
    ln -s /usr/lib/libcap.so.2.69  /usr/lib/libcap.so.2 && \
    ln -s /usr/lib/libcap.so.2  /usr/lib/libcap.so && \
#    ln -s /lib/libz.so.1.3  /lib/libz.so.1 && \
    ln -s /usr/lib/libstdc++.so.6.0.32  /usr/lib/libstdc++.so.6

COPY config.toml.tmpl /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl

