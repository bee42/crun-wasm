FROM rust:1.74 as builder
RUN rustup target add wasm32-wasi
WORKDIR /src/
COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/usr/local/cargo/registry/cache \
    --mount=type=cache,target=/usr/local/cargo/registry/index \
    cargo build --target wasm32-wasi --release

FROM scratch AS server-warp
ENTRYPOINT [ "wasmedge_warp_server.wasm" ]
COPY --link --from=builder /src/target/wasm32-wasi/release/wasmedge_warp_server.wasm wasmedge_warp_server.wasm