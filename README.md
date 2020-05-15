# docker-flutter

With this docker image you don't need to install the Flutter and Android SDK on your developer machine. Everything is ready to use inclusive an emulator device (Pixel with Android 9). With a shell alias you won't recognize a difference between the image and a local installation.

## Supported tags

- [`1.17.1`, `latest`](https://github.com/matsp/docker-flutter/blob/master/stable/Dockerfile)
- [`beta-1.18.0-11.1.pre`, `beta`](https://github.com/matsp/docker-flutter/tree/master/beta)

## Entrypoints

- `flutter` (default)
- `flutter-android-emulator` (Linux only at the moment)
- `flutter-web` (beta only)

_Dependencies_

When you want to run the `flutter-android-emulator` entrypoint your host must support KVM and have `xhost` installed.

### flutter (default)

Executing flutter in the current directory:

```shell
docker run --rm -e UID=$(id -u) -e GID=$(id -g) --workdir /project -v "$PWD":/project matspfeiffer/flutter
```

When you don't set the `UID` and `GID` the files will be owned by `G-/UID=1000`.

### flutter-android-emulator

_THIS ONLY TESTED WITH LINUX_

To archive the best performance we will mount the X11 directory, DRI and KVM device of the host to get full hardware accerlation:

```shell
xhost local:$USER && docker run --rm -ti -e UID=$(id -u) -e GID=$(id -g) -p 42000:42000 --workdir /project --device /dev/kvm --device /dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v "$PWD":/project --entrypoint flutter-android-emulator  matspfeiffer/flutter
```

### flutter-web (beta only)

You app will be served on localhost:8090:

```shell
docker run --rm -ti -e UID=$(id -u) -e GID=$(id -g) -p 42000:42000 -p 8090:8090  --workdir /project -v "$PWD":/project --entrypoint flutter-web matspfeiffer/flutter:beta
```

## FAQ

> Why not using alpine?

Alpine is based on `musl` instead of `glibc`. The dart binaries packaged by flutter are linked against `glibc` so the Flutter SDK is not compatible with Alpine - it's possible to fix this but not the core attempt of this image.
