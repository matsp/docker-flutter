#!/bin/bash

# execute flutter with arguments
flutter --no-version-check $1 $2 $3 $4 $5 $6

/bin/bash /usr/local/bin/chown.sh

exit
