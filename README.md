# arm-runner-action
GitHub action to run CI within a virtualized ARM environment, typically
raspbian.

## Usage

Minimal usage is as follows:

    jobs:
      build:
        - uses: pguyot/arm-runner-action@v1
          with:
            commands: |
                some commands


### Inputs

#### `commands`

Commands to execute. Written to a script within the image. Required.

#### `base_image`

Base image to use.

The following values are allowed:
- `raspbian_lite:2020-02-13`
- `raspios_lite:2021-03-04` (default)

More images will be added, eventually.

#### `image_additional_mb`

Enlarge the image by this number of MB. Default is to not enlarge the image.

#### `cpu`

CPU to pass to qemu.
Default value is `arm1176` which translates to arm6vl, suitable for Pi Zero.

#### `copy_artifact_path`

Source path to copy outside the image. Relative to the working directory, within the
image. Globs are allowed. Default is not to copy.

#### `copy_artifact_dest`

Destination path to copy outside the image. Relative to the working directory
(outside the image). Default to `.`

### Outputs

#### `image`

Path to the image, useful after the step to upload the image as an artifact.
