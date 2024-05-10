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
  * Bump version to 2.2.0~beta3~dev [#5917 @kit-ty-kate]

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

## Tree

## Exec

## Source

## Lint

## Repository

## Lock

## Clean

## Env
  * [BUG] Fix reverting of environment variables, principally on Windows [#5935 @dra27 fix #5838]
  * [BUG] Fix splitting environment variables [#5935 @dra27]

## Opamfile

## External dependencies

## Format upgrade

## Sandbox
## VCS

## Build

## Infrastructure

## Release scripts

## Install script

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

## Benchmarks

## Reftests
### Tests
  * env tests: use `sort` command instead of `unordered` [#5935 @dra27 @rjbou]
  * env.win32: add mixed slashes test [#5935 @dra27]
  * env:win32: add test for environment revert not working correctly for Unix-like variables on Windows [#5935 @dra27]
  * env.win32: add regression test for reverting additions to PATH-like variables [#5935 @dra27]
  * env.win32: add test for `+=` prepending an set and empty variable adds a trailing separator [#5935 @dra27]
  * env.win32: add test for prepending empty variable several times erroneously adds trailing separators [#5935 @dra27]

### Engine
  * Add `sort` command [#5935 @dra27]

## Github Actions

## Doc

## Security fixes

# API updates
## opam-client

## opam-repository

## opam-state

## opam-solver

## opam-format

## opam-core
  * `OpamStd.String`: add `split_quoted` that preserves quoted separator [#5935 @dra27]
