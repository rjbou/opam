#!/bin/bash -xue

. .github/scripts/preamble.sh

export OPAMYES=1
export OCAMLRUNPARAM=b

export OPAMROOT=$OPAMBSROOT
echo $OPAMROOT

which opam
opam --version
opam switch create $SOLVER ocaml-system || true
opam install $SOLVER
opam install . --deps
eval $(opam env)
./configure
make
