FROM ocamlpro/ocaml:4.12
RUN opam repo
RUN opam switch list-available
RUN opam switch create default ocaml-system --repo git+https://github.com/ocaml/opam-repository#$OPAM_REPO_SHA
RUN ls
