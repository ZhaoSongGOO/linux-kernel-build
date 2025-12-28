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

# Step2. edit dockerfile

cat > Dockerfile.busybox << 'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV HTTPS_PROXY=http://host.docker.internal:7897 
ENV HTTP_PROXY=http://host.docker.internal:7897 
ENV ALL_PROXY=socks5://host.docker.internal:7897 

RUN apt-get update && apt-get install -y \
    build-essential \
    bzip2 \
    wget \
    cpio \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

EOF

echo "[Okay] Dockerfile.busybox build successfully!"

# Step3. build docker image

docker build -f Dockerfile.busybox -t busybox-builder .

# Step4. download busybox source code

if [ ! -d "busybox-1.36.0" ]; then
    echo "download busybox(v1.36.0) source code"
    wget https://busybox.net/downloads/busybox-1.36.0.tar.bz2 && tar -xf busybox-1.36.0.tar.bz2 && rm busybox-1.36.0.tar.bz2
fi

# Step5. build busybox

# echo "=== build rootfs ==="
# mkdir -p rootfs/{bin,sbin,etc,proc,sys,dev,usr/bin,usr/sbin,lib,lib64}

# cp -r busybox-1.36.0/_install/* rootfs/

# cat > rootfs/init << 'EOF'
# #!/bin/sh
# echo "Starting custom Linux system..."

# mount -t proc proc /proc
# mount -t sysfs sysfs /sys
# mount -t devtmpfs devtmpfs /dev
# export PATH=/bin:/sbin:/usr/bin:/usr/sbin
# exec /bin/sh
# EOF

# chmod +x rootfs/init

# mkdir -p rootfs/etc/init.d
# cat > rootfs/etc/inittab << 'EOF'
# ::sysinit:/etc/init.d/rcs
# ::askfirst:-/bin/sh
# ::ctrlaltdel:/sbin/reboot
# EOF

# cat > rootfs/etc/init.d/rcS << 'EOF'
# #!/bin/sh
# echo "Running system initialization..."
# mount -t proc proc /proc
# mount -t sysfs sysfs /sys
# mount -t devtmpfs devtmpfs /dev
# hostname Sos
# echo "Initialization complete."
# EOF

# chmod +x rootfs/etc/init.d/rcS

# build system services
docker run --rm \
    -v $(pwd):/host \
    busybox-builder \
    bash -c "cd /host/services && \
            make"


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
