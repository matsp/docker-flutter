FROM ubuntu:20.04

ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip"
ENV ANDROID_VERSION="28"
ENV ANDROID_BUILD_TOOLS_VERSION="28.0.3"
ENV ANDROID_ARCHITECTURE="x86_64"
ENV ANDROID_SDK_ROOT="/opt/android"
ENV FLUTTER_CHANNEL="beta"
ENV FLUTTER_VERSION="1.17.0-3.4.pre"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
ENV FLUTTER_HOME="/opt/flutter"
ENV FLUTTER_WEB_PORT="8090"
ENV FLUTTER_DEBUG_PORT="42000"
ENV FLUTTER_EMULATOR_NAME="emulator-5554"
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$FLUTTER_HOME/bin:$PATH"

# install all dependencies
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
  && apt-get install --yes --no-install-recommends openjdk-14-jdk curl unzip sed git bash xz-utils libglvnd0 ssh xauth x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx \
  && rm -rf /var/lib/{apt,dpkg,cache,log}

# android sdk
RUN mkdir -p $ANDROID_SDK_ROOT \
  && curl -o android_tools.zip $ANDROID_TOOLS_URL \
  && unzip -qq -d "$ANDROID_SDK_ROOT" android_tools.zip \
  && rm android_tools.zip \
  && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
  && mv $ANDROID_SDK_ROOT/tools $ANDROID_SDK_ROOT/cmdline-tools/tools \
  && yes "y" | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
  && yes "y" | sdkmanager "platforms;android-$ANDROID_VERSION" \
  && yes "y" | sdkmanager "platform-tools" \
  && yes "y" | sdkmanager "emulator" \
  && yes "y" | sdkmanager "system-images;android-$ANDROID_VERSION;google_apis;$ANDROID_ARCHITECTURE" \
  && yes "no" | avdmanager create avd --force \
      --name "pixel_9.0" \
      --device "pixel" \
      --package "system-images;android-$ANDROID_VERSION;google_apis;$ANDROID_ARCHITECTURE" \
      --tag "google_apis" \
      --abi "$ARCHITECTURE"
      #&& echo "hw.ramSize=1024" >> /root/.android/avd/pixel_9.0.avd/config.ini

# flutter
RUN curl -o flutter.tar.xz $FLUTTER_URL \
  && mkdir -p $FLUTTER_HOME \
  && tar xf flutter.tar.xz -C /opt \
  && chown -R root:root $FLUTTER_HOME \
  && rm flutter.tar.xz \
  && flutter config --no-analytics --enable-web \
  && flutter precache \
  && yes "y" | flutter doctor --android-licenses \
  && flutter doctor

# commands
RUN echo "#!/bin/bash\nflutter emulators --launch pixel_9.0\nflutter run -d $FLUTTER_EMULATOR_NAME --observatory-port $FLUTTER_DEBUG_PORT" > /usr/bin/flutter-android-emulator \
    && chmod +x /usr/bin/flutter-android-emulator \
    && echo "#!/bin/bash\nflutter run -d web-server --web-port $FLUTTER_WEB_PORT --web-hostname 0.0.0.0 --observatory-port $FLUTTER_DEBUG_PORT" > /usr/bin/flutter-web \
    && chmod +x /usr/bin/flutter-web

WORKDIR "/app"
ENTRYPOINT [ "flutter" ]
