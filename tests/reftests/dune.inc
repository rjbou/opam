
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
 (alias reftest-admin-cache)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff admin-cache.test admin-cache.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-admin-cache)))

(rule
 (targets admin-cache.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:admin-cache.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-admin-migrate-extrafiles)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff admin-migrate-extrafiles.test admin-migrate-extrafiles.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-admin-migrate-extrafiles)))

(rule
 (targets admin-migrate-extrafiles.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:admin-migrate-extrafiles.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-admin)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff admin.test admin.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-admin)))

(rule
 (targets admin.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:admin.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-archive)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff archive.test archive.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-archive)))

(rule
 (targets archive.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:archive.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-assume-built)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff assume-built.test assume-built.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-assume-built)))

(rule
 (targets assume-built.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:assume-built.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-autopin)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff autopin.test autopin.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-autopin)))

(rule
 (targets autopin.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:autopin.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-avoid-version)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff avoid-version.test avoid-version.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-avoid-version)))

(rule
 (targets avoid-version.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:avoid-version.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-best-effort)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff best-effort.test best-effort.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-best-effort)))

(rule
 (targets best-effort.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:best-effort.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-cache)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff cache.test cache.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-cache)))

(rule
 (targets cache.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:cache.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-clean)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff clean.test clean.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-clean)))

(rule
 (targets clean.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:clean.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-cli-versioning)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff cli-versioning.test cli-versioning.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-cli-versioning)))

(rule
 (targets cli-versioning.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:cli-versioning.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-config)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff config.test config.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-config)))

(rule
 (targets config.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:config.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-core-config)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff core-config.test core-config.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-core-config)))

(rule
 (targets core-config.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:core-config.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-core-system.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff core-system.unix.test core-system.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-core-system.unix)))

(rule
 (targets core-system.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:core-system.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-depext-only)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff depext-only.test depext-only.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-depext-only)))

(rule
 (targets depext-only.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:depext-only.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-depexts)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff depexts.test depexts.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-depexts)))

(rule
 (targets depexts.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:depexts.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-deprecated)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff deprecated.test deprecated.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-deprecated)))

(rule
 (targets deprecated.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:deprecated.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-deps-only)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff deps-only.test deps-only.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-deps-only)))

(rule
 (targets deps-only.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:deps-only.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-dot-install)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff dot-install.test dot-install.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-dot-install)))

(rule
 (targets dot-install.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:dot-install.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-download)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff download.test download.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-download)))

(rule
 (targets download.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:download.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-effectively-equal)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff effectively-equal.test effectively-equal.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-effectively-equal)))

(rule
 (targets effectively-equal.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:effectively-equal.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-env-idempotent)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff env-idempotent.test env-idempotent.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-env-idempotent)))

(rule
 (targets env-idempotent.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:env-idempotent.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-env)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff env.test env.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-env)))

(rule
 (targets env.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:env.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-env.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff env.unix.test env.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-env.unix)))

(rule
 (targets env.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:env.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-env.win32)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff env.win32.test env.win32.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-env.win32)))

(rule
 (targets env.win32.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:env.win32.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-extrafile)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff extrafile.test extrafile.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-extrafile)))

(rule
 (targets extrafile.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:extrafile.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-extrasource)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff extrasource.test extrasource.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-extrasource)))

(rule
 (targets extrasource.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:extrasource.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-fetch-package)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff fetch-package.test fetch-package.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-fetch-package)))

(rule
 (targets fetch-package.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:fetch-package.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-filter-operators)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff filter-operators.test filter-operators.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-filter-operators)))

(rule
 (targets filter-operators.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:filter-operators.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-filter-variable-resolution)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff filter-variable-resolution.test filter-variable-resolution.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-filter-variable-resolution)))

(rule
 (targets filter-variable-resolution.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:filter-variable-resolution.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-git)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff git.test git.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-git)))

(rule
 (targets git.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:git.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-hooks-variables)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff hooks-variables.test hooks-variables.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-hooks-variables)))

(rule
 (targets hooks-variables.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:hooks-variables.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-hooks-variables.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff hooks-variables.unix.test hooks-variables.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-hooks-variables.unix)))

(rule
 (targets hooks-variables.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:hooks-variables.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-hooks-variables.win32)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff hooks-variables.win32.test hooks-variables.win32.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-hooks-variables.win32)))

(rule
 (targets hooks-variables.win32.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:hooks-variables.win32.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-init-ocaml-eval-variables.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff init-ocaml-eval-variables.unix.test init-ocaml-eval-variables.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-init-ocaml-eval-variables.unix)))

(rule
 (targets init-ocaml-eval-variables.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:init-ocaml-eval-variables.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-init-ocaml-eval-variables.win32)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff init-ocaml-eval-variables.win32.test init-ocaml-eval-variables.win32.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-init-ocaml-eval-variables.win32)))

(rule
 (targets init-ocaml-eval-variables.win32.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:init-ocaml-eval-variables.win32.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-init-scripts.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff init-scripts.unix.test init-scripts.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-init-scripts.unix)))

(rule
 (targets init-scripts.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:init-scripts.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-init-scripts.win32)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff init-scripts.win32.test init-scripts.win32.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-init-scripts.win32)))

(rule
 (targets init-scripts.win32.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Win32") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:init-scripts.win32.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-init)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff init.test init.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-init)))

(rule
 (targets init.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:init.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-inplace)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff inplace.test inplace.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-inplace)))

(rule
 (targets inplace.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:inplace.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-install-check)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff install-check.test install-check.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-install-check)))

(rule
 (targets install-check.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:install-check.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-json.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff json.unix.test json.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-json.unix)))

(rule
 (targets json.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:json.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-keep-build-dir)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff keep-build-dir.test keep-build-dir.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-keep-build-dir)))

(rule
 (targets keep-build-dir.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:keep-build-dir.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-legacy-git)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff legacy-git.test legacy-git.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-legacy-git)))

(rule
 (targets legacy-git.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:legacy-git.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-legacy-local)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff legacy-local.test legacy-local.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-legacy-local)))

(rule
 (targets legacy-local.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:legacy-local.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-lint)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff lint.test lint.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-lint)))

(rule
 (targets lint.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:lint.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-list)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff list.test list.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-list)))

(rule
 (targets list.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:list.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-lock)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff lock.test lock.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-lock)))

(rule
 (targets lock.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:lock.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-no-depexts-sandboxed.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff no-depexts-sandboxed.unix.test no-depexts-sandboxed.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-no-depexts-sandboxed.unix)))

(rule
 (targets no-depexts-sandboxed.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:no-depexts-sandboxed.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-no-depexts)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff no-depexts.test no-depexts.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-no-depexts)))

(rule
 (targets no-depexts.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:no-depexts.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-opam-pkgvar-with-plus)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff opam-pkgvar-with-plus.test opam-pkgvar-with-plus.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-opam-pkgvar-with-plus)))

(rule
 (targets opam-pkgvar-with-plus.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:opam-pkgvar-with-plus.test} %{read-lines:testing-env}))))

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
 (alias reftest-opamroot-versions)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff opamroot-versions.test opamroot-versions.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-opamroot-versions)))

(rule
 (targets opamroot-versions.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:opamroot-versions.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-opamrt-dep-cycle)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff opamrt-dep-cycle.test opamrt-dep-cycle.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-opamrt-dep-cycle)))

(rule
 (targets opamrt-dep-cycle.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:opamrt-dep-cycle.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-opamrt-reinstall)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff opamrt-reinstall.test opamrt-reinstall.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-opamrt-reinstall)))

(rule
 (targets opamrt-reinstall.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:opamrt-reinstall.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-orphans)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff orphans.test orphans.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-orphans)))

(rule
 (targets orphans.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:orphans.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-parallel)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff parallel.test parallel.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-parallel)))

(rule
 (targets parallel.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:parallel.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-pat-sub)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff pat-sub.test pat-sub.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-pat-sub)))

(rule
 (targets pat-sub.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:pat-sub.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-pin-depends-ignore)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff pin-depends-ignore.test pin-depends-ignore.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-pin-depends-ignore)))

(rule
 (targets pin-depends-ignore.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:pin-depends-ignore.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-pin-depends)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff pin-depends.test pin-depends.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-pin-depends)))

(rule
 (targets pin-depends.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:pin-depends.test} %{read-lines:testing-env}))))

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
 (alias reftest-pin-legacy)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff pin-legacy.test pin-legacy.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-pin-legacy)))

(rule
 (targets pin-legacy.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:pin-legacy.test} %{read-lines:testing-env}))))

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
 (alias reftest-process-output.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff process-output.unix.test process-output.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-process-output.unix)))

(rule
 (targets process-output.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:process-output.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-rebuild)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff rebuild.test rebuild.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-rebuild)))

(rule
 (targets rebuild.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:rebuild.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-rec-pin)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff rec-pin.test rec-pin.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-rec-pin)))

(rule
 (targets rec-pin.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:rec-pin.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-reftests)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff reftests.test reftests.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-reftests)))

(rule
 (targets reftests.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:reftests.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-reinstall)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff reinstall.test reinstall.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-reinstall)))

(rule
 (targets reinstall.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:reinstall.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-remove)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff remove.test remove.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-remove)))

(rule
 (targets remove.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:remove.test} %{read-lines:testing-env}))))

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
 (alias reftest-repository-patchdiff)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff repository-patchdiff.test repository-patchdiff.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-repository-patchdiff)))

(rule
 (targets repository-patchdiff.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:repository-patchdiff.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-repository)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff repository.test repository.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-repository)))

(rule
 (targets repository.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:repository.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-resolve-variables)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff resolve-variables.test resolve-variables.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-resolve-variables)))

(rule
 (targets resolve-variables.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:resolve-variables.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-shared-fetch)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff shared-fetch.test shared-fetch.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-shared-fetch)))

(rule
 (targets shared-fetch.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:shared-fetch.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-show)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (action
  (diff show.test show.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (deps (alias reftest-show)))

(rule
 (targets show.out)
 (deps root-009e00fa)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:show.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-simulated-pin)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff simulated-pin.test simulated-pin.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-simulated-pin)))

(rule
 (targets simulated-pin.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:simulated-pin.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-source)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff source.test source.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-source)))

(rule
 (targets source.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:source.test} %{read-lines:testing-env}))))

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
 (alias reftest-swhid.unix)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff swhid.unix.test swhid.unix.out)))

(alias
 (name reftest)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-swhid.unix)))

(rule
 (targets swhid.unix.out)
 (deps root-N0REP0)
 (enabled_if (and (= %{os_type} "Unix") (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:swhid.unix.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-switch-creation)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff switch-creation.test switch-creation.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-switch-creation)))

(rule
 (targets switch-creation.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:switch-creation.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-switch-import)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff switch-import.test switch-import.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-switch-import)))

(rule
 (targets switch-import.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:switch-import.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-switch-invariant)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff switch-invariant.test switch-invariant.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-switch-invariant)))

(rule
 (targets switch-invariant.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:switch-invariant.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-switch-link)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff switch-link.test switch-link.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-switch-link)))

(rule
 (targets switch-link.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:switch-link.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-switch-list-available)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff switch-list-available.test switch-list-available.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-switch-list-available)))

(rule
 (targets switch-list-available.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:switch-list-available.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-switch-list)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff switch-list.test switch-list.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-switch-list)))

(rule
 (targets switch-list.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:switch-list.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-switch-remove)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff switch-remove.test switch-remove.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-switch-remove)))

(rule
 (targets switch-remove.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:switch-remove.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-switch-set)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff switch-set.test switch-set.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-switch-set)))

(rule
 (targets switch-set.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:switch-set.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-tree)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff tree.test tree.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-tree)))

(rule
 (targets tree.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:tree.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-update-upgrade)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff update-upgrade.test update-upgrade.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-update-upgrade)))

(rule
 (targets update-upgrade.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:update-upgrade.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-update)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff update.test update.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-update)))

(rule
 (targets update.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:update.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-upgrade-format)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (action
  (diff upgrade-format.test upgrade-format.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (deps (alias reftest-upgrade-format)))

(rule
 (targets upgrade-format.out)
 (deps root-009e00fa)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) )))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:upgrade-format.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-upgrade-two-point-o)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff upgrade-two-point-o.test upgrade-two-point-o.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-upgrade-two-point-o)))

(rule
 (targets upgrade-two-point-o.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:upgrade-two-point-o.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-upgrade)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff upgrade.test upgrade.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-upgrade)))

(rule
 (targets upgrade.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:upgrade.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-var-option)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff var-option.test var-option.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-var-option)))

(rule
 (targets var-option.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:var-option.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-variables-sh)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff variables-sh.test variables-sh.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-variables-sh)))

(rule
 (targets variables-sh.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:variables-sh.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-verbose-on)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff verbose-on.test verbose-on.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-verbose-on)))

(rule
 (targets verbose-on.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:verbose-on.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-with-dev-setup)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff with-dev-setup.test with-dev-setup.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-with-dev-setup)))

(rule
 (targets with-dev-setup.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:with-dev-setup.test} %{read-lines:testing-env}))))

(rule
 (alias reftest-working-dir)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (action
  (diff working-dir.test working-dir.out)))

(alias
 (name reftest)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (deps (alias reftest-working-dir)))

(rule
 (targets working-dir.out)
 (deps root-N0REP0)
 (enabled_if (and  (or (<> %{env:TESTALL=1} 0) (= %{env:TESTN0REP0=0} 1))))
 (package opam)
 (action
  (with-stdout-to
   %{targets}
   (run ./run.exe %{exe:../../src/client/opamMain.exe.exe} %{dep:working-dir.test} %{read-lines:testing-env}))))

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
 (targets opam-archive-009e00fa.tar.gz)
 (action (run curl --silent -Lo %{targets} https://github.com/ocaml/opam-repository/archive/009e00fa.tar.gz)))

(rule
  (targets opam-repo-009e00fa)
  (action
   (progn
    (run mkdir -p %{targets})
    (run tar -C %{targets} -xzf %{dep:opam-archive-009e00fa.tar.gz} --strip-components=1))))

(rule
  (targets root-009e00fa)
  (deps opam-root-version)
  (action
   (progn
    (ignore-stdout
    (run %{bin:opam} init --root=%{targets}
           --no-setup --bypass-checks --no-opamrc --bare
           file://%{dep:opam-repo-009e00fa})))))
