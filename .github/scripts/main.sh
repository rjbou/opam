#!/bin/bash -xue

. .github/scripts/preamble.sh

unset-dev-version () {
  # disable git versioning to allow OPAMYES use for upgrade
  touch src/client/no-git-version
}

export OPAMYES=1
export OCAMLRUNPARAM=b

( # Run subshell in bootstrap root env to build
  (set +x ; echo -en "::group::build opam\r") 2>/dev/null
  if [[ $OPAM_TEST -eq 1 ]] ; then
    export OPAMROOT=$OPAMBSROOT
    # If the cached root is newer, regenerate a binary compatible root
    which opam
    opam config report || echo error
    cat $OPAMROOT/config || echo "NO CONFIG"
    cat /home/runner/.cache/.opam.cached/config || echo "NO CONFIG"
    export OPAMDEBUG=1
    export OPAMVERBOSE=2
    opam env || { rm -rf $OPAMBSROOT; init-bootstrap; }
    eval $(opam env)
  fi

  ./configure --prefix ~/local --with-mccs
  if [ "$OPAM_TEST" != "1" ]; then
    echo 'DUNE_PROFILE=dev' >> Makefile.config
  fi

  if [[ $OPAM_TEST$OPAM_COLD -eq 0 ]] ; then
    make lib-ext
  fi
  if [ $OPAM_UPGRADE -eq 1 ]; then
    unset-dev-version
  fi
  make all admin

  rm -f ~/local/bin/opam
  make install
  (set +x ; echo -en "::endgroup::build opam\r") 2>/dev/null

  export PATH=~/local/bin:$PATH
  opam config report

  if [ "$OPAM_TEST" = "1" ]; then
    # test if an upgrade is needed
    set +e
    opam list 2> /dev/null
    rcode=$?
    if [ $rcode -eq 10 ]; then
      echo "Recompiling for an opam root upgrade"
      (set +x ; echo -en "::group::rebuild opam\r") 2>/dev/null
      unset-dev-version
      make all admin
      rm -f ~/local/bin/opam
      make install
      opam list 2> /dev/null
      rcode=$?
      set -e
      if [ $rcode -ne 10 ]; then
        echo -e "\e[31mBad return code $rcode, should be 10\e[0m";
        exit $rcode
      fi
      (set +x ; echo -en "::endgroup::rebuild opam\r") 2>/dev/null
    fi
    set -e

    # Note: these tests require a "system" compiler and will use the one in $OPAMBSROOT
    make distclean

  fi
)
