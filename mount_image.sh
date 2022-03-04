#!/bin/bash
set -uo pipefail

image=$1
additional_mb=$2

if [ ${additional_mb} -gt 0 ]; then
    dd if=/dev/zero bs=1M count=${additional_mb} >> ${image}
fi

loopdev=$(losetup --find --show --partscan ${image})
echo "Created loopback device ${loopdev}"
echo "::set-output name=loopdev::${loopdev}"

if [ ${additional_mb} -gt 0 ]; then
    if ( (parted --script $loopdev print || false) | grep "Partition Table: gpt" > /dev/null); then
        sgdisk -e "${loopdev}"
    fi
    parted --script "${loopdev}" resizepart 2 100%
    e2fsck -p -f "${loopdev}p2"
    resize2fs "${loopdev}p2"
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
bootdev=$(waitForFile "${loopdev}*1")
rootdev=$(waitForFile "${loopdev}*2")

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
mount --bind /dev "${mount}/dev"
mount --bind /dev/pts "${mount}/dev/pts"

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
