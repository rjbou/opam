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

opam pin -y git+https://github.com/ocaml/opam#$BRANCH
cp `opam var prefix`/lib/opam-devel/opam /
alias opam=/opam/opam
rm -rf $OPAMROOT
opam config report
opam init --reinit -ni --disable-sandboxing --bare
opam switch create confs --empty
opam install conf-gmp
opam install conf-automake
