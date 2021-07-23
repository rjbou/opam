#!/bin/bash -xue

. .github/scripts/hygiene-preamble.sh

###
# Check configure
###

(set +x ; echo -en "::group::check configure\r") 2>/dev/null
case $GITHUB_EVENT_NAME in
  push)
    CheckConfigure "$GITHUB_SHA"
    ;;
  pull_request)
    for commit in $(git rev-list $BASE_REF_SHA...$PR_REF_SHA --reverse)
    do
      echo "check configure for $commit"
      CheckConfigure "$commit"
    done
    ;;
  *)
    echo "no configure to check for unknown event"
    ;;
esac
(set +x ; echo -en "::endgroup::check configure\r") 2>/dev/null


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

###
# Default cli version check
###

if [ "$GITHUB_EVENT_NAME" = "push" ] && [ "$BRANCH" = "master" ]; then
  (set +x ; echo -en "::group::check default cli\r") 2>/dev/null
  CURRENT_MAJOR="`sed -n "s/^AC_INIT(opam,\([0-9]\+\)[^0-9]*.*)$/\1/p" configure.ac`"
  DEFAULT_CLI_MAJOR="`sed -n "/let *default *=/s/.*(\([0-9]*\)[^0-9]*.*/\1/p" src/client/opamCLIVersion.ml`"
  if [ $CURRENT_MAJOR -eq $DEFAULT_CLI_MAJOR ]; then
    echo "Major viersion is default cli one: $CURRENT_MAJOR"
  else
    echo -e "[\e[31mERROR\e[0m] Major version $CURRENT_MAJOR and default cli version $DEFAULT_CLI_MAJOR mismatches"
  (set +x ; echo -en "::endgroup::check default cli\r") 2>/dev/null
    ERROR=1
  fi
fi

exit $ERROR
