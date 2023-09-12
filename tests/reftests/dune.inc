
(rule
 (alias reftest-download)
 (action
  (diff download.test download.out)))

(alias
 (name reftest)
 (deps (alias reftest-download)))

(rule
 (targets download.out)
 (deps root-N0REP0)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:download.test} %{read-lines:testing-env}))))

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
