#!/bin/sh
set -eux
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
sudo cp /home/ocaml/.opam/default/lib/opam-devel/opam /usr/local/bin
opam --version
rm -rf $OPAMROOT
opam init --reinit -ni --disable-sandboxing --bare
opam switch create confs --empty
opam install conf-gmp
opam install conf-automake
