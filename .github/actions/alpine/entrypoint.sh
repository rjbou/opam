#!/bin/sh
set -ex
case $GITHUB_EVENT_NAME in
  pull_request)
    BRANCH=$GITHUB_HEAD_REF
    ;;
  push)
    BRANCH=${GITHUB_REF##*/}
    ;;
  *)
  echo -e "Not handled event"
  BRANCH=master
esac

opam pin git+https://github.com/ocaml/opam#$BRANCH
cp `opam var prefix`/lib/opam-devel/opam /opam/
alias opam=/opam/opam
opam config report
rm -rf $OPAMROOT
opam init --reinit -ni --disable-sandboxing --bare
opam switch create confs --empty
opam install conf-gmp
opam install conf-automake
