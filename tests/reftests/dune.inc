
(rule
 (alias reftest-opamrt-big-upgrade)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (action
  (diff opamrt-big-upgrade.test opamrt-big-upgrade.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (deps (alias reftest-opamrt-big-upgrade)))

(rule
 (targets opamrt-big-upgrade.out)
 (deps root-7090735c)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:opamrt-big-upgrade.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-pin)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff pin.test pin.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-pin)))

(rule
 (targets pin.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:pin.test} %{read-lines:testing-env}))))

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

(rule
 (targets opam-archive-7090735c.tar.gz)
 (action (run curl --silent -Lo %{targets} https://github.com/ocaml/opam-repository/archive/7090735c.tar.gz)))

(rule
  (targets opam-repo-7090735c)
  (action
   (progn
    (run mkdir -p %{targets})
    (run tar -C %{targets} -xzf %{dep:opam-archive-7090735c.tar.gz} --strip-components=1))))

(rule
  (targets root-7090735c)
  (deps opam-root-version)
  (action
   (progn
    (ignore-stdout
    (run %{bin:opam} init --root=%{targets}
           --no-setup --bypass-checks --no-opamrc --bare
           file://%{dep:opam-repo-7090735c})))))
