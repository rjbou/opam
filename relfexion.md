Un peu de réflexion après avoir regardé https://github.com/ocaml/opam/pull/6394


```quote
2 sets of dependencies: one that we maintain, one that we don't maintain 
```
 ça serait genre 
```bash
opam list --or --depends-on opam-core.2.3.0,opam-format.2.3.0,opam-repository.2.3.0,opam-state.2.3.0,opam-solver.2.3.0,opam-client.2.3.0,opam-devel.2.3.0,opam-installer.2.3.0
``` 
(j'ai l'impression que ça a du sens de tester les revdeps d'opam libs que pour le latest release, on teste juste les derniers changements d'API) Je peux me tromper ... 


Du coup les deux sets c'est genre 
```
builder-web
dream
dune-release
mvar
odep
odig
odoc-driver
orb
topkg-care

opam-0install
opam-0install-cudf
opam-dune-lint
opam-graph
opam-lock
opam-publish
```
Un truc comme ça (il y en a un peu plus si on prend sans version ie `opam list --or --depends-on opam-core,opam-format ...`


Sinon, "add a release step to check CI log for failing projects" -> 
Pas trop clair comment les releases fonctionnent. Y a un script `release.sh`, mais il est appelé manuellement, non? Du coup il faut qu'il aille chercher dans le job du commit (" once bump version & changes PRs merged " -> release/readme.md) pour voir les paquets qui ont fail?  


"add a mechanism to eliminate pinned packages that rely on old versions of opam" 
Les paquets qui sont pinned où dans un switch? Genre une commande opam qui fait "opam unpin --depend-on-previous ->voulant dire égalité stricte '=2.3.0`

à discuter demain (im offline for now )