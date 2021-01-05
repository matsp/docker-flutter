#!/bin/bash

# execute flutter with arguments
flutter "$@"

/bin/bash /usr/local/bin/chown.sh

exit
