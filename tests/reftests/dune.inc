
(rule
 (alias reftest-pin)
 (action
  (diff pin.test pin.out)))

(alias
 (name reftest)
 (deps (alias reftest-pin)))

(rule
 (targets pin.out)
 (deps root-N0REP0)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe} %{dep:pin.test} %{read-lines:testing-env}))))

(rule
 (targets opam-repo-N0REP0)
 (action
  (progn
   (run mkdir -p %{targets}/packages)
   (write-file repo "opam-version:\"2.0\"")
   (run cp repo %{targets}/repo))))

(rule
  (targets root-N0REP0)
  (action
   (progn
    (ignore-stdout
    (run %{bin:opam} init --root=%{targets}
           --no-setup --bypass-checks --no-opamrc --bare
           file://%{dep:opam-repo-N0REP0})))))
