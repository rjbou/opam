
(rule
 (alias reftest-lint)
 (action
  (diff lint.test lint.out)))

(alias
 (name reftest)
 (deps (alias reftest-lint)))

(rule
 (targets lint.out)
 (deps root-N0REP0)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:lint.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-list)
 (action
  (diff list.test list.out)))

(alias
 (name reftest)
 (deps (alias reftest-list)))

(rule
 (targets list.out)
 (deps root-7371c1d9)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:list.test} %{read-lines:testing-env}))))

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
 (targets opam-archive-7371c1d9.tar.gz)
 (action (run curl --silent -Lo %{targets} https://github.com/ocaml/opam-repository/archive/7371c1d9.tar.gz)))

(rule
  (targets opam-repo-7371c1d9)
  (action
   (progn
    (run mkdir -p %{targets})
    (run tar -C %{targets} -xzf %{dep:opam-archive-7371c1d9.tar.gz} --strip-components=1))))

(rule
  (targets root-7371c1d9)
  (deps opam-root-version)
  (action
   (progn
    (ignore-stdout
    (run %{bin:opam} init --root=%{targets}
           --no-setup --bypass-checks --no-opamrc --bare
           file://%{dep:opam-repo-7371c1d9})))))
