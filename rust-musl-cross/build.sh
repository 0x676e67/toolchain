#!/bin/bash

# Default cache settings
AUTHOR=${AUTHOR:-0x676e67}
CACHE=${CACHE:-true}
NO_CACHE="--no-cache"
if [ "$CACHE" = true ]; then
    NO_CACHE=""
fi

# Define the targets
declare -A TARGETS=(
    ["1"]="x86_64-pc-windows-msvc"
    ["2"]="x86_64-unknown-linux-musl"
    ["3"]="aarch64-unknown-linux-musl"
    ["4"]="armv7-unknown-linux-musleabihf"
    ["5"]="armv7-unknown-linux-musleabi"
    ["6"]="arm-unknown-linux-musleabi"
    ["7"]="arm-unknown-linux-musleabihf"
    ["8"]="armv5te-unknown-linux-musleabi"
    ["9"]="i686-unknown-linux-musl,i686-unknown-linux-gnu"
    ["10"]="i586-unknown-linux-musl,i586-unknown-linux-gnu"
)

# Function to build a specific target
build_target() {
    local target=$1
    local additional_args=$2
    local tags=$3

    # Split tags into individual `-t` arguments
    local tag_args=""
    IFS=',' read -ra tag_array <<< "$tags"
    for tag in "${tag_array[@]}"; do
        tag_args="$tag_args -t $tag"
    done

    # Execute docker build with all tags
    docker build $NO_CACHE $additional_args $tag_args . --push
}

# Function to build all targets
build_all_targets() {
    for key in "${!TARGETS[@]}"; do
        build_single_target $key
    done
}

# Function to build a single target by key
build_single_target() {
    local key=$1
    case $key in
        1)
            cd cargo-xwin
            build_target "x86_64-pc-windows-msvc" "" "ghcr.io/${AUTHOR}/rust-musl-cross:x86_64-pc-windows-msvc"
            cd -
            ;;
        2)
            build_target "x86_64-unknown-linux-musl" "" "ghcr.io/${AUTHOR}/rust-musl-cross:x86_64-unknown-linux-musl,ghcr.io/${AUTHOR}/rust-musl-cross:x86_64-unknown-linux-gnu"
            ;;
        3)
            build_target "aarch64-unknown-linux-musl" "--build-arg TARGET=aarch64-unknown-linux-musl --build-arg RUST_MUSL_MAKE_CONFIG=config.mak" "ghcr.io/${AUTHOR}/rust-musl-cross:aarch64-unknown-linux-musl"
            ;;
        4)
            build_target "armv7-unknown-linux-musleabihf" "--build-arg TARGET=armv7-unknown-linux-musleabihf --build-arg RUST_MUSL_MAKE_CONFIG=config.mak" "ghcr.io/${AUTHOR}/rust-musl-cross:armv7-unknown-linux-musleabihf"
            ;;
        5)
            build_target "armv7-unknown-linux-musleabi" "--build-arg TARGET=armv7-unknown-linux-musleabi --build-arg RUST_MUSL_MAKE_CONFIG=config.mak" "ghcr.io/${AUTHOR}/rust-musl-cross:armv7-unknown-linux-musleabi"
            ;;
        6)
            build_target "arm-unknown-linux-musleabi" "--build-arg TARGET=arm-unknown-linux-musleabi --build-arg RUST_MUSL_MAKE_CONFIG=config.mak" "ghcr.io/${AUTHOR}/rust-musl-cross:arm-unknown-linux-musleabi"
            ;;
        7)
            build_target "arm-unknown-linux-musleabihf" "--build-arg TARGET=arm-unknown-linux-musleabihf --build-arg RUST_MUSL_MAKE_CONFIG=config.mak" "ghcr.io/${AUTHOR}/rust-musl-cross:arm-unknown-linux-musleabihf"
            ;;
        8)
            build_target "armv5te-unknown-linux-musleabi" "--build-arg TARGET=armv5te-unknown-linux-musleabi --build-arg RUST_MUSL_MAKE_CONFIG=config.mak" "ghcr.io/${AUTHOR}/rust-musl-cross:armv5te-unknown-linux-musleabi"
            ;;
        9)
            build_target "i686-unknown-linux-musl" "--build-arg TARGET=i686-unknown-linux-musl --build-arg RUST_MUSL_MAKE_CONFIG=config.mak" "ghcr.io/${AUTHOR}/rust-musl-cross:i686-unknown-linux-musl,ghcr.io/${AUTHOR}/rust-musl-cross:i686-unknown-linux-gnu"
            ;;
        10)
            build_target "i586-unknown-linux-musl" "--build-arg TARGET=i586-unknown-linux-musl --build-arg RUST_MUSL_MAKE_CONFIG=config.mak" "ghcr.io/${AUTHOR}/rust-musl-cross:i586-unknown-linux-musl,ghcr.io/${AUTHOR}/rust-musl-cross:i586-unknown-linux-gnu"
            ;;
        *)
            echo "Invalid target key: $key"
            ;;
    esac
}

# Display menu
echo "Select a target to build:"
echo "0) All targets"
for key in "${!TARGETS[@]}"; do
    echo "$key) ${TARGETS[$key]}"
done

# Read user input
read -p "Enter your choice: " choice

# Build based on user choice
if [ "$choice" -eq 0 ]; then
    build_all_targets
elif [[ ${TARGETS[$choice]+_} ]]; then
    build_single_target $choice
else
    echo "Invalid choice: $choice"
    exit 1
fi
