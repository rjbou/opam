#!/bin/bash

set -xe


if [ "$OPAM_DOC" = "1" ]; then

  if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    . .github/scripts/common/hygiene-preamble.sh
    set -x
    diff="git diff $BASE_REF_SHA..$PR_REF_SHA"
    $diff --name-only --diff-filter=A
    $diff --name-only --diff-filter=A | grep 'src/.*mli'
    files="`$diff --name-only --diff-filter=A | grep 'src/.*mli'`"
    if [ -n "$files" ]; then
      echo '::group::new module added - checking it'
      if $diff --name-only --exit-code -- doc/index.html ; then
        echo '::error new module added but index not updates'
        echo "$files"
        exit 3
      fi
      echo '::engroup::'
    else
      echo 'No new module added'
    fi
  fi
fi
