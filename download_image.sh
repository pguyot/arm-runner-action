#!/bin/bash
set -uo pipefail

case $1 in
    "raspbian_lite:latest")
        url=https://downloads.raspberrypi.org/raspbian_lite_latest
    ;;
    "raspios_lite:latest")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf_latest
    ;;
    "raspios_lite_arm64:latest")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64_latest
    ;;
    "raspbian_lite:2020-02-13")
        url=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
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
    "raspios_lite_arm64:2022-01-28")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-01-28/2022-01-28-raspios-bullseye-arm64-lite.zip
    ;;
    "raspios_lite_arm64:2022-04-04")
        url=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-04-07/2022-04-04-raspios-bullseye-arm64-lite.img.xz
    ;;
    "dietpi:rpi_armv6_bullseye")
        url=https://dietpi.com/downloads/images/DietPi_RPi-ARMv6-Bullseye.7z
    ;;
    "dietpi:rpi_armv7_bullseye")
        url=https://dietpi.com/downloads/images/DietPi_RPi-ARMv7-Bullseye.7z
    ;;
    "dietpi:rpi_armv8_bullseye")
        url=https://dietpi.com/downloads/images/DietPi_RPi-ARMv8-Bullseye.7z
    ;;
    "raspi_1_bullseye:20220121")
        url=https://raspi.debian.net/tested/20220121_raspi_1_bullseye.img.xz
    ;;
    "raspi_2_bullseye:20230102")
        url=https://raspi.debian.net/tested/20230102_raspi_2_bullseye.img.xz
    ;;
    "raspi_3_bullseye:20230102")
        url=https://raspi.debian.net/tested/20230102_raspi_3_bullseye.img.xz
    ;;
    "raspi_4_bullseye:20230102")
        url=https://raspi.debian.net/tested/20230102_raspi_4_bullseye.img.xz
    ;;
    https:/*|http:/*)
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
wget --trust-server-names --content-disposition -q ${url}
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
