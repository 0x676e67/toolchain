#!/bin/bash

docker buildx build --platform linux/amd64,linux/arm64 --tag gngpp/cargo-zigbuild:latest --tag ghcr.io/gngpp/cargo-zigbuild:latest . --push