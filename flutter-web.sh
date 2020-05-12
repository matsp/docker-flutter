#!/bin/bash

flutter run -d web-server --web-port $FLUTTER_WEB_PORT --web-hostname 0.0.0.0 --observatory-port $FLUTTER_DEBUG_PORT
/bin/bash /usr/local/bin/chown.sh

exit
