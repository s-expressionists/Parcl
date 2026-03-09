(cl:in-package #:parcl.macros.test)

(in-suite :parcl.macros)

(test in-package.smoke
  "Smoke test for the `in-package' macro."
  (with-mock-package-constellation ((nil #1="package1"))
    (eval '(parcl:in-package #1#))
    (is (eq parcl:*package* (parcl:find-package #1#)))))

(test in-package.syntax-errors
  "Ensure that the `in-package' macro signals appropriate error for
invalid syntax."
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:in-package 1)))
  (signals parcl:macro-syntax-error
    (macroexpand '(parcl:in-package "ok" 2))))

(test in-package.runtime-errors
  "Ensure that `in-package' signals appropriate errors at runtime."
  (with-mock-package-system ()
    (signals parcl:package-does-not-exist-error
      (eval '(parcl:in-package "does-not-exist")))))
