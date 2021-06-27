#!/bin/bash
set -uo pipefail

loopdev=$1
mount=$2
optimize=$3

rm "${mount}/usr/bin/qemu-arm-static0"
rm "${mount}/usr/bin/qemu-arm-static"
mv "${mount}/etc/_ld.so.preload" "${mount}/etc/ld.so.preload"
mv "${mount}/etc/_resolv.conf" "${mount}/etc/resolv.conf"

[[ -f "${mount}/tmp/commands.sh" ]] && rm "${mount}/tmp/commands.sh"
if [[ -d "${mount}" ]]; then
    if [[ "${optimize}x" == "x" || "${optimize}x" == "yesx" ]]; then
        if [[ -d "${mount}/boot" ]]; then
            echo "Zero-filling unused blocks on /boot filesystem..."
            cat /dev/zero >"${mount}/boot/zero.fill" 2>/dev/null; sync; rm -f "${mount}/boot/zero.fill"
        fi
        echo "Zero-filling unused blocks on / filesystem..."
        cat /dev/zero >"${mount}/zero.fill" 2>/dev/null; sync; rm -f "${mount}/zero.fill"
    fi
    umount "${mount}/dev/pts" || true
    umount "${mount}/dev" || true
    umount "${mount}/proc" || true
    umount "${mount}/sys" || true
    umount "${mount}/boot" || true
    umount "${mount}" || true
    rmdir "${mount}" || true
fi
[ -n "${loopdev:-}" ] && losetup --detach "${loopdev}" || true
