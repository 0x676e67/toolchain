#!/bin/bash

image=ghcr.io/gngpp/lede-builder:$1
docker build --platform linux/$1 -t $image -f Dockerfile-$1 . 
docker push $image