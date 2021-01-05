#!/bin/bash

# execute flutter with arguments
flutter --no-version-check "$@"


/bin/bash /usr/local/bin/chown.sh

exit
