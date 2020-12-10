#!/bin/bash -xue

. .github/scripts/preamble.sh

set -e
set -u

CheckConfigure () {
  (set +x ; echo -en "::group::check configure\r") 2>/dev/null
  GIT_INDEX_FILE=tmp-index git read-tree --reset -i "$1"
  git diff-tree --diff-filter=d --no-commit-id --name-only -r "$1" \
    | (while IFS= read -r path
  do
    case "$path" in
      configure|configure.ac|m4/*)
        touch CHECK_CONFIGURE;;
    esac
  done)
  rm -f tmp-index
  if [[ -e CHECK_CONFIGURE ]] ; then
    echo "configure generation altered in $1"
    echo 'Verifying that configure.ac generates configure'
    git clean -dfx
    git checkout -f "$1"
    mv configure configure.ref
    make configure
    if ! diff -q configure configure.ref >/dev/null ; then
      echo -e "[\e[31mERROR\e[0m] configure.ac in $1 doesn't generate configure, \
please run make configure and fixup the commit"
      ERROR=1
    fi
  fi
  (set +x ; echo -en "::endgroup::check configure\r") 2>/dev/null
}

#set +x

ERROR=0

###
# Check install.sh
###

if [ "$GITHUB_EVENT_NAME" = "pull_request" ] ; then
  (set +x ; echo -en "::group::check install.sh\r") 2>/dev/null
  if ! git diff "$BASE_REF_SHA..$PR_REF_SHA" --name-only --exit-code -- shell/install.sh > /dev/null ; then
    echo "shell/install.sh updated - checking it"
    eval $(grep '^\(OPAM_BIN_URL_BASE\|DEV_VERSION\|VERSION\)=' shell/install.sh)
    echo "OPAM_BIN_URL_BASE=$OPAM_BIN_URL_BASE"
    echo "VERSION = $VERSION"
    echo "DEV_VERSION = $DEV_VERSION"
    for VERSION in $DEV_VERSION $VERSION; do
      eval $(grep '^TAG=' shell/install.sh)
      echo "TAG = $TAG"
      ARCHES=0

      while read -r key sha
      do
        ARCHES=1
        URL="$OPAM_BIN_URL_BASE$TAG/opam-$TAG-$key"
        echo "Checking $URL"
        check=$(curl -Ls "$URL" | sha512sum | cut -d' ' -f1)
        if [ "$check" = "$sha" ] ; then
          echo "Checksum as expected ($sha)"
        else
          echo -e "[\e[31mERROR\e[0m] Checksum downloaded: $check"
          echo -e "[\e[31mERROR\e[0m] Checksum install.sh: $sha"
          ERROR=1
        fi
      done < <(sed -ne "s/.*opam-$TAG-\([^)]*\).*\"\([^\"]*\)\".*/\1 \2/p" shell/install.sh)
    done
    if [ $ARCHES -eq 0 ] ; then
      echo "[\e[31mERROR\e[0m] No sha512 checksums were detected in shell/install.sh"
      echo "That can't be right..."
      ERROR=1
    fi
  fi
  (set +x ; echo -en "::endgroup::check install.sh\r") 2>/dev/null
fi


###
# Check configure
###

case $GITHUB_EVENT_NAME in
  push)
    CheckConfigure "$GITHUB_SHA"
    ;;
  pull_request)
    for commit in $(git rev-list $BASE_REF_SHA...$PR_REF_SHA --reverse)
    do
      CheckConfigure "$commit"
    done
    ;;
  *)
    echo "no configure to check for unknown event"
    ;;
esac


###
# Check src_ext patches
###

(set +x ; echo -en "::group::check src_ext patches\r") 2>/dev/null
# Check that the lib-ext/lib-pkg patches are "simple"
make -C src_ext PATCH="busybox patch" clone
make -C src_ext PATCH="busybox patch" clone-pkg
# Check that the lib-ext/lib-pkg patches have been re-packaged
cd src_ext
../shell/re-patch.sh
if [[ $(find patches -name \*.old | wc -l) -ne 0 ]] ; then
  echo -e "[\e[31mERROR\e[0m] ../shell/re-patch.sh should be run from src_ext before CI check"
  git diff
  ERROR=1
fi
cd ..
(set +x ; echo -en "::endgroup::check src_ext patches\r") 2>/dev/null

exit $ERROR
