#!/bin/bash

set -xue

. .github/scripts/main/preamble.sh

export OCAMLRUNPARAM=b
# XXX This should be matching up with $PREFIX in main
export PATH=~/local/bin:$PATH
export OPAMKEEPLOGS=1

case "$1" in
  *-pc-windows|*-w64-mingw32)
    CONFIGURE_PREFIX='D:\Local'
    PREFIX="$(cygpath "$CONFIGURE_PREFIX")";;
  *)
    PREFIX=~/local
    CONFIGURE_PREFIX="$PREFIX";;
esac

export PATH="$PREFIX/bin:$PATH"

git clone https://codeberg.org/kit-ty-kate/micro_httpd
pushd micro_httpd
dune build -p micro_httpd
dune install --root . --prefix "$CONFIGURE_PREFIX"
popd
rm -rf micro_httpd

make tests
