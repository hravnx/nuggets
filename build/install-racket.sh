URL="https://mirror.racket-lang.org/installers/$racketVs/racket-$racketVs-x86_64-linux.sh"
INSTALLER=install-racket.sh
RACKET_DIR=./racket

echo "Downloading Racket ..."
curl -L -o $INSTALLER $URL

echo "Making racket executable"
chmod u+rx "$INSTALLER"

echo "Running installer"
$INSTALLER <<EOF
no
"$RACKET_DIR"
EOF

echo "Racket installed"

