#!/bin/bash
set -e

echo "=== Run QEMU in Mac ==="

if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Install QEMU..."
    brew install qemu
fi

if [ ! -f "linux-6.1/arch/x86/boot/bzImage" ]; then
    echo "[Err] Linux kernel not found , please run build_linux_kernel.sh"
    exit 1
fi

if [ ! -f "initramfs.cpio.gz" ]; then
    echo "[Err] Root file system not found , please run build_busybox.sh"
    exit 1
fi

echo "=== Run QEMU ==="

qemu-system-x86_64 \
    -m 1024 \
    -kernel linux-6.1/arch/x86/boot/bzImage\
    -initrd initramfs.cpio.gz \
    -append "console=ttyS0 root=/dev/ram rdinit=/init" \
    -nographic