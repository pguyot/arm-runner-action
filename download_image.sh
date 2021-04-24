#!/bin/bash
set -uo pipefail

case $1 in
    "raspbian_lite:2020-02-13")
        url=https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
    ;;
    "raspios_lite:2021-03-04")
        url=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-03-25/2021-03-04-raspios-buster-armhf-lite.zip
    ;;
    *)
    echo "Unknown image $1"
    exit 1
    ;;
esac

filename=`basename ${url}`
tempdir=${RUNNER_TEMP:-/home/actions/temp}/arm-runner
mkdir -p ${tempdir}
cd ${tempdir}
wget -q ${url}
unzip -u ${filename}
mv "$(ls *.img | head -n 1)" arm-runner.img
echo "::set-output name=image::${tempdir}/arm-runner.img"
