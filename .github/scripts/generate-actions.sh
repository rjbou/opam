#!/bin/sh

set -eux

target=$1
dir=.github/actions/$target

mkdir -p $dir

cat >$dir/action.yml << EOF
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
EOF
    ;;
  debian)
  cat >$dir/Dockerfile << EOF
FROM debian
RUN apt update
RUN apt install -y ocaml m4 git rsync patch make wget opam ocaml-compiler-libs
EOF
esac

cat >>$dir/Dockerfile << EOF
RUN mkdir opam
WORKDIR opam
ENV OPAMROOTISOK 1
ENV OPAMROOT /opam/root
ENV OPAMYES 1
ENV OPAMCONFIRMLEVEL unsafe-yes
ENV OPAMPRECISETRACKING 1
RUN opam init --no-setup --disable-sandboxing --bare
RUN opam switch create localopam ocaml-system
RUN opam install opam-repository opam-solver opam-state opam-client opam-core opam-devel --deps
COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/opam/entrypoint.sh"]
EOF

cat >$dir/entrypoint.sh << EOF
#!/bin/sh
set -eux
#case \$GITHUB_EVENT_NAME in
#  pull_request)
#    BRANCH=\$GITHUB_HEAD_REF
#    ;;
#  push)
#    BRANCH=\${GITHUB_REF##*/}
#    ;;
#  *)
#  echo -e "Not handled event"
#  BRANCH=master
#esac

cd /github/workspace
opam install . --deps
eval \$(opam env)
./configure
make
#opam pin /github/workspace #git+https://github.com/ocaml/opam#\$BRANCH
#cp \$(opam var prefix)/lib/opam-devel/opam /opam/
#alias opam=/opam/opam
./opam config report
./opam switch create confs --empty
./opam install conf-autoconf
./opam install conf-gmp
./opam install conf-automake
EOF

chmod +x $dir/entrypoint.sh
