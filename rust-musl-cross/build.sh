#!/bin/bash
set -ex

CACHE=${CACHE:-true}
NO_CACHE="$NO_CACHE"
if [ "$CACHE" = true ]; then
    NO_CACHE=""
fi

# x86_64-pc-windows-msvc
#cd cargo-xwin
#docker build $NO_CACHE -t ghcr.io/penumbra-x/rust-musl-cross:x86_64-pc-windows-msvc . --push
#cd -

# x86_64-unknown-linux-musl
docker build $NO_CACHE -t ghcr.io/penumbra-x/rust-musl-cross:x86_64-unknown-linux-musl . --push

# aarch64-unknown-linux-musl
docker build $NO_CACHE --build-arg TARGET=aarch64-unknown-linux-musl \
    --build-arg RUST_MUSL_MAKE_CONFIG=config.mak \
    -t ghcr.io/penumbra-x/rust-musl-cross:aarch64-unknown-linux-musl . --push

# armv7-unknown-linux-musleabihf
docker build $NO_CACHE --build-arg TARGET=armv7-unknown-linux-musleabihf \
    --build-arg RUST_MUSL_MAKE_CONFIG=config.mak \
    -t ghcr.io/penumbra-x/rust-musl-cross:armv7-unknown-linux-musleabihf . --push

# armv7-unknown-linux-musleabi
docker build $NO_CACHE --build-arg TARGET=armv7-unknown-linux-musleabi \
    --build-arg RUST_MUSL_MAKE_CONFIG=config.mak \
    -t ghcr.io/penumbra-x/rust-musl-cross:armv7-unknown-linux-musleabi . --push

# arm-unknown-linux-musleabi
docker build $NO_CACHE --build-arg TARGET=arm-unknown-linux-musleabi \
    --build-arg RUST_MUSL_MAKE_CONFIG=config.mak \
    -t ghcr.io/penumbra-x/rust-musl-cross:arm-unknown-linux-musleabi . --push

# arm-unknown-linux-musleabihf
docker build $NO_CACHE --build-arg TARGET=arm-unknown-linux-musleabihf \
    --build-arg RUST_MUSL_MAKE_CONFIG=config.mak \
    -t ghcr.io/penumbra-x/rust-musl-cross:arm-unknown-linux-musleabihf . --push

# armv5te-unknown-linux-musleabi
docker build $NO_CACHE --build-arg TARGET=armv5te-unknown-linux-musleabi \
    --build-arg RUST_MUSL_MAKE_CONFIG=config.mak \
    -t ghcr.io/penumbra-x/rust-musl-cross:armv5te-unknown-linux-musleabi . --push

# i686-unknown-linux-musl i686-unknown-linux-gnu
docker build $NO_CACHE --build-arg TARGET=i686-unknown-linux-musl \
    --build-arg RUST_MUSL_MAKE_CONFIG=config.mak \
    -t ghcr.io/penumbra-x/rust-musl-cross:i686-unknown-linux-musl \
    -t ghcr.io/penumbra-x/rust-musl-cross:i686-unknown-linux-gnu . --push

# i586-unknown-linux-musl i586-unknown-linux-gnu
docker build $NO_CACHE --build-arg TARGET=i586-unknown-linux-musl \
    --build-arg RUST_MUSL_MAKE_CONFIG=config.mak \
    -t ghcr.io/penumbra-x/rust-musl-cross:i586-unknown-linux-musl \
    -t ghcr.io/penumbra-x/rust-musl-cross:i586-unknown-linux-gnu . --push
