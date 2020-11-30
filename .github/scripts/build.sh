#!/bin/bash -xue

. .github/scripts/preamble.sh

write_versions () {
  echo "LOCAL_OCAML_VERSION=$OCAML_VERSION" > .cache/local/versions
  echo "LOCAL_OPAMBSVERSION=$OPAMBSVERSION" >> .cache/local/versions
}

unset-dev-version () {
  # disable git versioning to allow OPAMYES use for upgrade
  touch src/client/no-git-version
}

export OPAMYES=1
export OCAMLRUNPARAM=b
echo "PATH: $PATH"
ls .cache/local/bin
echo "ocaml"
which ocaml
echo "ocal ver"
ocamlc -vnum


( # Run subshell in bootstrap root env to build
  (set +x ; echo -en "::group::build\r") 2>/dev/null
  if [[ $OPAM_TEST -eq 1 ]] ; then
    export OPAMROOT=$OPAMBSROOT
    # If the cached root is newer, regenerate a binary compatible root
    opam env || { rm -rf $OPAMBSROOT; init-bootstrap; }
    eval $(opam env)
  fi

  ./configure --prefix $PWD/.cache/local --with-mccs

  if [[ $OPAM_TEST$OPAM_COLD -eq 0 ]] ; then
    make lib-ext
  fi
  if [ $OPAM_UPGRADE -eq 1 ]; then
    unset-dev-version
  fi
  make all admin

  rm -f .cache/local/bin/opam
  make install

  if [ "$OPAM_TEST" = "1" ]; then
    # test if an upgrade is needed
    set +e
    opam list 2> /dev/null
    rcode=$?
    if [ $rcode -eq 10 ]; then
      echo "Recompiling for an opam root upgrade"
      unset-dev-version
      make all admin
      rm -f .cache/local/bin/opam
      make install
      opam list 2> /dev/null
      rcode=$?
      set -e
      if [ $rcode -ne 10 ]; then
        echo -e "\e[31mBad return code $rcode, should be 10\e[0m";
        exit $rcode
      fi
    fi
    set -e
    make distclean

    for pin in core format solver repository state client ; do
      opam pin add --kind=path opam-$pin . --yes
    done
    # Compile and run opam-rt
		mkdir -p .cache/build
    cd .cache/build
    wget https://github.com/ocaml/opam-rt/archive/${GITHUB_REF##*/}.tar.gz -O opam-rt.tar.gz || \
    wget https://github.com/ocaml/opam-rt/archive/master.tar.gz -O opam-rt.tar.gz
    tar -xzf opam-rt.tar.gz
    cd opam-rt-*
    opam install ./opam-rt.opam --deps-only -y
    make

    opam switch default
    opam switch remove $OPAMBSSWITCH --yes
  elif [ $OPAM_UPGRADE -ne 1 ]; then
    # Note: these tests require a "system" compiler and will use the one in $OPAMBSROOT
#    OPAMEXTERNALSOLVER="$EXTERNAL_SOLVER" make tests ||
     make tests ||
      (tail -n 2000 _build/default/tests/fulltest-*.log; echo "-- TESTS FAILED --"; exit 1)
  fi
  (set +x ; echo -en "::endgroup::build\r") 2>/dev/null
)

if [ $OPAM_UPGRADE -eq 1 ]; then
  OPAM12=$OPAM12CACHE/bin/opam
  if [[ ! -f $OPAM12 ]]; then
    mkdir -p $OPAM12CACHE/bin
    wget https://github.com/ocaml/opam/releases/download/1.2.2/opam-1.2.2-x86_64-Linux -O $OPAM12
    chmod +x $OPAM12
  fi
  export OPAMROOT=/tmp/opamroot
  rm -rf $OPAMROOT
  if [[ ! -d $OPAM12CACHE/root ]]; then
    $OPAM12 init
    cp -r /tmp/opamroot/ $OPAM12CACHE/root
  else
    cp -r $OPAM12CACHE/root /tmp/opamroot
  fi
  set +e
  $OPAM12 --version
  opam -version
  opam update
  rcode=$?
  if [ $rcode -ne 10 ]; then
    echo "[31mBad return code $rcode, should be 10[0m";
    exit $rcode
  fi
  opam_version=$(sed -ne 's/opam-version: *//p' $OPAMROOT/config)
  if [ "$opam_version" = '"1.2"' ]; then
    echo -e "\e[31mUpgrade failed, opam-root is still 1.2\e[0m";
    cat $OPAMROOT/config
    exit 2
  fi
  exit 0
fi

( # Finally run the tests, in a clean environment
  export OPAMKEEPLOGS=1

  if [[ $OPAM_TEST -eq 1 ]] ; then
    cd .cache/build/opam-rt-*
#    OPAMEXTERNALSOLVER="$EXTERNAL_SOLVER" make KINDS="local git" run
     make KINDS="local git" run
  else
    if [[ $OPAM_COLD -eq 1 ]] ; then
      export PATH=.cache/bootstrap/ocaml/bin:$PATH
    fi

    # Test basic actions
    # The SHA is fixed so that upstream changes shouldn't affect CI. The SHA needs
    # to be moved forwards when a new version of OCaml is added to ensure that the
    # ocaml-system package is available at the correct version.
    opam init --bare default git+https://github.com/ocaml/opam-repository#$OPAM_REPO_SHA
    opam switch create default ocaml-system
    eval $(opam env)
    opam install lwt
    opam list
    opam config report
  fi
)

rm -f .cache/local/bin/opam

