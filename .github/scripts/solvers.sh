#!/bin/bash -xue

. .github/scripts/preamble.sh

export OPAMYES=1
export OCAMLRUNPARAM=b

# All environment variable are overwritten in job description
# One cache per solver, $CACHE/opam.<solver>.cached
export OPAMROOT=$OPAMBSROOT
echo $OPAMROOT

opam switch create $SOLVER ocaml-system || true
opam install $SOLVER
opam install . --deps
opam clean --logs --switch-cleanup
eval $(opam env)
./configure
make
