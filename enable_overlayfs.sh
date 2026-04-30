#!/bin/bash
# Enable Raspberry Pi OverlayFS root in a mounted image.
#
# raspi-config's do_overlayfs uses `update-initramfs -c -k "$(uname -r)"`,
# but under qemu-user chroot `uname -r` returns the host kernel, so the
# command fails silently and the image ships without /boot/initrd.img.
# This script regenerates the initramfs against the image's actual kernel
# and ensures cmdline.txt / config.txt are set up for overlay boot.
set -euxo pipefail

mount=$1

kver=$(ls "${mount}/lib/modules" 2>/dev/null | sort -V | tail -n1 || true)
if [ -z "${kver}" ]; then
    echo "enable_overlayfs: no kernel found under ${mount}/lib/modules/" >&2
    echo "enable_overlayfs requires an image with a kernel installed (e.g. Raspberry Pi OS)." >&2
    exit 1
fi
echo "enable_overlayfs: detected image kernel ${kver}"

chroot "${mount}" sh -c '
    set -e
    if ! command -v overlayroot-chroot >/dev/null 2>&1; then
        DEBIAN_FRONTEND=noninteractive apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y overlayroot
    fi
'

# Use mkinitramfs directly rather than update-initramfs: the
# z50-raspi-firmware post-update hook copies to /boot/firmware/, which does
# not exist in this mount layout (the FAT firmware partition is mounted at
# ${mount}/boot, not ${mount}/boot/firmware). We place the file ourselves.
chroot "${mount}" mkinitramfs -o "/boot/initrd.img-${kver}" "${kver}"

cp -f "${mount}/boot/initrd.img-${kver}" "${mount}/boot/initrd.img"

cmdline="${mount}/boot/cmdline.txt"
if [ -f "${cmdline}" ] && ! grep -q "boot=overlay" "${cmdline}"; then
    sed -i 's/[[:space:]]*$/ boot=overlay/' "${cmdline}"
fi

config="${mount}/boot/config.txt"
if [ -f "${config}" ] && ! grep -q "^initramfs initrd.img followkernel" "${config}"; then
    printf '\ninitramfs initrd.img followkernel\n' >> "${config}"
fi
