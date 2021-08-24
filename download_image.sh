#!/bin/bash
set -uo pipefail

case $1 in
    "raspbian_lite:2020-02-13")
        url=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
    ;;
    "raspios_lite:2021-03-04")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-03-25/2021-03-04-raspios-buster-armhf-lite.zip
    ;;
    "raspios_lite:2021-05-07")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip
    ;;
    "dietpi:rpi_armv6_buster")
        url=https://dietpi.com/downloads/images/DietPi_RPi-ARMv6-Buster.7z
    ;;
    https:/*|http:/*)
        url="$1"
    ;;
    *)
        echo "Unknown image $1"
        exit 1
    ;;
esac

case $url in
    *.zip)
        uncompress="unzip -u"
    ;;
    *.7z)
        uncompress="7zr e"
    ;;
esac

filename=`basename ${url}`
tempdir=${RUNNER_TEMP:-/home/actions/temp}/arm-runner
mkdir -p ${tempdir}
cd ${tempdir}
wget -q ${url}
${uncompress} ${filename}
mv "$(ls *.img */*.img 2>/dev/null | head -n 1)" arm-runner.img
echo "::set-output name=image::${tempdir}/arm-runner.img"
