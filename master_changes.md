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

## Plugins

## Init

## Config report

## Actions

## Install

## Remove

## Switch

## Config

## Pin

## List

## Show

## Var/Option

## Update / Upgrade

## Exec

## Source

## Lint
  * Fix extra-files handling when linting packages from repositories, see #5068 [#5639 @rjbou]

## Repository

## Lock

## Clean

## Opamfile
  * Update populating extra-files fields log [#5640 @rjbou]

## External dependencies

## Format upgrade

## Sandbox

## VCS

## Build
  * Remove `bigarray` dependency [#5612 @kit-ty-kate]
  * Remove use of deprecated `Printf.kprintf" [#5612 @kit-ty-kate]
  * Fix "make cold" on Windows when gcc is available [#5635 @kit-ty-kate - fixes #5600]

## Infrastructure

## Release scripts
  * Add ppc64le and s390x support [#5420 @kit-ty-kate]

## Admin

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

### Engine

## Github Actions
  * Add coreutils install for cheksum validation tests [#5560 @rjbou]

## Doc

## Security fixes

# API updates
## opam-client

## opam-repository

## opam-state

## opam-solver

## opam-format

* Add `OpamFilter.expand_interpolations_in_file_full` which allows setting the
  output file along with the input file [#5629 @rgrinberg]

* Expose `OpamFilter.string_interp_regex` which allows clients to identify
  variable interpolations in strings [#5633 @gridbugs]

## opam-core
