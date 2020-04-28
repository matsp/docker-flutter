# docker-flutter

# Client dependencies

## Linux 

Host need to support KVM.

* `xauth`

## Build

```shell
docker build -t docker-flutter .
```

## Linux:run

```shell
docker run --rm -it -p 8090:8090 -p 2222:22 --device /dev/kvm docker-flutter
```

## Flutter

### Run flutter for web
```shell
flutter run -d web-server --web-port 8090 --web-hostname 0.0.0.0
```

### Run flutter for android
```shell
sudo /bin/sshd # start SSH server for X11 forwarding
ssh user@localhost -X -p 2222

flutter emulators --launch pixel_9.0
flutter devices # retrieve emulator name
flutter run -d emulator-xxx
```
