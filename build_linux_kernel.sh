#!/bin/bash
source ./env.sh

set -e

echo "=== Build Linux Kernel in Mac ==="

# Step1. check if install docker
echo "=== Step1. check if install docker ==="
if ! command -v docker &> /dev/null; then
    echo "error: docker not installed!"
    echo "Please visit https://www.docker.com/"
    exit 1
fi


# # Step4. get linux source
if [ ! -d "${LINUX_KERNEL_VERSION}" ]; then
    echo "download linux(v${LINUX_KERNEL_VERSION}) source code"
    wget ${LINUX_KERNEL_DOWNLOAD_URL}
    tar -xf ${LINUX_KERNEL_VERSION}.tar.xz && rm ${LINUX_KERNEL_VERSION}.tar.xz
fi


echo "=== Start linux kernel build... ==="

docker run --rm \
    -v $(pwd):/host \
    -w /host/${LINUX_KERNEL_VERSION} \
    linux-kernel-builder \
    bash -c "make defconfig && make -j\$(nproc)"


echo "linux kernel image in ./${LINUX_KERNEL_VERSION}/arch/x86/boot/bzImage!"

# start build driver

docker run --rm \
    -v $(pwd):/host \
    -w /host/drivers \
    linux-kernel-builder \
    make