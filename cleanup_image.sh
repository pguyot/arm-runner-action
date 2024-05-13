#!/bin/bash
set -euxo pipefail

loopdev=$1
mount=$2
image=$3
optimize=$4
rootpartition=$5

rm "${mount}/usr/bin/qemu-arm-static0"
rm "${mount}/usr/bin/qemu-arm-static"
rm "${mount}/usr/bin/qemu-aarch64-static0"
rm "${mount}/usr/bin/qemu-aarch64-static"
[ -e "${mount}/etc/_ld.so.preload" ] && mv "${mount}/etc/_ld.so.preload" "${mount}/etc/ld.so.preload"
[ -e "${mount}/etc/_resolv.conf" ] && mv "${mount}/etc/_resolv.conf" "${mount}/etc/resolv.conf"

[[ -f "${mount}/tmp/commands.sh" ]] && rm "${mount}/tmp/commands.sh"
if [[ -d "${mount}" ]]; then

    if [[ "${optimize}x" == "x" || "${optimize}x" == "yesx" ]]; then
        if [[ -d "${mount}/boot" ]]; then
            echo "Zero-filling unused blocks on boot filesystem..."
            (cat /dev/zero >"${mount}/boot/zero.fill" 2>/dev/null || true); sync; rm -f "${mount}/boot/zero.fill"
        fi
        echo "Zero-filling unused blocks on root filesystem..."
        (cat /dev/zero >"${mount}/zero.fill" 2>/dev/null || true); sync; rm -f "${mount}/zero.fill"
    fi

    umount "${mount}/dev/pts" || fuser -ckv "${mount}/dev/pts" || umount --force --lazy "${mount}/dev/pts" || true
    umount "${mount}/dev" || fuser -ckv "${mount}/dev" || umount --force --lazy "${mount}/dev" || true
    umount "${mount}/proc" || fuser -ckv "${mount}/proc" || umount --force --lazy "${mount}/proc" || true
    umount "${mount}/sys" || fuser -ckv "${mount}/sys" || umount --force --lazy "${mount}/sys" || true
    umount "${mount}/boot" || fuser -ckv "${mount}/boot" || umount --force --lazy "${mount}/boot" || true
    umount "${mount}" || fuser -ckv "${mount}" || umount --force --lazy "${mount}" || true

    if [[ "${optimize}x" == "x" || "${optimize}x" == "yesx" ]]; then
        rootfs_partnum=${rootpartition}
        rootdev="${loopdev}p${rootfs_partnum}"

        echo "Resizing root filesystem to minimal size."
        e2fsck -p -f "${rootdev}"
        resize2fs -M "${rootdev}"
        rootfs_blocksize=$(tune2fs -l ${rootdev} | grep "^Block size" | awk '{print $NF}')
        rootfs_blockcount=$(tune2fs -l ${rootdev} | grep "^Block count" | awk '{print $NF}')

        echo "Resizing rootfs partition."
        rootfs_partstart=$(parted -m --script "${loopdev}" unit B print | grep "^${rootfs_partnum}:" | awk -F ":" '{print $2}' | tr -d 'B')
        rootfs_partsize=$((${rootfs_blockcount} * ${rootfs_blocksize}))
        rootfs_partend=$((${rootfs_partstart} + ${rootfs_partsize} - 1))
        rootfs_partoldend=$(parted -m --script "${loopdev}" unit B print | grep "^${rootfs_partnum}:" | awk -F ":" '{print $3}' | tr -d 'B')
        # parted --script "${loopdev}" unit B resizepart "${rootfs_partnum}" "${rootfs_partend}"
        # Can't use resizepart for shrinking with --script (parted bug#22167) => must rm then mkpart
        if [ "$rootfs_partoldend" -gt "$rootfs_partend" ]; then
            parted --script "${loopdev}" rm "${rootfs_partnum}"
            parted --script "${loopdev}" unit B mkpart primary "${rootfs_partstart}" "${rootfs_partend}"
        else
            echo "Rootfs partition not resized as it was not shrunk"
        fi

        free_space=$(parted -m --script "${loopdev}" unit B print free | tail -1)
        if [[ "${free_space}" =~ "free" ]]; then
            initial_image_size=$(stat -L --printf="%s" "${image}")
            image_size=$(echo "${free_space}" | awk -F ":" '{print $2}' | tr -d 'B')
            echo "Shrinking image from ${initial_image_size} to ${image_size} bytes."
            truncate -s "${image_size}" "${image}"
        fi
    fi
    rmdir "${mount}" || true
fi
[ -n "${loopdev:-}" ] && losetup --detach "${loopdev}" || true
