#!/bin/bash
set -uo pipefail

case $1 in
    # Raspbian lite
    "raspbian_lite:latest")
        url=https://downloads.raspberrypi.org/raspbian_lite_latest
    ;;
    "raspbian_lite:2020-02-13")
        url=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
    ;;
    # RaspiOS lite
    "raspios_lite:latest")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf_latest
    ;;
    "raspios_lite:2021-03-04")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-03-25/2021-03-04-raspios-buster-armhf-lite.zip
    ;;
    "raspios_lite:2021-05-07")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
    ;;
    "raspios_lite:2021-10-30")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf-lite.zip
    ;;
    "raspios_lite:2022-01-28")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip
    ;;
    "raspios_lite:2022-04-04")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-04-07/2022-04-04-raspios-bullseye-armhf-lite.img.xz
    ;;
    "raspios_lite:2023-05-03")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf-lite.img.xz
    ;;
    "raspios_lite:2023-12-11")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2023-12-11/2023-12-11-raspios-bookworm-armhf-lite.img.xz
    ;;
    "raspios_lite:2024-03-15")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2024-03-15/2024-03-15-raspios-bookworm-armhf-lite.img.xz
    ;;
    "raspios_lite:2024-07-04")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf-lite.img.xz
    ;;
    "raspios_lite:2024-10-22")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2024-10-28/2024-10-22-raspios-bookworm-armhf-lite.img.xz
    ;;
    "raspios_lite:2025-05-13")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2025-05-13/2025-05-13-raspios-bookworm-armhf-lite.img.xz
    ;;
    "raspios_lite:2025-12-04")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2025-12-04/2025-12-04-raspios-trixie-armhf-lite.img.xz
    ;;
    "raspios_lite:2026-04-21")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2026-04-21/2026-04-21-raspios-trixie-armhf-lite.img.xz
    ;;
    # RaspiOS oldstable lite
    "raspios_oldstable_lite:2023-05-03")
        url=https://downloads.raspberrypi.org/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2023-05-03/2023-05-03-raspios-buster-armhf-lite.img.xz
    ;;
    "raspios_oldstable_lite:2025-05-07")
        url=https://downloads.raspberrypi.com/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2025-05-07/2025-05-06-raspios-bullseye-armhf-lite.img.xz
    ;;
    "raspios_oldstable_lite:2026-04-14")
        url=https://downloads.raspberrypi.com/raspios_oldstable_lite_armhf/images/raspios_oldstable_lite_armhf-2026-04-14/2026-04-13-raspios-bookworm-armhf-lite.img.xz
    ;;
    # RaspiOS lite arm64
    "raspios_lite_arm64:latest")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64_latest
    ;;
    "raspios_lite_arm64:2022-01-28")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-01-28/2022-01-28-raspios-bullseye-arm64-lite.zip
    ;;
    "raspios_lite_arm64:2022-04-04")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-04-07/2022-04-04-raspios-bullseye-arm64-lite.img.xz
    ;;
    "raspios_lite_arm64:2023-05-03")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz
    ;;
    "raspios_lite_arm64:2023-12-11")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-12-11/2023-12-11-raspios-bookworm-arm64-lite.img.xz
    ;;
    "raspios_lite_arm64:2024-03-15")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-03-15/2024-03-15-raspios-bookworm-arm64-lite.img.xz
    ;;
    "raspios_lite_arm64:2024-07-04")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz
    ;;
    "raspios_lite_arm64:2024-10-22")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-10-28/2024-10-22-raspios-bookworm-arm64-lite.img.xz
    ;;
    "raspios_lite_arm64:2025-05-13")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2025-05-13/2025-05-13-raspios-bookworm-arm64-lite.img.xz
    ;;
    "raspios_lite_arm64:2025-12-04")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2025-12-04/2025-12-04-raspios-trixie-arm64-lite.img.xz
    ;;
    "raspios_lite_arm64:2026-04-21")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2026-04-21/2026-04-21-raspios-trixie-arm64-lite.img.xz
    ;;
    # RaspiOS oldstable lite arm64
    "raspios_oldstable_lite_arm64:2025-05-07")
        url=https://downloads.raspberrypi.com/raspios_oldstable_lite_arm64/images/raspios_oldstable_lite_arm64-2025-05-07/2025-05-06-raspios-bullseye-arm64-lite.img.xz
    ;;
    "raspios_oldstable_lite_arm64:2026-04-14")
        url=https://downloads.raspberrypi.com/raspios_oldstable_lite_arm64/images/raspios_oldstable_lite_arm64-2026-04-14/2026-04-13-raspios-bookworm-arm64-lite.img.xz
    ;;
    # DietPi
    "dietpi:rpi_armv6_bookworm")
        url=https://dietpi.com/downloads/images/DietPi_RPi1-ARMv6-Bookworm.img.xz
    ;;
    "dietpi:rpi_armv7_bookworm")
        url=https://dietpi.com/downloads/images/DietPi_RPi2-ARMv7-Bookworm.img.xz
    ;;
    "dietpi:rpi_armv8_bookworm")
        url=https://dietpi.com/downloads/images/DietPi_RPi234-ARMv8-Bookworm.img.xz
    ;;
    "dietpi:rpi5_armv8_bookworm")
        url=https://dietpi.com/downloads/images/DietPi_RPi5-ARMv8-Bookworm.img.xz
    ;;
    "dietpi:rpi_armv6_trixie")
        url=https://dietpi.com/downloads/images/DietPi_RPi1-ARMv6-Trixie.img.xz
    ;;
    "dietpi:rpi_armv7_trixie")
        url=https://dietpi.com/downloads/images/DietPi_RPi2-ARMv7-Trixie.img.xz
    ;;
    "dietpi:rpi_armv8_trixie")
        url=https://dietpi.com/downloads/images/DietPi_RPi234-ARMv8-Trixie.img.xz
    ;;
    "dietpi:rpi5_armv8_trixie")
        url=https://dietpi.com/downloads/images/DietPi_RPi5-ARMv8-Trixie.img.xz
    ;;
    "dietpi:rpi_armv6_forky")
        url=https://dietpi.com/downloads/images/DietPi_RPi1-ARMv6-Forky.img.xz
    ;;
    "dietpi:rpi_armv7_forky")
        url=https://dietpi.com/downloads/images/DietPi_RPi2-ARMv7-Forky.img.xz
    ;;
    "dietpi:rpi_armv8_forky")
        url=https://dietpi.com/downloads/images/DietPi_RPi234-ARMv8-Forky.img.xz
    ;;
    "dietpi:rpi5_armv8_forky")
        url=https://dietpi.com/downloads/images/DietPi_RPi5-ARMv8-Forky.img.xz
    ;;
    # Debian
    "raspi_1_bullseye:20220121")
        url=https://raspi.debian.net/tested/20220121_raspi_1_bullseye.img.xz
    ;;
    "raspi_1_bookworm:20231109")
        url=https://raspi.debian.net/tested/20231109_raspi_1_bookworm.img.xz
    ;;
    "raspi_2_bullseye:20230102")
        url=https://raspi.debian.net/tested/20230102_raspi_2_bullseye.img.xz
    ;;
    "raspi_2_bookworm:20231109")
        url=https://raspi.debian.net/tested/20231109_raspi_2_bookworm.img.xz
    ;;
    "raspi_3_bullseye:20230102")
        url=https://raspi.debian.net/tested/20230102_raspi_3_bullseye.img.xz
    ;;
    "raspi_3_bookworm:20231109")
        url=https://raspi.debian.net/tested/20231109_raspi_3_bookworm.img.xz
    ;;
    "raspi_4_bullseye:20230102")
        url=https://raspi.debian.net/tested/20230102_raspi_4_bullseye.img.xz
    ;;
    "raspi_4_bookworm:20231109")
        url=https://raspi.debian.net/tested/20231109_raspi_4_bookworm.img.xz
    ;;
    # Custom URL
    https:/*|http:/*)
        url="$1"
    ;;
    file:///*|file://localhost/*)
        url="$1"
    ;;
    *)
        echo "Unknown image $1"
        exit 1
    ;;
esac

tempdir=${RUNNER_TEMP:-/home/actions/temp}/arm-runner
rm -rf ${tempdir}
mkdir -p ${tempdir}
cd ${tempdir}
case ${url} in
    file://localhost/*)
        cp "${url#file://localhost}" .
    ;;
    file:///*)
        cp "${url#file://}" .
    ;;
    https:/*|http:/*)
        wget --trust-server-names --content-disposition -q ${url}
esac
case `echo *` in
    *.zip)
        unzip -u *
    ;;
    *.7z)
        7zr e *
    ;;
    *.xz)
        xz -d *
    ;;
    *.gz)
        gzip -d *
    ;;
    *.img)
    ;;
    *.zip\?*)
        unzip -u *
    ;;
    *.7z\?*)
        7zr e *
    ;;
    *.xz\?*)
        xz -d *
    ;;
    *.gz\?*)
        gzip -d *
    ;;
    *)
        echo "Don't know how to uncompress image " *
        exit 1
esac
mv "$(ls *.img */*.img 2>/dev/null | head -n 1)" arm-runner.img
echo "image=${tempdir}/arm-runner.img" >> "$GITHUB_OUTPUT"
