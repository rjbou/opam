
(rule
 (alias reftest-core-config)
 (action
  (diff core-config.test core-config.out)))

(alias
 (name reftest)
 (deps (alias reftest-core-config)))

(rule
 (targets core-config.out)
 (deps root-N0REP0)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:core-config.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-core-system.unix)
 (enabled_if (= %{os_type} "Unix"))
 (action
  (diff core-system.unix.test core-system.unix.out)))

(alias
 (name reftest)
 (enabled_if (= %{os_type} "Unix"))
 (deps (alias reftest-core-system.unix)))

(rule
 (targets core-system.unix.out)
 (deps root-N0REP0)
 (enabled_if (= %{os_type} "Unix"))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:core-system.unix.test} %{read-lines:testing-env}))))

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
 (alias reftest-env)
 (action
  (diff env.test env.out)))

(alias
 (name reftest)
 (deps (alias reftest-env)))

(rule
 (targets env.out)
 (deps root-N0REP0)
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:env.test} %{read-lines:testing-env}))))

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
