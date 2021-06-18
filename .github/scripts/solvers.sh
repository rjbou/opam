#!/bin/bash -xue

. .github/scripts/preamble.sh

export OPAMYES=1
export OCAMLRUNPARAM=b

export OPAMROOT=$CACHE/opam.$SOLVER.cached

which opam
opam --version
opam switch create $SOLVER ocaml-system || true
opam install $SOLVER
opam install . --deps
./configure
make
