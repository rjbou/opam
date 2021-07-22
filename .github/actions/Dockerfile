FROM ocamlpro/ocaml:4.12
RUN opam repo
RUN opam switch create confs --empty
RUN opam switch create default ocaml-system
RUN sudo apk add g++
RUN opam pin -y git+https://github.com/ocaml/opam
RUN sudo cp /home/ocaml/.opam/default/lib/opam-devel/opam /usr/local/bin
RUN opam --version
RUN rm -rf $OPAMROOT
RUN opam init --reinit -ni --disable-sandboxing --bare
RUN opam switch create confs --empty
RUN opam install conf-gmp
RUN opam install conf-automake
