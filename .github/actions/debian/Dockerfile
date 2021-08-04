FROM debian
RUN apt update
RUN apt install -y ocaml m4 git rsync patch make wget opam ocaml-compiler-libs
RUN mkdir opam
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
