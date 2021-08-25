#!/bin/sh

set -eu

#for target in alpine debian archlinux centos opensuse fedora oraclelinux ubuntu; do
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


mainlibs="m4 git rsync patch tar unzip make wget"
ocaml="ocaml ocaml-compiler-libs"
case "$target" in
  alpine)
    cat >$dir/Dockerfile << EOF
FROM alpine
RUN apk add $mainlibs $ocaml g++
EOF
    ;;
  archlinux)
# no automake
    cat >$dir/Dockerfile << EOF
FROM archlinux
RUN pacman -Sy
RUN pacman -S --noconfirm $mainlibs $ocaml gcc diffutils
EOF
    ;;
 centos)
    cat >$dir/Dockerfile << EOF
FROM centos:7
RUN yum install -y $mainlibs $ocaml bzip2 gcc-c++
EOF
    ;;
  debian)
  cat >$dir/Dockerfile << EOF
FROM debian
RUN apt update
RUN apt install -y $mainlibs $ocaml
RUN apt install -y bzip2 g++
EOF
    ;;
  fedora)
  cat >$dir/Dockerfile << EOF
FROM fedora
RUN dnf install -y $mainlibs $ocaml
RUN dnf install -y diffutils bzip2 gcc-c++
EOF
    ;;
  opensuse)
  # mccs doesn't compile
    cat >$dir/Dockerfile << EOF
FROM opensuse/tumbleweed
RUN zypper --non-interactive install $mainlibs $ocaml gcc-c++ tar diffutils
RUN zypper --non-interactive install gzip bzip2 libcap-devel
EOF
    ;;
  oraclelinux)
    cat >$dir/Dockerfile << EOF
FROM oraclelinux:8
RUN yum install -y $mainlibs bzip2 gcc-c++
EOF
  ;;
  ubuntu)
  cat >$dir/Dockerfile << EOF
FROM ubuntu:20.04
RUN apt update
RUN apt install -y $mainlibs $ocaml g++
EOF
    ;;
 esac

# Take 2.1 opam binary from cache
cp binary/opam $dir/opam

cat >>$dir/Dockerfile << EOF
RUN test -d /opam || mkdir /opam
ENV OPAMROOTISOK 1
ENV OPAMROOT /opam/root
ENV OPAMYES 1
ENV OPAMCONFIRMLEVEL unsafe-yes
ENV OPAMPRECISETRACKING 1
COPY opam /usr/bin/opam
RUN echo 'default-invariant: [ "ocaml" {>= "4.09.0"} ]' > /opam/opamrc
RUN test -f \$OPAMROOT/config || /usr/bin/opam init --no-setup --disable-sandboxing --bare --config /opam/opamrc
RUN /usr/bin/opam switch this-opam || /usr/bin/opam switch create this-opam ocaml
RUN /usr/bin/opam install opam-repository opam-solver opam-state opam-client opam-core opam-devel --deps
RUN opam clean --logs --switch-cleanup
COPY entrypoint.sh /opam/entrypoint.sh
ENTRYPOINT ["/opam/entrypoint.sh"]
EOF

cat >$dir/entrypoint.sh << EOF
#!/bin/sh
set -eux

cd /github/workspace
opam install . --deps
eval \$(opam env)
./configure
make
./opam config report
./opam switch create confs --empty
./opam install -vv conf-autoconf
./opam install -vv conf-gmp
./opam install -vv conf-automake
EOF

chmod +x $dir/entrypoint.sh

#done
