# docker-flutter

With this docker image you don't need to install the Flutter and Android SDK on your developer machine. Everything is ready to use inclusive an emulator device (Pixel with Android 9). With a shell alias you won't recognize a difference between the image and a local installation.

## Supported tags

- [`latest`](https://github.com/matsp/docker-flutter/blob/master/stable/Dockerfile)
  - [`1.20.1`](https://github.com/matsp/docker-flutter/blob/master/stable/Dockerfile)
- [`beta`](https://github.com/matsp/docker-flutter/tree/master/beta)	
  - [`beta-1.20.0-7.4.pre`](https://github.com/matsp/docker-flutter/tree/master/beta)
- [`dev`](https://github.com/matsp/docker-flutter/tree/master/dev)
  - [`dev-1.21.0-1.0.pre`](https://github.com/matsp/docker-flutter/tree/master/dev)

## Entrypoints

- `flutter` (default)
- `flutter-android-emulator`
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

To archive the best performance we will mount the X11 directory, DRI and KVM device of the host to get full hardware accerlation:

```shell
xhost local:$USER && docker run --rm -ti -e UID=$(id -u) -e GID=$(id -g) -p 42000:42000 --workdir /project --device /dev/kvm --device /dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v "$PWD":/project --entrypoint flutter-android-emulator  matspfeiffer/flutter
```

### flutter-web (beta only)

You app will be served on localhost:8090:

```shell
docker run --rm -ti -e UID=$(id -u) -e GID=$(id -g) -p 42000:42000 -p 8090:8090  --workdir /project -v "$PWD":/project --entrypoint flutter-web matspfeiffer/flutter:beta
```

## VSCode devcontainer

You can also use this image to develop inside a devcontainer in VSCode and launch the android emulator or web-server.

Add this `.devcontainer/devcontainer.json` to your VSCode project - e.g. Linux:

```json
{
  "name": "Flutter",
  "image": "matspfeiffer/flutter:beta",
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

## FAQ

> Why not using alpine?

Alpine is based on `musl` instead of `glibc`. The dart binaries packaged by flutter are linked against `glibc` so the Flutter SDK is not compatible with Alpine - it's possible to fix this but not the core attempt of this image.

> Why OpenJDK 8?

With higher versions the sdkmanager of the android tools throws errors while fetching maven dependencies.

> Which operating systems are currently supported?

Using the image to run `flutter` in the container and use Flutter for Web is working on Linux, MacOS and Windows. Starting the android emulator in the container and forward to the graphical system of the host is only working on Linux at the moment.
