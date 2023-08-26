#!/bin/bash
set -uo pipefail

image=$1
additional_mb=$2
use_systemd_nspawn=$3
rootpartition=$4

if [ $# -ge 5 ]; then
    bootpartition=$5
    if [ "x$rootpartition" = "x$bootpartition" ]; then
        echo "Boot partition cannot be equal to root partition"
        if [ "x$bootpartition" = "x1" ]; then
            echo "Forgot to unset bootpartition ?"
        fi
        exit 1
    fi
else
    bootpartition=
fi

if [ ${additional_mb} -gt 0 ]; then
    dd if=/dev/zero bs=1M count=${additional_mb} >> ${image}
fi

loopdev=$(losetup --find --show --partscan ${image})
echo "Created loopback device ${loopdev}"
echo "loopdev=${loopdev}" >> "$GITHUB_OUTPUT"

if [ ${additional_mb} -gt 0 ]; then
    if ( (parted --script $loopdev print || false) | grep "Partition Table: gpt" > /dev/null); then
        sgdisk -e "${loopdev}"
    fi
    parted --script "${loopdev}" resizepart ${rootpartition} 100%
    e2fsck -p -f "${loopdev}p${rootpartition}"
    resize2fs "${loopdev}p${rootpartition}"
    echo "Finished resizing disk image."
fi

waitForFile() {
    maxRetries=60
    retries=0
    until [ -n "$(compgen -G "$1")" ] ; do
        retries=$((retries + 1))
        if [ $retries -ge $maxRetries ] ; then
            echo "Could not find $1 within $maxRetries seconds" >&2
            return 1
        fi
        sleep 1
    done
    compgen -G "$1"
}

sync
partprobe -s "${loopdev}"
if [ "x$bootpartition" != "x" ]; then
    bootdev=$(waitForFile "${loopdev}p${bootpartition}")
else
    bootdev=
fi
rootdev=$(waitForFile "${loopdev}p${rootpartition}")

# Mount the image
mount=${RUNNER_TEMP:-/home/actions/temp}/arm-runner/mnt
mkdir -p ${mount}
echo "mount=${mount}" >> "$GITHUB_OUTPUT"
[ ! -d "${mount}" ] && mkdir "${mount}"
mount "${rootdev}" "${mount}"
if [ "x${bootdev}" != "x" ]; then
    [ ! -d "${mount}/boot" ] && mkdir "${mount}/boot"
    mount "${bootdev}" "${mount}/boot"
fi

# Prep the chroot
if [ "${use_systemd_nspawn}x" = "x" -o "${use_systemd_nspawn}x" = "nox" ]; then
    mount --bind /proc "${mount}/proc"
    mount --bind /sys "${mount}/sys"
    mount --bind /dev "${mount}/dev"
    mount --bind /dev/pts "${mount}/dev/pts"
fi

mv "${mount}/etc/resolv.conf" "${mount}/etc/_resolv.conf"
cp /etc/resolv.conf "${mount}/etc/resolv.conf"
cp /usr/bin/qemu-arm-static0 ${mount}/usr/bin/qemu-arm-static0
cp /usr/bin/qemu-arm-static ${mount}/usr/bin/qemu-arm-static
cp /usr/bin/qemu-aarch64-static0 ${mount}/usr/bin/qemu-aarch64-static0
cp /usr/bin/qemu-aarch64-static ${mount}/usr/bin/qemu-aarch64-static
if [ -e "${mount}/etc/ld.so.preload" ]; then
    cp "${mount}/etc/ld.so.preload" "${mount}/etc/_ld.so.preload"
    echo > "${mount}/etc/ld.so.preload"
fi
