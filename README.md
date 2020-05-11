# docker-flutter

# Tags

* beta

# Client dependencies

## Linux 

Host need to support KVM.

## Build

```shell
git clone --depth 1 https://github.com/matsp/docker-flutter.git
cd docker-flutter
docker build -t docker-flutter .
```

## Linux:run

```shell
docker run --rm -ti -p 42000:42000 -p 8090:8090 --device /dev/kvm -v /tmp/.X11-unix -e DISPLAY docker-flutter
```

## Flutter

* flutter-android-emulator
* flutter-web
