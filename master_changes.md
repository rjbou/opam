Working version changelog, used as a base for the changelog and the release
note.
Possibly scripts breaking changes are prefixed with ✘.
New option/command/subcommand are prefixed with ◈.

## Version
  *

## Global CLI
  * Add default cli mechanism: deprecated options are acceptedi (in the major version) if no cli is specified [#4575 @rjbou]
  * Add `opam config` deprecated subcommands in the default cli  [#4575 @rjbou - fix #4503]

## Init
  *

## Config report
  * Fix `Not_found` (config file) error [#4570 @rjbou]
  * Print variables of installed compilers and their (installed) dependencies [#4570 @rjbou]

## Install
  * Don't patch twice [#4529 @rjbou]

## Remove
  *

## Switch
  * Don't exclude base packages from rebuilds (made some sense in opam 2.0
    with base packages but doesn't make sense with 2.1 switch invariants) [#4569 @dra27]

## Pin
  * Don't look for lock files for pin depends [#4511 @rjbou - fix #4505]
  * Fetch sources when pinning an already pinned package with a different url when using working directory [#4542 @rjbou - fix #4484]
  * Don't ask for confirmation for pinning base packages (similarly makes no
    sense with 2.1 switch invariants) [#4571 @dra27]

## List
  *

## Show
  *

## Var
  *

## Option
  *

## Lint
  * fix W59 & E60 with conf flag handling (no url required) [#4550 @rjbou - fix #4549]

## Lock
  * Don't write lock file with `--read-only', `--safe`, and `--dryrun` [#4562 @rjbou - fix #4320]
  * Make consistent with `opam install`, on local pin always take last opam file even if uncomitted [#4562 @rjbou - fix #4320]

## Opamfile
  * Fix `features` parser [#4507 @rjbou]
  * Rename `hidden-version` to `avoid-version` [#4527 @dra27]

## External dependencies
  * Handle macport variants [#4509 @rjbou - fix #4297]
  * Always upgrade all the installed packages when installing a new package on Archlinux [#4556 @kit-ty-kate]
  * Handle some additional environment variables (`OPAMASSUMEDEPEXTS`, `OPAMNODEPEXTS`) [#4587 @AltGr]

## Sandbox
  * Fix the conflict with the environment variable name used by dune [#4535 @smorimoto - fix ocaml/dune#4166]
  * Kill builds on Ctrl-C with bubblewrap [#4530 @kit-ty-kate - fix #4400]
  * Linux: mount existing TMPDIR read-only, re-bind `$TMPDIR` to a separate tmpfs [#4589 @AltGr]
  * Fix the sandbox check [#4589 @AltGr]
  * Fix sandbox script shell mistake that made `PWD` read-write on remove actions [@4589 @AltGr]
  * Port bwrap improvements to sandbox_exec [@4589 @AltGr]

  * Make the reference tests dune-friendly [#4376 @emillon]
  * Rewrite the very old tests and unify them with the newer ones [@AltGr]
## Repository management
  *

## VCS
  *

## Build
  * Fix opam-devel's tests on platforms without openssl, GNU-diff and a system-wide ocaml [#4500 @kit-ty-kate]
  * Use dune to run reftests [#4376 @emillon]
  * Restrict `extlib` and `dose` version [#4517 @kit-ty-kate]
  * Restrict to opam-file-format 2.1.2 [#4495 @rjbou]
  * Switch to newer version of MCCS (based on newer GLPK) for src_ext [#4559 @AltGr]
  * Bump dune version to 2.8.2 [#4592 @AltGr]

## Infrastructure
  * Release scripts: switch to OCaml 4.10.2 by default, add macos/arm64 builds by default [#4559 @AltGr]
  * Release script: add default cli version check on full archive build [#4575 @rjbou]

## Admin
  *

## Opam installer
  *

## State
  *

# Opam file format
  *

## Solver
  * Fix Cudf preprocessing [#4534 @AltGr]

## Client
  *

## Internal
  * Generalise `mk_tristate_opt' to mk_state_opt [#4575 @rjbou]
  * Fix `opam exec` on native Windows when calling cygwin executables [#4588 @AltGr]
  * Fix temporary file with a too long name causing errors on Windows [#4590 @AltGr]

## Test
  * Fix configure check in github actions [#4593 @rjbou]

## Shell
  *

## Doc
  * Install page: add OSX arm64 [#4506 @eth-arm]
  * Document the default build environment variables [#4496 @kit-ty-kate]
