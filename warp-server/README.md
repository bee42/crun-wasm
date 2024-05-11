# WasmEdge WASI Socket Http Server Demo

This is a clone of

* https://github.com/second-state/wasmedge_wasi_socket

Many thanks to sharing this with me!

This demo runs an echo server on `localhost`.

## Build

```shell
docker build -t bee42/cnbc/crun-wasmedge/warp-server .
k3d image import -c wasm bee42/cnbc/crun-wasmedge/warp-server
```

## Run

```shell
k create namespace demo
k ns demo
cat <<EOF |kubectl apply -n demo -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wasmedge-warp-server
  labels:
    app: wasmedge-warp-server
spec:
  selector:
    matchLabels:
      app: wasmedge-warp-server
  template:
    metadata:
      labels:
        app: wasmedge-warp-server
      annotations:
        module.wasm.image/variant: compat-smart
    spec:
      containers:
      - name: nginx
        image: nginx
      - name: wasm
        image: bee42/cnbc/crun-wasmedge/warp-server
        imagePullPolicy: Never
        ports:
        - containerPort: 8080
          protocol: TCP
        livenessProbe:
          tcpSocket:
            port: 8008
          initialDelaySeconds: 3
          periodSeconds: 30
      runtimeClassName: crun
EOF

```

## Test

In another terminal window, do the following.

```shell

k port-forward deploy/wasmedge-warp-server 8081:80 8082:8080 &
curl localhost:8082/echo -XPOST -d 'hello world'
Handling connection for 8088
hello world

curl -X POST http://127.0.0.1:8082/echo -d "name=WasmEdge"
name=WasmEdge
curl -X POST http://127.0.0.1:8082/echo -d "name=WasmEdge"

# access nginx hello
curl http://127.0.0.1:8081
```

Regards,
[`|-o-|` Your tour guide - Peter](mailto://peter.rossbach@bee42.com)
