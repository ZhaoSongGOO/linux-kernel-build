#!/bin/bash

set -e

echo "=== Build Linux Kernel in Mac ==="

# Step1. check if install docker
echo "=== Step1. check if install docker ==="
if ! command -v docker &> /dev/null; then
    echo "error: docker not installed!"
    echo "Please visit https://www.docker.com/"
    exit 1
fi

# Step2. edit dockerfile

cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV HTTPS_PROXY=http://host.docker.internal:7897 
ENV HTTP_PROXY=http://host.docker.internal:7897 
ENV ALL_PROXY=socks5://host.docker.internal:7897 

RUN apt-get update && apt-get install -y \
    build-essential \
    libncurses-dev \
    bc \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    wget \
    xz-utils \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

CMD ["tail", "-f", "/dev/null"]
EOF

echo "[Okay] Dockerfile build successfully!"

# Step3. build docker image

docker build -t linux-kernel-builder .


# Step4. get linux source
if [ ! -d "linux-6.1" ]; then
    echo "download linux(v6.1) source code"
    wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.tar.xz && tar -xf linux-6.1.tar.xz && rm linux-6.1.tar.xz
fi


docker run --rm \
    -v $(pwd):/host \
    -w /host/linux-6.1 \
    linux-kernel-builder \
    bash -c "make defconfig && make -j\$(nproc)"


echo "linux kernel image in ./linux-6.1/arch/x86/boot/bzImage!"

# start build driver

docker run --rm \
    -v $(pwd):/host \
    -w /host/drivers \
    linux-kernel-builder \
    make