#!/bin/bash
set -e

# Step1. check if install docker
echo "=== Step1. check if install docker ==="
if ! command -v docker &> /dev/null; then
    echo "error: docker not installed!"
    echo "Please visit https://www.docker.com/"
    exit 1
fi

docker build -t linux-kernel-builder .

docker build -f Dockerfile.busybox -t busybox-builder .

