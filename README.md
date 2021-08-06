# arm-runner-action

Run tests natively and build images directly from GitHub Actions using a
chroot-based virtualized Raspberry Pi (raspios/raspbian) environment.

With this action, you can:
- run tests in an environment closer to a real embedded system, using qemu
userland linux emulation;
- build artifacts in such environment and upload them;
- prepare images that are ready to run on Raspberry-Pi and other arm embedded
devices.

## Usage

Minimal usage is as follows:

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v2
        - uses: pguyot/arm-runner-action@v1
          with:
            commands: |
                commands to run tests

Typical usage to upload an image as an artifact:

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v2
        - uses: pguyot/arm-runner-action@v1
          id: build_image
          with:
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

Several scenarios are actually implemented as [tests](/.github/workflows).

### Commands

The repository is copied to the image before the commands script is executed
in the chroot environment. The commands script is copied to /tmp/ and is
deleted on cleanup.

### Inputs

#### `commands`

Commands to execute. Written to a script within the image. Required.

#### `base_image`

Base image to use.

The following values are allowed:
- `raspbian_lite:2020-02-13`
- `raspios_lite:2021-03-04`
- `raspios_lite:2021-05-07` (default)
- `dietpi:rpi_armv6_buster`

More images will be added, eventually. Feel free to submit PRs.

#### `image_additional_mb`

Enlarge the image by this number of MB. Default is to not enlarge the image.

#### `cpu`

CPU to pass to qemu.
Default value is `arm1176` which translates to arm6vl, suitable for Pi Zero.
Other values include `cortex-a8` which translates to arm7vl.

#### `copy_artifact_path`

Source path to copy outside the image. Relative to the working directory,
within the image. Globs are allowed. Default is not to copy.

#### `copy_artifact_dest`

Destination path to copy outside the image. Relative to the working directory
(outside the image). Defaults to `.`

#### `copy_repository_path`

Absolute path, inside the image, where the repository is copied. Defaults
to `/<repository_name>`. It is also the working directory where commands are
executed.

#### `optimize_image`

Zero-fill unused filesystem blocks during final cleanup, to make any later
image compression more efficient. Default is to zero-fill.

#### `use_systemd_nspawn`

Use `systemd-nspanw` instead of chroot to run commands. Default is to use
chroot.

#### `shell`

Path to shell or shell name to run the commands in. Defaults to /bin/sh.
If missing, it will be installed. See `shell_package`.
If defined as basename filename, it will be used as long as the shell binary
exists under PATH after the package is installed.

#### `shell_package`

The shell package to install, if different from shell. It may be handy
with some shells that come packaged under a different package name.

For example, to use `ksh93` as shell, set `shell` to `ksh93` and
`shell_package` to `ksh`.

#### `exit_on_fail`

Exit immediately if a command exits with a non-zero status. Default is to exit.
Set to `no` or `false` to disable exiting on command failure.

### Outputs

#### `image`

Path to the image, useful after the step to upload the image as an artifact.

## Examples

Real world examples include:
- [pguyot/wm8960](https://github.com/pguyot/wm8960/blob/master/.github/workflows/arm-runner.yml) : compilation and tests
- [nabaztag2018/pynab](https://github.com/nabaztag2018/pynab/blob/master/.github/workflows/arm-runner.yml) : compilation, tests and disk image.

## Releases

Releases are listed on [dedicated page](https://github.com/pguyot/arm-runner-action/releases).
Release numbers follow semantic versionning : incompatible changes in invocation will be reflected with major release upgrades.
