# docker-flutter

With this container images you don't need to install the Flutter and Android SDK on your developer machine.
Everything is ready to use inclusive an emulator device (Pixel with Android 9). With a shell alias you won't recognize 
a difference between the image and a local installation. If you are using VSCode you can also use this image as your devcontainer.

## Recommendations

To have no file permission issues between your project and the container you should run the container rootless:

1. [Docker rootless](https://docs.docker.com/engine/security/rootless/#rootless-docker-in-docker)
2. [Podman rootless @arch](https://wiki.archlinux.org/index.php/Podman#Rootless_Podman)

## Supported tags

- [`latest`](https://github.com/matsp/docker-flutter/blob/master/Dockerfile.base)
- [`stable`](https://github.com/matsp/docker-flutter/blob/master/Dockerfile.base)
- [`beta`](https://github.com/matsp/docker-flutter/tree/master/Dockerfile.base)
- [`dev`](https://github.com/matsp/docker-flutter/tree/master/Dockerfile.base)
- [`stable-android`](https://github.com/matsp/docker-flutter/tree/master/Dockerfile.android)
- [`beta-android`](https://github.com/matsp/docker-flutter/tree/master/Dockerfile.android)
- [`dev-android`](https://github.com/matsp/docker-flutter/tree/master/Dockerfile.android)

## Entrypoints

- `flutter` (default)
- `flutter-android-emulator`

_Dependencies_

When you want to run the `flutter-android-emulator` entrypoint your host must support KVM and have `xhost` installed.

### flutter (default)

Executing e.g. `flutter help` in the current directory (appended arguments are passed to flutter in the container):

```shell
docker run --rm -w /project -v "$PWD":/project matspfeiffer/flutter help
```

### flutter (connected usb device)

Connecting to a device connected via usb is possible via:

```shell
docker run --rm -w /project -v "$PWD":/project --device=/dev/bus -v /dev/bus/usb:/dev/bus/usb matspfeiffer/flutter:stable-android devices
```

### flutter-android-emulator

To achieve the best performance we will mount the X11 directory, DRI and KVM device of the host to get full hardware acceleration:

```shell
xhost local:$USER && docker run -ti --rm -w /project --device /dev/kvm --device /dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v "$PWD":/project --entrypoint flutter-android-emulator  matspfeiffer/flutter:stable-android
```

### flutter-web (beta only)

```shell
docker run --rm -ti -p 42000:42000 -p 8090:8090 -w /project -v "$PWD":/project  matspfeiffer/flutter:beta run -d web-server --web-port 8090 --web-hostname 0.0.0.0 --observatory-port 42000
```

## VSCode devcontainer

You can also use this image to develop inside a devcontainer in VSCode and launch the android emulator or web-server. The android emulator need hardware acceleration, so their is no best practice for all common operating systems.

### Linux #1 (X11 & KVM forwarding)

For developers using Linux as their OS I recommend this approach, because it's the overall cleanest way.

Add this `.devcontainer/devcontainer.json` to your VSCode project:

```json
{
  "name": "Flutter",
  "image": "matspfeiffer/flutter:stable-android",
  "extensions": ["dart-code.dart-code", "dart-code.flutter"],
  "runArgs": [
    "--device",
    "/dev/kvm",
    "--device",
    "/dev/dri:/dev/dri",
    "-v",
    "/tmp/.X11-unix:/tmp/.X11-unix",
    "-e",
    "DISPLAY"
  ]
}
```

When VSCode has launched your container you have to execute `flutter emulators --launch flutter_emulator` to startup the emulator device. Afterwards you can choose it to debug your flutter code.

### Linux #2, Windows & MacOS (using host emulator)

Add this `.devcontainer/devcontainer.json` to your VSCode project:

```json
{
  "name": "Flutter",
  "image": "matspfeiffer/flutter:stable-android",
  "extensions": ["dart-code.dart-code", "dart-code.flutter"]
}
```

Start your local android emulator. Afterwards execute the following command to make it accessable via network:

```shell
adb tcpip 5555
```

In your docker container connect to device:

```shell
adb connect host.docker.internal:5555
```

You can now choose the device to start debugging.

## FAQ

> Why not using alpine?

Alpine is based on `musl` instead of `glibc`. The dart binaries packaged by flutter are linked against `glibc` so the Flutter SDK is not compatible with Alpine - it's possible to fix this but not the core attempt of this image.

> Why OpenJDK 8?

With higher versions the sdkmanager of the android tools throws errors while fetching maven dependencies.
