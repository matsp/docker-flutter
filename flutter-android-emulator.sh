#!/bin/bash

flutter emulators --launch pixel_9.0
sleep 10
flutter run -d $FLUTTER_EMULATOR_NAME --observatory-port $FLUTTER_DEBUG_PORT
/bin/bash /usr/local/bin/chown.sh

exit
