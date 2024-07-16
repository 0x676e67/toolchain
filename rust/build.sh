#!/bin/bash

docker buildx build --platform linux/amd64 --tag ghcr.io/0x676e67/cargo-zigbuild:latest . --push
