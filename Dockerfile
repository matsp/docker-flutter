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
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$FLUTTER_HOME/bin:$PATH"

# install all dependencies
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get install --yes --no-install-recommends default-jdk curl unzip sed git bash xz-utils libglvnd0 ssh xauth x11-xserver-utils libpulse0 libxcomposite1 \
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

# X11 ssh forwarding
RUN sed -i \
  -e 's/^#*\(PermitRootLogin\) .*/\1 yes/' \
  -e 's/^#*\(X11Forwarding\) .*/\1 yes/' \
  -e 's/^#*\(X11DisplayOffset\) .*/\1 10/' \
  -e 's/^#*\(AllowTcpForwarding\) .*/\1 yes/' \
  -e 's/^#*\(X11UseLocalhost\) .*/\1 no/' \
  -e 's/^#*\(UsePAM\) .*/\1 no/' \
  -e 's/^#*\(AddressFamily\) .*/\1 inet/' \
       /etc/ssh/sshd_config \
  && ssh-keygen -A \
  && mkdir -p /var/run/sshd \
  && echo "root:root" | chpasswd \
  && echo "export PATH=$PATH" >> /root/.profile \
  && echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" >> /root/.profile

CMD [ "/bin/bash" ]
