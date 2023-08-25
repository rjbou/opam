
(rule
 (alias reftest-extrafile)
 (action
  (diff extrafile.test extrafile.out)))

(alias
 (name reftest)
 (deps (alias reftest-extrafile)))

(rule
 (targets extrafile.out)
 (deps root-N0REP0)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:extrafile.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-extrasource)
 (action
  (diff extrasource.test extrasource.out)))

(alias
 (name reftest)
 (deps (alias reftest-extrasource)))

(rule
 (targets extrasource.out)
 (deps root-N0REP0)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:extrasource.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-local-cache)
 (action
  (diff local-cache.test local-cache.out)))

(alias
 (name reftest)
 (deps (alias reftest-local-cache)))

(rule
 (targets local-cache.out)
 (deps root-N0REP0)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:local-cache.test} %{read-lines:testing-env}))))

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
