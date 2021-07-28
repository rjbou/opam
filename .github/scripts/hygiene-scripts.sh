#!/bin/bash -xue

. .github/scripts/hygiene-preamble.sh

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
  else
    echo "No changes in install.sh"
  fi
  (set +x ; echo -en "::endgroup::check install.sh\r") 2>/dev/null
fi

exit $ERROR
