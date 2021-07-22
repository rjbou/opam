FROM ocamlpro/ocaml:4.12
RUN opam repo
RUN opam switch create confs --empty
RUN opam switch create default ocaml-system
RUN sudo apk add g++
RUN opam pin -y git+https://github.com/ocaml/opam
RUN opam --version
RUN sudo cp /home/ocaml/.opam/default/lib/opam-devel/opam /usr/local/bin
RUN opam install conf-gmp conf-capnproto
