#!/usr/bin/env bash
URL="https://mirror.racket-lang.org/installers/$RACKET_VS/racket-$RACKET_VS-x86_64-linux.sh"
INSTALLER=./install-racket-binaries.sh
RACKET_DIR=./racket

printenv

echo "Downloading Racket ... "
curl -L -o $INSTALLER $URL

echo "Making racket executable"
chmod u+rx "$INSTALLER"

echo "Running installer"
$INSTALLER <<EOF
no
"$RACKET_DIR"
EOF

export PATH=/app/racket/bin:$PATH

echo "Installing deps"
raco pkg install --deps search-auto





