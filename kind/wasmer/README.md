# Create WASMER CRUN runtime

* [Wasmer Github](https://github.com/wasmerio/docs.wasmer.io)
* [Wasmer docs](https://docs.wasmer.io)
* [Build Wasmer from source ](https://docs.wasmer.io/developers/build-from-source)

## Prepare your kindest boat

* Review ![Image WASMER builder](Dockerfile).

```shell
docker build -t bee42/crun-wasm/kindest-minion-wasmer:v1.29.2 .
kind create cluster \
  --image=bee42/crun-wasm/kindest-minion-wasmer-v1.29.2 \
  --name wasmer \
  --config=./wasmer-config.yaml
kubectl apply -f wasmer-runtime.yaml
```

## Examples

* [Static-Web-Server](https://hub.docker.com/r/joseluisq/static-web-server/)

Regards,
[`|-o-|` Your humble sign painter - Peter](mailto://peter.rossbach@bee42.com)
