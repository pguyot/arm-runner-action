# arm-runner-action

Run tests natively and build images directly from GitHub Actions using a
chroot-based virtualized Raspberry Pi (raspios/raspbian) environment.

With this action, you can:

- run tests in an environment closer to a real embedded system, using qemu
userland Linux emulation;
- build artifacts in such environment and upload them;
- prepare images that are ready to run on Raspberry Pi and other ARM embedded
devices.

This action works with both 32 bits (arm) and 64 bits (aarch64) images.

## Usage

Minimal usage is as follows:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: pguyot/arm-runner-action@v2
      with:
        commands: |
            commands to run tests
```

Typical usage to upload an image as an artifact:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: pguyot/arm-runner-action@v2
      id: build_image
      with:
        base_image: raspios_lite:2022-04-04
        commands: |
            commands to build image
    - name: Compress the release image
      if: github.ref == 'refs/heads/releng' || startsWith(github.ref, 'refs/tags/')
      run: |
        mv ${{ steps.build_image.outputs.image }} my-release-image.img
        xz -0 -T 0 -v my-release-image.img
    - name: Upload release image
      uses: actions/upload-artifact@v2
      if: github.ref == 'refs/heads/releng' || startsWith(github.ref, 'refs/tags/')
      with:
        name: Release image
        path: my-release-image.img.xz
```

Several scenarios are actually implemented as [tests](/.github/workflows).

### Host and guest OS

The action has been tested with `ubuntu-latest` (currently equivalent to
`ubuntu-20.04`) and `ubuntu-22.04`. It requires a Linux kernel that is
compatible enough with the guest system as it uses qemu userland emulation. It
relies on binfmt.

### Commands

The repository is copied to the image before the commands script is executed
in the chroot environment. The commands script is copied to /tmp/ and is
deleted on cleanup.

### Inputs

#### `commands`

Commands to execute. Written to a script within the image. Required.

#### `base_image`

Base image to use. By default, uses latest `raspios_lite` image. Please note
that this is not necessarily well suited for continuous integration as
the latest image can change with new releases.

The following values are allowed:

- `raspbian_lite:2020-02-13`
- `raspbian_lite:latest`
- `raspios_lite:2021-03-04`
- `raspios_lite:2021-05-07`
- `raspios_lite:2021-10-30`
- `raspios_lite:2022-01-28`
- `raspios_lite:2022-04-04`
- `raspios_lite:latest` (armhf build, *default*)
- `raspios_lite_arm64:2022-01-28` (arm64)
- `raspios_lite_arm64:2022-04-04` (arm64)
- `raspios_lite_arm64:latest` (arm64)
- `dietpi:rpi_armv6_bullseye`
- `dietpi:rpi_armv7_bullseye`
- `dietpi:rpi_armv8_bullseye` (arm64)
- `raspi_1_bullseye:20220121` (armel)
- `raspi_2_bullseye:20220121` (armhf)
- `raspi_3_bullseye:20220121` (arm64)
- `raspi_4_bullseye:20220121` (arm64)

The input parameter also accepts any custom URL beginning in http(s)://...

More images will be added, eventually. Feel free to submit PRs.

#### `image_additional_mb`

Enlarge the image by this number of MB. Default is to not enlarge the image.

#### `cpu`

CPU to pass to qemu. Pass either a single CPU value or a pair
`<arm_cpu>:<aarch64_cpu>`.

Default is `arm1176:cortex-a53`, i.e. `arm1176` for arm and `cortex-a53` for
aarch64. This is the most compatible pair for Raspberry Pi. Indeed, `arm1176`
is the CPU of BCM2835 which is the SOC of first generation RaspberryPi and
RaspberryPi Zero, while `cortex-a53` is the 64 bits CPU of the first 64 bits
Raspberry Pi models. Code compiled for `arm1176` can be run on later 32 bits
CPUs.

The following values are specially processed:
- `arm1176` equivalent to `arm1176:cortex-a53`.
- `cortex-a7` equivalent to `cortex-a7:cortex-a53`. Optimized for later Pi
   models (Pi 3/Pi 4 and Pi Zero 2). Not suitable for Pi 1/Pi 2/Pi Zero.
- `cortex-a8` equivalent to `cortex-a8:max`.
- `cortex-a53` equivalent to `max:cortex-a53`.

Some software uses the output of `uname -m` or equivalent. This command is
directly driven by this `cpu` option. You might want to compile 32 bits
binaries with both `arm1176` which translates to `armv6l` and `cortex-a7` which
translates to `armv7l`.

For FPU and vector instruction sets, software usually automatically looks into
`/proc/cpuinfo` or equivalent. This can be patched with `cpu_info` option.

Whether code is executed in 32 bits or 64 bits (and build generates 32 bits
or 64 bits binaries) depend on the image. See _32 and 64 bits_ below.

#### `copy_artifact_path`

Source paths(s) inside the image to copy outside after the commands have
executed. Relative to the `/<repository_name>` directory or the directory
defined with `copy_repository_path`. Globs are allowed. To copy multiple paths,
provide a list of paths, separated by semicolons. Default is not to copy.

#### `copy_artifact_dest`

Destination path to copy outside the image after the commands have executed.
Relative to the working directory (outside the image). Defaults to `.`

#### `copy_repository_path`

Absolute path, inside the image, where the repository is copied or mounted.
Defaults to `/<repository_name>`. It is also the working directory where
commands are executed.

The repository is copied unless `bind_mount_repository` is set to true.

#### `bind_mount_repository`

Bind mount the repository within the image instead of copying it. Default is
to copy files.

If mounted, any modification of files within the repository by the target
emulated system will persist after execution. It does not accelerate execution
significantly but can simplify the logic by avoiding the copy artifact step
from the target system.

#### `cpu_info`

Path to a fake cpu_info file to be used instead of `/proc/cpuinfo`. Default is
to not fake the CPU (/proc/cpuinfo will report amd64 CPU of GitHub runner).

Some software checks for features using `/proc/cpuinfo` and this option can be
used to trick them. The path is relative to the action (to use pre-defined
settings) or to the local repository.

Bundled with the action are the following files:
- `cpuinfo/raspberrypi_4b`
- `cpuinfo/raspberrypi_3b` (with a 32 bits system)
- `cpuinfo/raspberrypi_zero_w`
- `cpuinfo/raspberrypi_zero2_w` (with a 32 bits system)
- `cpuinfo/raspberrypi_zero2_w_arm64` (with a 64 bits system)

On real hardware, the `/proc/cpuinfo` file content depends on the CPU being
used in 32 bits or 64 bits mode, which in turn depends on the base image.
Consequently, you may want to use `cpuinfo/raspberrypi_zero2_w_arm64` for
64 bits builds and `cpuinfo/raspberrypi_zero2_w` for 32 bits builds.

#### `optimize_image`

Zero-fill unused filesystem blocks and shrink root filesystem during final clean-up, to make any later
image compression more efficient. Default is to optimize image.

#### `use_systemd_nspawn`

Use `systemd-nspawn` instead of chroot to run commands. Default is to use
chroot.

#### `rootpartition`

Index (starting with 1) of the root partition. Default is 2, which is suitable
for Raspberry Pi. NVIDIA Jetson images require 1. This is the partition that is
resized with `image_additional_mb` option.

#### `bootpartition`

Index (starting with 1) of the boot partition which gets mounted at /boot.
Default is 1, which is suitable for Raspberry Pi. If the value is empty,
the partition is not mounted.

#### `shell`

Path to shell or shell name to run the commands in. Defaults to /bin/sh.
If missing, it will be installed. See `shell_package`.
If defined as basename filename, it will be used as long as the shell binary
exists under PATH after the package is installed.

Parameters can be passed to the shell, e.g.:
```yaml
shell: /bin/bash -eo pipefail
```

#### `shell_package`

The shell package to install, if different from shell. It may be handy
with some shells that come packaged under a different package name.

For example, to use `ksh93` as shell, set `shell` to `ksh93` and
`shell_package` to `ksh`.

#### `exit_on_fail`

Exit immediately if a command exits with a non-zero status. Default is to exit.
Set to `no` or `false` to disable exiting on command failure. This only works
with `sh`, `bash` and `ksh` shells.

#### `debug`

Display executed commands as they are executed. Enabled by default.

#### `import_github_env`

Imports variables written so far to `$GITHUB_ENV` to the image. Default is not
to import any environment. This may be useful for sharing external variables with
the virtual environment. Set to `yes` or `true` to enable.

Practically, this setting allows constructs like `${VARIABLE_NAME}` instead of
`${{ env.VARIABLE_NAME }}` within the command set.

#### `export_github_env`

Enables `$GITHUB_ENV` for commands in the image and exports its contents on
completion to subsequent tasks. This option is an alternative to using a
file-based artifact for passing the results of commands outside the image
environment.

Note this parameter does not enable importing any contents written to
`$GITHUB_ENV` ahead of running the commands. For that, use `import_github_env`.

### Outputs

#### `image`

Path to the image, useful after the step to upload the image as an artifact.

### 32 and 64 bits

Many RaspberryPis and ARM boards are based on 64-bits chipsets than can run
32 bits and 64 bits kernels. RaspberryPi OS, as well as other distributions,
are now provided in 32 bits and 64 bits flavors.

This action works for images built for 32 bits and 64 bits ARM architectures.
Default input values imply 32 bits images. For 64 bits, the CPU and the
base image should match.

The following matrix will build on armv6l, armv7l and aarch64 using the latest
RaspberryPi OS images.

```yaml
name: Test architecture matrix
on: [push, pull_request, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        arch: [armv6l, armv7l, aarch64]
        include:
        - arch: armv6l
          cpu: arm1176
          base_image: raspios_lite:latest
          cpu_info: raspberrypi_zero_w
        - arch: armv7l
          cpu: cortex-a7
          base_image: raspios_lite:latest
          cpu_info: raspberrypi_3b
        - arch: aarch64
          cpu: cortex-a53
          base_image: raspios_lite_arm64:latest
          cpu_info: raspberrypi_zero2_w_arm64_w
    steps:
    - uses: pguyot/arm-runner-action@v2
      with:
        base_image: ${{ matrix.base_image }}
        cpu: ${{ matrix.cpu }}
        cpu_info: ${{ matrix.cpu_info }}
        commands: |
            test `uname -m` = ${{ matrix.arch }}
            grep Model /proc/cpuinfo
```

Internally, the `cpu` value is embedded in a wrapper for `qemu-arm-static` and
`qemu-aarch64-static`. The actual qemu invoked depends on executables within
the base image.

## Examples

Real world examples include:

- [pguyot/wm8960](https://github.com/pguyot/wm8960/blob/master/.github/workflows/arm-runner.yml) : compilation and tests
- [nabaztag2018/pynab](https://github.com/nabaztag2018/pynab/blob/master/.github/workflows/arm-runner.yml) : compilation, tests and disk image.

## Releases

Releases are listed on [dedicated page](https://github.com/pguyot/arm-runner-action/releases).
Release numbers follow semantic versionning : incompatible changes in invocation will be reflected with major release upgrades.
