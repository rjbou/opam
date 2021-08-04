#!/bin/sh

set -eux

target=$1
dir=.github/actions/$target

mkdir -p $dir

cat >$dir/action.ml << EOF
name: 'depexts-$target'
description: 'Test external dependencies handling for $target'
runs:
  using: 'docker'
  image: 'Dockerfile'
EOF

case "$target" in
  alpine)
    cat >$dir/Dockerfile << EOF
FROM alpine
RUN apk add ocaml m4 git rsync patch make wget opam ocaml-compiler-libs
RUN apk add g++
RUN mkdir opam
EOF
    ;;
  debian)
  cat >$dir/Dockerfile << EOF
FROM debian
RUN apt update
RUN apt install -y ocaml m4 git rsync patch make wget opam ocaml-compiler-libs
EOF
esac

cat >$dir/Dockerfile <<- EOF
WORKDIR opam
ENV OPAMROOTISOK=1
ENV OPAMROOT=/opam/root
ENV OPAMYES=1
ENV OPAMCONFIRMLEVEL=unsafe-yes
RUN opam init -ni --disable-sandboxing --bare
RUN opam switch create confs ocaml-system
RUN opam install opam-repository opam-solver opam-state opam-client opam-core opam-devel --deps
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EOF

cat >$dir/entrypoint.sh << EOF
#!/bin/sh
set -ex
case \$GITHUB_EVENT_NAME in
  pull_request)
    BRANCH=\$GITHUB_HEAD_REF
    ;;
  push)
    BRANCH=\${GITHUB_REF##*/}
    ;;
  *)
  echo -e "Not handled event"
  BRANCH=master
esac

opam pin git+https://github.com/rjbou/opam#\$BRANCH
cp `opam var prefix`/lib/opam-devel/opam /opam/
alias opam=/opam/opam
opam config report
rm -rf \$OPAMROOT
opam init --reinit -ni --disable-sandboxing --bare
opam switch create confs --empty
opam install conf-gmp
opam install conf-automake
EOF
