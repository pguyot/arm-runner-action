#!/bin/bash
set -uo pipefail

image=$1
additional_mb=$2
use_systemd_nspawn=$3

if [ ${additional_mb} -gt 0 ]; then
    dd if=/dev/zero bs=1M count=${additional_mb} >> ${image}
fi

loopdev=$(losetup --find --show ${image})
echo "Created loopback device ${loopdev}"
echo "::set-output name=loopdev::${loopdev}"

if [ ${additional_mb} -gt 0 ]; then
    parted --script "${loopdev}" resizepart 2 100%
    e2fsck -p -f "${loopdev}p2"
    resize2fs "${loopdev}p2"
    echo "Finished resizing disk image."
fi

partprobe "${loopdev}"
bootdev=$(ls "${loopdev}"*1)
rootdev=$(ls "${loopdev}"*2)

# Mount the image
mount=${RUNNER_TEMP:-/home/actions/temp}/arm-runner/mnt
mkdir -p ${mount}
echo "::set-output name=mount::${mount}"
[ ! -d "${mount}" ] && mkdir "${mount}"
mount "${rootdev}" "${mount}"
[ ! -d "${mount}/boot" ] && mkdir "${mount}/boot"
mount "${bootdev}" "${mount}/boot"

# Prep the chroot
mount --bind /proc "${mount}/proc"
mount --bind /sys "${mount}/sys"
if [ "${use_systemd_nspawn}x" = "x" -o "${use_systemd_nspawn}x" = "nox" ]; then
    mount --bind /dev "${mount}/dev"
    mount --bind /dev/pts "${mount}/dev/pts"
fi

cp "${mount}/etc/resolv.conf" "${mount}/etc/_resolv.conf"
cp /etc/resolv.conf "${mount}/etc/resolv.conf"
cp /usr/bin/qemu-arm-static0 ${mount}/usr/bin/qemu-arm-static0
cp /usr/bin/qemu-arm-static ${mount}/usr/bin/qemu-arm-static
cp /usr/bin/qemu-aarch64-static0 ${mount}/usr/bin/qemu-aarch64-static0
cp /usr/bin/qemu-aarch64-static ${mount}/usr/bin/qemu-aarch64-static
if [ -e "${mount}/etc/ld.so.preload" ]; then
    cp "${mount}/etc/ld.so.preload" "${mount}/etc/_ld.so.preload"
    echo > "${mount}/etc/ld.so.preload"
fi
