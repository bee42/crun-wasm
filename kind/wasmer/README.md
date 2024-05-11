# Create WASMER CRUN runtime

* https://docs.wasmer.io/developers/build-from-source

Prepare rust...

```shell
git clone https://github.com/wasmerio/wasmer.git
cd wasmer
export ENABLE_SINGLEPASS=1
export ENABLE_CRANELIFT=0
export ENABLE_LLVM=0
make build-wasmer
make build-capi
make package-capi
mkdir /usr/local/lib
mkdir /usr/local/headers
cp package/lib/libwasmer.so /usr/local/lib/libwasmer.so 
cp package/headers/wasm.h /usr/local/headers/wasm.h
cp package/headers/wasmer.h /usr/local/headers/wasmer.h
```

Regards,
[`|-o-|` Your minion tour guide - Peter](mailto://peter.rossbach@bee42.com)
