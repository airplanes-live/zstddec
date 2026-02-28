#!/bin/bash

wget https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz
tar xf zstd-1.5.7.tar.gz

cd zstd-1.5.7/build/single_file_libs
./combine.sh -r ../../lib -o zstddeclib.c zstddeclib-in.c
cp zstddeclib.c ../../..
cd ../../..

patch -u zstddeclib.c -i patch.diff

docker pull emscripten/emsdk:latest
docker run --rm -v $(pwd):/src -u $(id -u):$(id -g) emscripten/emsdk:latest emcc \
    zstddeclib.c -O3 \
    -Wl,--no-entry \
    -sEXPORTED_FUNCTIONS=_ZSTD_decompress,_ZSTD_findDecompressedSize,_ZSTD_isError,_malloc,_free \
    -sALLOW_MEMORY_GROWTH=1 \
    -sTOTAL_STACK=64kb \
    -sTOTAL_MEMORY=2Mb \
    -DNDEBUG \
    -o zstddec.wasm

base64 -w 0 zstddec.wasm > zstddec.wasm.base64