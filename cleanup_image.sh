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

    for mp in "${mount}/dev/pts" "${mount}/dev" "${mount}/proc" "${mount}/sys" "${mount}/boot" "${mount}" ; do
        mountpoint "${mp}" && {
            retries=0
            force=""
            while ! umount ${force} "${mp}" ; do
                retries=$((retries + 1))
                if [ "${retries}" -ge 10 ]; then
                    echo "Could not unmount ${mp} after ${retries} attempts, giving up."
                    exit 1
                fi
                if [ "${retries}" -eq 5 ]; then
                    force="--force"
                fi
                fuser -ckv "${mp}"
                sleep 1
            done
        }
    done

    if [[ "${optimize}x" == "x" || "${optimize}x" == "yesx" ]]; then
        rootfs_partnum=${rootpartition}
        rootdev="${loopdev}p${rootfs_partnum}"
        
        part_type=$(blkid -o value -s PTTYPE "${loopdev}")
        echo "Image is using ${part_type} partition table"

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
            echo y | sudo parted ---pretend-input-tty "${loopdev}" unit B resizepart "${rootfs_partnum}" "${rootfs_partend}"
        else
            echo "Rootfs partition not resized as it was not shrunk"
        fi

        free_space=$(parted -m --script "${loopdev}" unit B print free | tail -1)
        if [[ "${free_space}" =~ "free" ]]; then
            initial_image_size=$(stat -L --printf="%s" "${image}")
            image_size=$(echo "${free_space}" | awk -F ":" '{print $2}' | tr -d 'B')
            if [[ "${part_type}" == "gpt" ]]; then
                # for GPT partition table, leave space at the end for the secondary GPT 
                # it requires 33 sectors, which is 16896 bytes
                image_size=$((${image_size} + 16896))
            fi            
            echo "Shrinking image from ${initial_image_size} to ${image_size} bytes."
            truncate -s "${image_size}" "${image}"
            if [[ "${part_type}" == "gpt" ]]; then
                # use sgdisk to fix the secondary GPT after truncation 
                sgdisk -e "${image}"
            fi
        fi
    fi
    rmdir "${mount}" || true
fi
[ -n "${loopdev:-}" ] && losetup --detach "${loopdev}" || true
