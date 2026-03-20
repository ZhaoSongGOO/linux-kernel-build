#!/bin/bash
set -e

echo "=== Build BusyBox in Mac ==="

# Step1. check if install docker
echo "=== Step1. check if install docker ==="
if ! command -v docker &> /dev/null; then
    echo "error: docker not installed!"
    echo "Please visit https://www.docker.com/"
    exit 1
fi

# Step2. build docker image



# Step4. download busybox source code

echo "=== check busybox(v1.36.0) source code ==="
if [ ! -d "busybox-1.36.0" ]; then
    echo "download busybox(v1.36.0) source code"
    wget https://busybox.net/downloads/busybox-1.36.0.tar.bz2 && tar -xf busybox-1.36.0.tar.bz2 && rm busybox-1.36.0.tar.bz2
fi

echo "=== build system services  ==="
# build system services
docker run --rm \
    -v $(pwd):/host \
    busybox-builder \
    bash -c "cd /host/services && \
            make"


echo "=== build busybox and fs ==="
docker run --rm \
    -v $(pwd):/host \
    busybox-builder \
    bash -c "cd /host/busybox-1.36.0 && \
            make defconfig && \
            sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config && \
            make -j\$(nproc) && make install && \
            mkdir -p _install/{bin,sbin,etc,proc,sys,dev,usr/bin,usr/sbin,lib/modules,lib64,var/log} && \
            cp -r _install /build && cd /build/ && \
            cd _install && \
            cp /host/res/init . && \
            cp /host/res/inittab ./etc && \
            mkdir -p ./etc/init.d && cp /host/res/init.d/rcS ./etc/init.d && \
            cp /host/services/out/hello ./bin && chmod +x ./bin/hello && \
            cp /host/drivers/hello_driver.ko ./lib/modules && \
            chmod +x ./init && \
            chmod +x ./etc/init.d/rcS && \
            mknod ./dev/console c 5 1 && \
            mknod ./dev/null c 1 3 && \
            mknod ./dev/tty c 5 0 && \
            find . | cpio -o -H newc | gzip > /host/initramfs.cpio.gz"
