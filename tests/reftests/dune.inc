
(rule
 (alias reftest-init-scripts.unix)
 (enabled_if (= %{os_type} "Unix"))
 (action
  (diff init-scripts.unix.test init-scripts.unix.out)))

(alias
 (name reftest)
 (enabled_if (= %{os_type} "Unix"))
 (deps (alias reftest-init-scripts.unix)))

(rule
 (targets init-scripts.unix.out)
 (deps root-N0REP0)
 (enabled_if (= %{os_type} "Unix"))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:init-scripts.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-init-scripts.win32)
 (enabled_if (= %{os_type} "Win32"))
 (action
  (diff init-scripts.win32.test init-scripts.win32.out)))

(alias
 (name reftest)
 (enabled_if (= %{os_type} "Win32"))
 (deps (alias reftest-init-scripts.win32)))

(rule
 (targets init-scripts.win32.out)
 (deps root-N0REP0)
 (enabled_if (= %{os_type} "Win32"))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:init-scripts.win32.test} %{read-lines:testing-env}))))

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
