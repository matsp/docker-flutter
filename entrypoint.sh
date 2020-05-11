#!/bin/bash

# execute flutter with arguments
flutter $1 $2 $3 $4 $5 $6

chown $UID:$GID -R $(pwd)

exit
