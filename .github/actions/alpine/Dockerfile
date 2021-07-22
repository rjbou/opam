FROM ocamlpro/ocaml:4.12
RUN opam repo
RUN opam switch create default ocaml-system
RUN sudo apk add g++
RUN opam install opam-devel
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
