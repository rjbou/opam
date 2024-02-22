
(rule
 (alias reftest-init-scripts)
 (action
  (diff init-scripts.test init-scripts.out)))

(alias
 (name reftest)
 (deps (alias reftest-init-scripts)))

(rule
 (targets init-scripts.out)
 (deps root-N0REP0)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:init-scripts.test} %{read-lines:testing-env}))))

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
