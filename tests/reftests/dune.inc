
(rule
 (alias reftest-action-disk)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff action-disk.test action-disk.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-action-disk)))

(rule
 (targets action-disk.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:action-disk.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-opam-repo-ci)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff opam-repo-ci.test opam-repo-ci.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-opam-repo-ci)))

(rule
 (targets opam-repo-ci.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:opam-repo-ci.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-pin-depsonly-wtest-6501)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff pin-depsonly-wtest-6501.test pin-depsonly-wtest-6501.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-pin-depsonly-wtest-6501)))

(rule
 (targets pin-depsonly-wtest-6501.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:pin-depsonly-wtest-6501.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-sources-directory-cleaning)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff sources-directory-cleaning.test sources-directory-cleaning.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-sources-directory-cleaning)))

(rule
 (targets sources-directory-cleaning.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:sources-directory-cleaning.test} %{read-lines:testing-env}))))

(rule
 (targets opam-repo-N0REP0)
 (action
  (progn
   (run mkdir -p %{targets}/packages)
   (write-file repo "opam-version:\"2.0\"")
   (run cp repo %{targets}/repo))))

(rule
  (targets root-N0REP0)
  (deps opam-root-version)
  (action
   (progn
    (ignore-stdout
    (run %{bin:opam} init --root=%{targets}
           --no-setup --bypass-checks --no-opamrc --bare
           file://%{dep:opam-repo-N0REP0})))))
