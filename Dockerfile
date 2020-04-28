FROM matspfeiffer/dotfiles:latest

ENV ANDROID_VERSION="28"
ENV ANDROID_BUILD_TOOLS_VERSION="28.0.3"
ENV ARCHITECTURE="x86_64"

# android sdk
RUN yay -S --needed --noconfirm --quiet base-devel jdk8-openjdk \
	&& yay -S --noconfirm --quiet android-sdk \
	&& yay -Rnu --noconfirm base-devel \
	&& yay -S --needed --asexplicit --noconfirm --quiet sed unzip

ENV PATH $PATH:/opt/android-sdk/tools/bin
RUN yes "y" | sudo sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
	&& yes "y" | sudo sdkmanager "platforms;android-$ANDROID_VERSION" \
	&& yes "y" | sudo sdkmanager "platform-tools" \
	&& yes "y" | sudo sdkmanager "emulator"

## emulator
RUN yes "y" | sudo sdkmanager "system-images;android-$ANDROID_VERSION;google_apis;$ARCHITECTURE" \
	&& yes "no" | avdmanager --verbose create avd --force --name "pixel_9.0" --device "pixel" --package "system-images;android-$ANDROID_VERSION;google_apis;$ARCHITECTURE" --tag "google_apis" --abi "$ARCHITECTURE"

# flutter
ENV PATH $PATH:/home/$USER/git/flutter/bin
ENV ANDROID_HOME /opt/android-sdk
RUN mkdir -p ~/git \
	&& cd ~/git \
	&& git clone https://github.com/flutter/flutter.git -b beta
RUN flutter config  --no-analytics --enable-web \
	&& flutter precache \
	&& yes "y" | flutter doctor --android-licenses \
	&& flutter doctor

# X11 ssh forwarding
RUN yay -S --noconfirm --needed --quiet openssh libglvnd libxcomposite libxcursor libpulse alsa-lib xorg-xauth xorg-xhost
RUN sudo sed -i \
        -e 's/^#*\(PermitRootLogin\) .*/\1 yes/' \
        -e 's/^#*\(X11Forwarding\) .*/\1 yes/' \
	-e 's/^#*\(X11DisplayOffset\) .*/\1 10/' \
	-e 's/^#*\(AllowTcpForwarding\) .*/\1 yes/' \
	-e 's/^#*\(X11UseLocalhost\) .*/\1 yes/' \
	-e 's/^#*\(UsePAM\) .*/\1 no/' \
	-e 's/^#*\(AddressFamily\) .*/\1 inet/' \
        /etc/ssh/sshd_config \
	&& sudo ssh-keygen -A

ENTRYPOINT [ "zsh" ]
