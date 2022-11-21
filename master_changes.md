Working version changelog, used as a base for the changelog and the release
note.
Prefixes used to help generate release notes, changes, and blog posts:
* ✘ Possibly scripts breaking changes
* ◈ New option/command/subcommand
* [BUG] for bug fixes
* [NEW] for new features (not a command itself)
* [API] api updates 🕮
If there is changes in the API (new non optional argument, function renamed or
moved, etc.), please update the _API updates_ part (it helps opam library
users)

## Version
  * Bump to 2.2.0~alpha3~dev [#5615 @rjbou]

## Global CLI
  * [BUG] Fix `OPAMVERBOSE` setting, 0 and 1 levels was inverted: eg, "no" gives level 1, and "yes" level 0 [#5686 @smorimoto]

## Plugins

## Init

## Config report

## Actions

## Install
  * [BUG] On install driven by `.install` file, track intermediate directories too, in order to have them suppressed at package removal [#5691 @rjbou - fix #5688]
  * [BUG] With `--assume-built`, resolve variables in depends filter according switch & global environment, not only depends predefined variables [#570 @rjbou - fix #5698]
  * [BUG] Handle undefined variables defaults to false in dependencies formula resolution for assume built [#5701 rjbou]

## Remove

## Switch

## Config

## Pin

## List

## Show

## Var/Option

## Update / Upgrade

## Tree
  * Allow packages with a specific version, directories or local opam files, as input [#5613 @kit-ty-kate]
  * Add handling of `--recurse` and `--subpath` for directory arguments [#5613 @kit-ty-kate]

## Exec

## Source

## Lint
  * [BUG] Fix extra-files handling when linting packages from repositories, see #5068 [#5639 @rjbou]
  * Allow to mark a set of warnings as errors using a new syntax -W @1..9 [#5652 @kit-ty-kate @rjbou - fixes #5651]

## Repository
  * [BUG] Fix `OPAMCURL` and `OPAMFETCH` handling [#5607 @rjbou - fix #5597]

## Lock

## Clean

## Opamfile
  * Update populating extra-files fields log [#5640 @rjbou]

## External dependencies

## Format upgrade

## Sandbox
  * Make /tmp writable again to restore POSIX compliancy [#5634 #5662 @kit-ty-kate - fixes #5462]

## VCS

## Build
  * Remove `bigarray` dependency [#5612 @kit-ty-kate]
  * Remove use of deprecated `Printf.kprintf" [#5612 @kit-ty-kate]
  * [BUG] Fix "make cold" on Windows when gcc is available [#5635 @kit-ty-kate - fixes #5600]

## Infrastructure
  * Test OCaml 5.0 and 5.1 in CI [#5672 @kit-ty-kate]

## Release scripts
  * Add ppc64le and s390x support [#5420 @kit-ty-kate]

## Admin
  * Add `add-extrafiles` command to add, check, and update `extra-files:` field according files present in `files/` directory [#5647 @rjbou]

## Opam installer

## State

## Opam file format

## Solver

## Client

## Shell

## Internal

## Internal: Windows

## Test

## Reftests
### Tests
  * Lint: add test for W53, to test extra file with good hash [#5639 @rjbou]
  * Add several checksum & cache validation checks for archive, extra-source section, and extra-file field [#5560 @rjbou]
  * Move local-cache into archive-field-checks test [#5560 @rjbou]
  * Admin: add `admin add-extrafiles` test cases [#5647 @rjbou]
  * Add download test, to check `OPAMCURL/OPAMFETCH` handling [#5607 @rjbou]
  * Add `core/opamSystem.ml` specific tests, to test command resolution [#5600 @rjbou]
  * Add test for `OpamCoreConfig`, to check `OPAMVERBOSE` values [#5686 @rjbou]
  * dot-install: generalise inner script & use less generic filenames [#5691 @rjbou]
  * dot-install: add a test for removal of non specified in .install empty directories [#5701 @rjbou]
  * Add test in assume-built for depends with switch variable filters [#5700 @rjbou]
  * Add undefined variable handling in assume built test [#5701 @rjbou]
  * Add switch-invariant test [#4866 @rjbou]
  * opam root version: add local switch cases [#4763 @rjbou] [2.1.0~rc2 #4715]
  * opam root version: add reinit test casess [#4763 @rjbou] [2.1.0~rc2 #4750]
  * Port opam-rt tests: orphans, dep-cycles, reinstall, and big-upgrade [#4979 @AltGr]
  * Add & update env tests [#4861 #4841 #4974 #5203 @rjbou @dra27 @AltGr]
  * Add remove test [#5004 @AltGr]
  * List:
    * Add some simple tests for the "opam list" command [#5006 @kit-ty-kate]
    * Update list with co-instabillity [#5024 @AltGr]
    * Add a usecase with faulty dependencies computation [#5329 @rjbou]
  * Add clean test for untracked option [#4915 @rjbou]
  * Harmonise some repo hash to reduce opam repository checkout [#5031 @AltGr]
  * Add repo optim enable/disable test [#5015 @rjbou]
  * Add lint test [#4967 @rjbou]
  * Add lock test [#4963 @rjbou]
  * Add working dir/inplace/assume-built test [#5081 @rjbou]
  * Fix github url: `git://` form no more handled [#5097 @rjbou]
  * Add source test [#5101 @rjbou]
  * Add upgrade (and update) test [#5106 @rjbou]
  * Update var-option test with no switch examples [#5025]
  * Escape for cmdliner.1.1.1 output change [#5131 @rjbou]
  * Add deprectaed flag test [#4523 @kit-ty-kate]
  * Add deps-only, install formula [#4975 @AltGr]
  * Update opam root version test:
    * to escape `OPAMROOTVERSION` sed, it matches generated hexa temporary directory names [#5007 @AltGr #5301 @rjbou]
    * several improvments: add repo config check, update generator [#5303 @rjbou]
  * Add json output test [#5143 @rjbou]
    * Add tree json output [#5303 @cannorin @rjbou]
  * Add test for opam file write with format preserved bug in #4936, fixed in #4941 [#4159 @rjbou]
  * Add test for switch upgrade from 2.0 root, with pinned compiler [#5176 @rjbou @kit-ty-kate]
  * Add switch import (for pinned packages) test [#5181 @rjbou]
  * Add `--with-tools` test [#5160 @rjbou]
  * Add a series of reftests showing empty conflict messages [#5253 @kit-ty-kate]
  * Fix the reftests under some heavy parallel hardwear [#5262 @kit-ty-kate]
  * Add some tests for --best-effort to avoid further regressions when trying to install specific versions of packages [@5261 @kit-ty-kate]
  * Add unhelpful conflict error message test [#5270 @kit-ty-kate]
  * Add rebuild test [#5258 @rjbou]
  * Add test for opam tree command [#5171 @cannorin]
  * Update and reintegrate pin & depext test `pin.unix` in `pin` test, with test environment, there is no more need to have it only on unix [#5268 @rjbou @kit-ty-kate]
  * Add a reftest testing for system package manager failure [#5257 @kit-ty-kate]
  * Add autopin test including deps-only, dev-deps, depexts; instrument depext handling to allow depext reftesting [#5236 @AltGr]
  * Add test for init configuration with opamrc [#5315 @rjbou]
  * Test opam pin remove <pkg>.<version> [#5325 @kit-ty-kate]
  * Add a test checking that reinstalling a non-installed package is equivalent to installing it [#5228 @kit-ty-kate]
  * Add a test showing that we still get the reason for installing a package when using opam reinstall on non-installed packages [#5229 @kit-ty-kate]
  * Add a windows test to check case insensitive environment variable handling [#5356 @dra27]
  * Fix the reftests on OCaml 5.0 [#5402 @kit-ty-kate]
  * Add `build-env` overwrite opam vars test [#5364 @rjbou]

### Engine
  * With real path resolved for all opam temp dir, remove `/private` from mac temp dir regexp [#5654 @rjbou]
  * Reimplement `sed-cmd` command regexp, to handle prefixed commands with path not only in subprocess, but anywere in output [#5657 #5607 @rjbou]
  * Add environment variables path addition [#5606 @rjbou]
  * Remove duplicated environment variables in environmenet [#5606 @rjbou]
  * Add `PATH` to replaceable variables [#5606 @rjbou]
  * Set `SHELL` to `/bin/sh` in Windows to ensure `opam env` commands are consistent [#5723 @dra27]
  * Substitution for `BASEDIR` and `OPAMTMP` now recognise the directory with either forward-slashes, back-slashes, or converted to Cygwin
    notation (i.e. C:\cygwin64\tmp\..., C:/cygwin64/tmp/..., or /tmp/...) [#5723 @dra27]

## Github Actions
  * Add coreutils install for cheksum validation tests [#5560 @rjbou]
  * Add `wget` on Cygwin install [#5607 @rjbou]

## Doc
  * Fix typos in readme [#5706 @MisterDA]
  * Fix formatting in the Manual [#5708 @kit-ty-kate]

## Security fixes

# API updates
## opam-client
  * `OpamTreeCommand.run`: now takes an `atom` instead of `name` [#5613 @kit-ty-kate]

## opam-repository

## opam-state

## opam-solver

## opam-format
## opam-format
  * `OpamFilter`: add `expand_interpolations_in_file_full` which allows setting the output file along with the input file [#5629 @rgrinberg]
  * `OpamFilter`: expose `string_interp_regex` which allows clients to identify variable interpolations in strings [#5633 @gridbugs]

## opam-core
  * `OpamSystem.mk_temp_dir`: resolve real path with `OpamSystem.real_path` before returning it [#5654 @rjbou]
  * `OpamSystem.resolve_command`: in command resolution path, check that the file is not a directory and that it is a regular file [#5606 @rjbou - fix #5585 #5597 #5650 #5626]
  * `OpamStd.Config.env_level`: fix level parsing, it was inverted (eg, "no" gives level 1, and "yes" level 0) [#5686 @smorimoto]
  * `OpamSystem.apply_cygpath`: runs `cygpath` over the argument [#5723 @dra27 - function itself added in #3348]
