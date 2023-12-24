#!/bin/bash

docker buildx build --platform linux/amd64 --tag ghcr.io/gngpp/cargo-zigbuild:latest . --push