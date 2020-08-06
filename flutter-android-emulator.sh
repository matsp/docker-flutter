#!/bin/bash

flutter emulators --launch $FLUTTER_EMULATOR_NAME

started=0
while [ $started -eq 0 ] 
do 
  sleep 1
  started=$(flutter devices | grep emulator | wc -l)
done

flutter run -d $FLUTTER_EMULATOR_NAME --observatory-port $FLUTTER_DEBUG_PORT

/bin/bash /usr/local/bin/chown.sh

exit
