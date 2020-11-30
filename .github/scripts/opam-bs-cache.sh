#!/bin/bash -xue

. .github/scripts/preamble.sh

rm -f .cache/local/bin/opam-bootstrap
mkdir -p .cache/local/bin/

os=$( (uname -s || echo unknown) | awk '{print tolower($0)}')
if [ "$os" = "darwin" ] ; then
  os=macos
fi
wget -q -O .cache/local/bin/opam-bootstrap \
  "https://github.com/ocaml/opam/releases/download/$OPAMBSVERSION/opam-$OPAMBSVERSION-$(uname -m)-$os"
cp -f .cache/local/bin/opam-bootstrap .cache/local/bin/opam
chmod a+x .cache/local/bin/opam
opam --version
if [[ -d $OPAMBSROOT ]] ; then
  init-bootstrap || { rm -rf $OPAMBSROOT; init-bootstrap; }
else
  init-bootstrap
fi
