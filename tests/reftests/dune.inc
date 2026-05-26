
(rule
 (alias reftest-repository-http)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff repository-http.test repository-http.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-repository-http)))

(rule
 (targets repository-http.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:repository-http.test} %{read-lines:testing-env}))))

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
