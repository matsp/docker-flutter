# docker-flutter

## Entrypoints

* `flutter`
* `flutter-android-emulator` (only works on Linux)
* `flutter-web` (may not work on Windows)

*Dependencies*

When you want to run the `flutter-android-emulator` entrypoint your host must support KVM and have `xhost` installed.

### flutter

Executing flutter in the current host directory:

```shell
docker run --rm -e UID=$(id -u) -e GID=$(id -g) --workdir /project -v "$PWD":/project matspfeiffer/flutter
```

When you don't set the `UID` and `GID` the files will be owned by the root user.

### flutter-android-emulator
To archive the best performance we will mount the X11 directory, DRI and KVM device of the host to get full hardware accerlation: 

```shell
xhost local:$USER && docker run --rm -ti -e UID=$(id -u) -e GID=$(id -g) -p 42000:42000 --workdir /project --device /dev/kvm --device /dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v "$PWD":/project --entrypoint flutter-android-emulator  matspfeiffer/flutter
```

### flutter-web

You app will be served on localhost:8090:

```shell
docker run --rm -ti -e UID=$(id -u) -e GID=$(id -g) -p 42000:42000 -p 8090:8090  --workdir /project -v "$PWD":/project --entrypoint flutter-web matspfeiffer/flutter
```
