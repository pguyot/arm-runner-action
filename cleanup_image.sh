#!/bin/bash
set -uo pipefail

loopdev=$1
mount=$2

mv "${mount}/etc/_ld.so.preload" "${mount}/etc/ld.so.preload"

[[ -f "${mount}/tmp/commands.sh" ]] && rm "${mount}/tmp/commands.sh"
if [[ -d "${mount}" ]]; then
    umount "${mount}/dev/pts" || true
    umount "${mount}/dev" || true
    umount "${mount}/proc" || true
    umount "${mount}/sys" || true
    umount "${mount}/boot" || true
    umount "${mount}" || true
    rmdir "${mount}" || true
fi
[ -n "${loopdev:-}" ] && losetup --detach "${loopdev}" || true
