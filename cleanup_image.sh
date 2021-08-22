#!/bin/bash
set -uo pipefail

loopdev=$1
mount=$2
image=$3
optimize=$4

rm "${mount}/usr/bin/qemu-arm-static0"
rm "${mount}/usr/bin/qemu-arm-static"
mv "${mount}/etc/_ld.so.preload" "${mount}/etc/ld.so.preload"
mv "${mount}/etc/_resolv.conf" "${mount}/etc/resolv.conf"

[[ -f "${mount}/tmp/commands.sh" ]] && rm "${mount}/tmp/commands.sh"
if [[ -d "${mount}" ]]; then

    if [[ "${optimize}x" == "x" || "${optimize}x" == "yesx" ]]; then
        if [[ -d "${mount}/boot" ]]; then
            echo "Zero-filling unused blocks on boot filesystem..."
            cat /dev/zero >"${mount}/boot/zero.fill" 2>/dev/null; sync; rm -f "${mount}/boot/zero.fill"
        fi
        echo "Zero-filling unused blocks on root filesystem..."
        cat /dev/zero >"${mount}/zero.fill" 2>/dev/null; sync; rm -f "${mount}/zero.fill"
    fi

    umount "${mount}/dev/pts" || true
    umount "${mount}/dev" || true
    umount "${mount}/proc" || true
    umount "${mount}/sys" || true
    umount "${mount}/boot" || true
    umount "${mount}" || true

    if [[ "${optimize}x" == "x" || "${optimize}x" == "yesx" ]]; then
        rootfs_partnum=2
        rootdev=$(ls "${loopdev}"*${rootfs_partnum})

        echo "Resizing root filesystem to minimal size."
        e2fsck -p -f "${rootdev}"
        resize2fs -M "${rootdev}"
        rootfs_blocksize=$(tune2fs -l ${rootdev} | grep "^Block size" | awk '{print $NF}')
        rootfs_blockcount=$(tune2fs -l ${rootdev} | grep "^Block count" | awk '{print $NF}')

        echo "Resizing rootfs partition."
        rootfs_partstart=$(parted -m --script "${loopdev}" unit B print | grep "^${rootfs_partnum}:" | awk -F ":" '{print $2}' | tr -d 'B')
        rootfs_partsize=$((${rootfs_blockcount} * ${rootfs_blocksize}))
        rootfs_partend=$((${rootfs_partstart} + ${rootfs_partsize}))
        # parted --script "${loopdev}" unit B resizepart "${rootfs_partnum}" "${rootfs_partend}"
        # Can't use resizepart for shrinking with --script (parted bug#22167) => must rm then mkpart
        parted --script "${loopdev}" rm "${rootfs_partnum}"
        parted --script "${loopdev}" unit B mkpart primary "${rootfs_partstart}" "${rootfs_partend}"

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
